import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:polar_explorer/heart_rate_service.dart';

import 'connection_state_card.dart';

import 'device_selector.dart';
import 'error_banner.dart';
import 'heart_rate_service_card.dart';
import 'home_screen_view_model.dart';

class BluetoothAdapterStatus extends StatelessWidget {
  const BluetoothAdapterStatus({super.key, required this.onStateChanged});

  final void Function(bool isOn) onStateChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterBluePlus.adapterState.handleError((e) {
        // TODO: Handle the error properly, e.g., show a dialog to the user or log the error.
        print(e.toString());
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Bluetooth unavailable");
        }
        if (snapshot.hasData) {
          final isOn = snapshot.data == BluetoothAdapterState.on;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onStateChanged(isOn);
          });
          if (isOn) {
            return Text("Bluetooth on");
          } else {
            return Text("Bluetooth off, please turn on Bluetooth to continue");
          }
        } else {
          return Container();
        }
      },
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polar Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(24, 26, 66, 1.0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(24, 26, 66, 1.0),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeScreenViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeScreenViewModel();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          var children = [
            // Error banner
            if (_viewModel.hasError)
              ErrorBanner(
                message: _viewModel.currentError!.message,
                onDismiss: _viewModel.clearError,
              ),

            // Loading indicator
            if (_viewModel.isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Initializing...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    switch (_viewModel.appConnectionState) {
                      AppConnectionState.bluetoothOff => ConnectionStateCard(
                        child: BluetoothAdapterStatus(
                          onStateChanged: _viewModel.updateBluetoothState,
                        ),
                      ),
                      AppConnectionState.scanningForDevices =>
                        ConnectionStateCard(
                          child: DeviceSelector(
                            viewModel: _viewModel.deviceSelectorViewModel,
                            onDeviceSelected: _viewModel.selectDevice,
                          ),
                        ),
                      AppConnectionState.deviceSelectedNotConnected =>
                        ConnectionStateCard(
                          child: DeviceSelector(
                            viewModel: _viewModel.deviceSelectorViewModel,
                            onDeviceSelected: _viewModel.selectDevice,
                          ),
                        ),
                      AppConnectionState.heartRateServiceAvailable =>
                        HeartRateServiceCard(
                          child: HeartRateService(
                            heartRateService: _viewModel.heartRateData,
                            connectionState: _viewModel.connectionState,
                          ),
                        ),
                    },
                  ],
                ),
              ),
            ],
          ];
          return Center(
            child: Column(mainAxisAlignment: .center, children: children),
          );
        },
      ),
    );
  }
}
