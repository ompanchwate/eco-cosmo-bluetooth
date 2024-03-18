import 'package:fluttertoast/fluttertoast.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

void main() {
  runApp(const MyApp());
}

// Does not have a inbuild Build method so created explicitly
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState(); // Creating a state
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _bluetoothClassicPlugin =
      BluetoothClassic(); // Bluetooth classic object
  List<Device> _discoveredDevices = [];
  List<Device> _connectedDevices = []; // List of connected devices
  Uint8List _data = Uint8List(0);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      // If it is null then unknown.
      platformVersion = await _bluetoothClassicPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the Widget is not mounted then no need to change the state
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _disconnectDevice(Device device) async {
    // Disconnect the device
    await _bluetoothClassicPlugin.disconnect();

    setState(() {
      _connectedDevices
          .remove(device); // Remove the disconnected device from the list
    });

    Fluttertoast.showToast(
      msg: 'Disconnected from ${device.name}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _scan() async {
    _discoveredDevices.clear(); // Clear the previously discovered devices
    await _bluetoothClassicPlugin.startScan();
    _bluetoothClassicPlugin.onDeviceDiscovered().listen((event) {
      setState(() {
        _discoveredDevices.add(event);
      });
    });

    await Future.delayed(Duration(seconds: 10));

    // Show toast message with the count of discovered devices
    Fluttertoast.showToast(
      msg: 'Found ${_discoveredDevices.length} devices',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Widget _buildConnectedDevices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connected Devices:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _connectedDevices.length,
          itemBuilder: (context, index) {
            String hexMessage =
                "46 4D 42 58 AA AA AA AA 00 2E 00 02 00 01 0E A8";
            final device = _connectedDevices[index];
            return ListTile(
              title: Text(device.name ?? 'Unknown Device'),
              subtitle: Text(device.address ?? 'Unknown Device'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _disconnectDevice(device),
                    child: Text('Disconnect'),
                  ),
                  SizedBox(width: 5), // Add some spacing between buttons
                  ElevatedButton(
                    onPressed: () => _sendMessageToDevice(device, hexMessage),
                    child: Text('Ping'),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  int hexToInt(String hex) {
    int value = int.parse(hex, radix: 16);
    return value > 127 ? value - 256 : value;
  }

  Uint8List fromHexString(String s) {
    var buf = <int>[];
    int b = 0;
    int nibble = 0;
    for (int pos = 0; pos < s.length; pos++) {
      if (nibble == 2) {
        buf.add(b);
        nibble = 0;
        b = 0;
      }
      int c = s.codeUnitAt(pos);
      if (c >= 48 && c <= 57) {
        // '0' to '9'
        nibble++;
        b <<= 4;
        b += c - 48;
      }
      if (c >= 65 && c <= 70) {
        // 'A' to 'F'
        nibble++;
        b <<= 4;
        b += c - 65 + 10;
      }
      if (c >= 97 && c <= 102) {
        // 'a' to 'f'
        nibble++;
        b <<= 4;
        b += c - 97 + 10;
      }
    }
    if (nibble > 0) {
      buf.add(b);
    }
    return Uint8List.fromList(buf.map((e) => e & 0xFF).toList());
  }

  Future<void> _sendMessageToDevice(Device device, String message) async {
    if (_connectedDevices.contains(device)) {
      // List<int> byteArray =
      //     message.split(' ').map((String hex) => hexToInt(hex)).toList();
      Uint8List byteArray = fromHexString(message);
      // String message1 = byteArray
      //     .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
      //     .join(' ');
      print(byteArray);
      await _bluetoothClassicPlugin.write(message);
      Fluttertoast.showToast(
        msg: "${message} sent to ${device.name}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Device is not connected",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _connectToDevice(Device device) async {
    await _bluetoothClassicPlugin.connect(
        device.address, "00001101-0000-1000-8000-00805f9b34fb");

    setState(() {
      _connectedDevices.add(device); // Add the connected device to the list
    });
    Fluttertoast.showToast(
      msg: 'Connected to ${device.name}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    // } else {
    //   Fluttertoast.showToast(
    //     msg: 'Already connected to ${device.address}',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.blue,
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Classic Devices'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildConnectedDevices(), // Show connected devices
              Center(
                child: ElevatedButton(
                  onPressed: _scan,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(350, 55),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  child: const Text(
                    "Scan",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _discoveredDevices.length,
                itemBuilder: (context, index) {
                  final device = _discoveredDevices[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(device.name ?? 'Unknown Device'),
                      subtitle: Text(device.address ?? 'Unknown Device'),
                      // trailing: Text(device.rssi),
                      onTap: () => _connectToDevice(device),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
