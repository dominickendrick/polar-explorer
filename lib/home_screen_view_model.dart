import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device_selector.dart';
import 'device_selector_view_model.dart';

enum AppErrorType {
  permission,
  bluetooth,
  connection,
  serviceDiscovery,
  scanning,
}

class AppError {
  final AppErrorType type;
  final String message;
  final String? details;

  AppError({required this.type, required this.message, this.details});

  @override
  String toString() => '$message${details != null ? ' ($details)' : ''}';
}

class HomeScreenViewModel extends ChangeNotifier {
  bool _bluetoothState = false;
  UserBluetoothDevice? _selectedDeviceId;
  BluetoothConnectionState? _connectionState;
  Timer? _scanTimer;
  List<BluetoothService> _services = [];
  BluetoothService? _bluetoothService;
  BluetoothCharacteristic? _bluetoothCharacteristic;
  BluetoothService? _heartRateData;
  late DeviceSelectorViewModel _deviceSelectorViewModel;
  AppError? _currentError;
  bool _isLoading = false;

  // Getters
  bool get bluetoothState => _bluetoothState;
  UserBluetoothDevice? get selectedDeviceId => _selectedDeviceId;
  BluetoothConnectionState? get connectionState => _connectionState;
  List<BluetoothService> get services => _services;
  BluetoothService? get bluetoothService => _bluetoothService;
  BluetoothCharacteristic? get bluetoothCharacteristic =>
      _bluetoothCharacteristic;
  BluetoothService? get heartRateData => _heartRateData;
  DeviceSelectorViewModel get deviceSelectorViewModel =>
      _deviceSelectorViewModel;
  AppError? get currentError => _currentError;
  bool get isLoading => _isLoading;
  bool get hasError => _currentError != null;

  void _setError(AppError error) {
    _currentError = error;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _currentError = null;
    notifyListeners();
  }

  void _clearError() {
    if (_currentError != null) {
      _currentError = null;
      notifyListeners();
    }
  }

  void init() {
    _deviceSelectorViewModel = DeviceSelectorViewModel();
    _deviceSelectorViewModel.init();
    _setLoading(true);
    getPermissions()
        .then((_) {
          _startScan();
          _scanTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            _startScan();
            if (_selectedDeviceId != null &&
                _selectedDeviceId!.device != null) {
              _connectionStateStream(_selectedDeviceId!.device!);
              _getServices(_selectedDeviceId!.device!);
            }
          });
          _setLoading(false);
        })
        .catchError((e) {
          _setError(
            AppError(
              type: AppErrorType.permission,
              message: 'Failed to initialize app',
              details: e.toString(),
            ),
          );
        });
  }

  void updateBluetoothState(bool isOn) {
    _bluetoothState = isOn;
    notifyListeners();
  }

  void selectDevice(UserBluetoothDevice device) {
    _selectedDeviceId = device;
    notifyListeners();
  }

  Future<void> getPermissions() async {
    try {
      _clearError();
      final status = await Permission.bluetooth.request();

      if (status.isDenied) {
        _setError(
          AppError(
            type: AppErrorType.permission,
            message: 'Bluetooth permission is required to scan for devices',
          ),
        );
      } else if (status.isPermanentlyDenied) {
        _setError(
          AppError(
            type: AppErrorType.permission,
            message:
                'Bluetooth permission permanently denied. Please enable in settings.',
          ),
        );
      }
    } catch (e) {
      _setError(
        AppError(
          type: AppErrorType.permission,
          message: 'Failed to request Bluetooth permissions',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _startScan() async {
    try {
      if (!(await FlutterBluePlus.isScanning.first)) {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      }
    } catch (e) {
      _setError(
        AppError(
          type: AppErrorType.scanning,
          message: 'Failed to start scanning for devices',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _getServices(BluetoothDevice device) async {
    try {
      _clearError();
      _services = await device.discoverServices();
      _bluetoothService = _services.first;
      _bluetoothCharacteristic = _bluetoothService!.characteristics.first;

      try {
        _heartRateData = _services.firstWhere(
          (service) => service.uuid.toString().toLowerCase().contains("180d"),
        );
      } catch (e) {
        // Heart rate service not found, which is okay for some devices
        _heartRateData = null;
      }

      _deviceSelectorViewModel.updateDeviceState(
        connectionState: _connectionState,
        services: _services,
      );
      notifyListeners();
    } catch (e) {
      _setError(
        AppError(
          type: AppErrorType.serviceDiscovery,
          message: 'Failed to discover device services',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _connectionStateStream(BluetoothDevice device) async {
    try {
      _clearError();
      await device
          .connect(license: License.free)
          .then((value) {
            device.connectionState.listen((event) async {
              if (event == BluetoothConnectionState.connected) {
                _connectionState = BluetoothConnectionState.connected;
              } else if (event == BluetoothConnectionState.disconnected) {
                _connectionState = BluetoothConnectionState.disconnected;
              } else {
                _connectionState = null;
              }
              _deviceSelectorViewModel.updateDeviceState(
                connectionState: _connectionState,
                services: _services,
              );
              notifyListeners();
            });
          })
          .catchError((e) {
            _setError(
              AppError(
                type: AppErrorType.connection,
                message: 'Connection to device failed',
                details: e.toString(),
              ),
            );
          });
    } catch (e) {
      _setError(
        AppError(
          type: AppErrorType.connection,
          message: 'Failed to connect to device',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _deviceSelectorViewModel.dispose();
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}
