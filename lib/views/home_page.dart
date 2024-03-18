// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:get/get.dart';
// import 'package:task_one/controllers/bluetooth_controller.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GetBuilder<BluetoothController>(
//         init: BluetoothController(),
//         builder: (controller) {
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 Container(
//                   height: 180,
//                   width: double.infinity,
//                   color: Colors.blue,
//                   child: const Center(
//                     child: Text(
//                       "Bluetooth Devices",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 30,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () => controller.scanDevices(),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: Colors.blue,
//                       minimumSize: const Size(350, 55),
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(5)),
//                       ),
//                     ),
//                     child: const Text(
//                       "Scan",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 StreamBuilder<List<ScanResult>>(
//                   stream: controller.scanResults,
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       return ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: snapshot.data!.length,
//                         itemBuilder: (context, index) {
//                           final data = snapshot.data![index];
//                           return Card(
//                             elevation: 2,
//                             child: ListTile(
//                               title: Text(
//                                   data.device.platformName ?? 'Unknown Device'),
//                               subtitle: Text(data.device.remoteId.toString()),
//                               trailing: Text(data.rssi.toString()),
//                             ),
//                           );
//                         },
//                       );
//                     } else {
//                       return const Center(child: Text("No Devices found"));
//                     }
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
