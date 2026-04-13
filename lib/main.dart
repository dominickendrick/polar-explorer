import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _bluetoothState = false;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future getPermissions() async {
    try {
      await Permission.bluetooth.request();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermissions();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text("Bluetooth State: ${_bluetoothState.toString()}"),
            StreamBuilder(
              stream: FlutterBluePlus.adapterState,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == BluetoothAdapterState.on) {
                    _bluetoothState = true;
                  } else if (snapshot.data == BluetoothAdapterState.off) {
                    _bluetoothState = false;
                  }
                  return BluetoothToggle(
                    value: _bluetoothState,
                    onToggled: (bool value) {
                      setState(() {
                        _bluetoothState = value;
                      });
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BluetoothToggle extends StatefulWidget {
  const BluetoothToggle({
    super.key,
    required this.value,
    this.onToggled,
  });

  final bool value;
  final ValueChanged<bool>? onToggled;

  @override
  State<BluetoothToggle> createState() => _BluetoothToggleState();
}

class _BluetoothToggleState extends State<BluetoothToggle> {
  void _onChanged(bool value) {
    final newValue = !widget.value;
    if (newValue) {
      FlutterBluePlus.turnOn();
    }
    widget.onToggled?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: SwitchListTile(
        activeColor: Color(0xFF015164),
        activeTrackColor: Color(0xFF0291B5),
        inactiveTrackColor: Colors.grey,
        inactiveThumbColor: Colors.white,
        selectedTileColor: Colors.red,
        title: Text(
          "Activate Bluetooth",
          style: TextStyle(fontSize: 14),
        ),
        value: widget.value,
        onChanged: _onChanged,
      ),
    );
  }
}
