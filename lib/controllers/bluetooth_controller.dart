import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

class BluetoothController extends GetxController {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  final BluetoothClassic _bluetoothClassicPlugin = BluetoothClassic();
  RxList<Device> _discoveredDevices = <Device>[].obs;

  Future<void> scanDevices() async {
    _discoveredDevices.clear(); // Clear the previously discovered devices
    await _bluetoothClassicPlugin.startScan();
    _bluetoothClassicPlugin.onDeviceDiscovered().listen((event) {
      _discoveredDevices.add(event);
    });

    //   FlutterBluePlus.startScan();

    //   // Wait for 5 seconds
    //   await Future.delayed(const Duration(seconds: 5));

    //   FlutterBluePlus.stopScan();
  }

  List<Device> getDiscoveredDevices() {
    return _discoveredDevices.toList();
  }
}
