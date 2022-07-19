// // import 'package:esp_provisioning_example/wifi_screen/wifi.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:rodland_farms/deviceConnection/BluetoothDeviceListEntry.dart';
// import 'package:rodland_farms/network/network_requests.dart';
// import 'package:wifi_scan/wifi_scan.dart';
//
// class BlClassicScreen extends StatefulWidget {
//   bool start = true;
//
//   BlClassicScreen();
//
//   @override
//   _BlClassicScreenState createState() => _BlClassicScreenState();
// }
//
// class _BlClassicScreenState extends State<BlClassicScreen> {
//   StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
//   List<BluetoothDiscoveryResult> results =
//       List<BluetoothDiscoveryResult>.empty(growable: true);
//   bool isDiscovering = false;
//
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
//
//   Timer? _discoverableTimeoutTimer;
//   //int _discoverableTimeoutSecondsLeft = 0;
//   //bool _autoAcceptPairingRequests = false;
//   BluetoothConnection? _connection;
//
//   WiFiAccessPoint? _selectedWifiNetwork;
//   String? _password;
//   String? hostname;
//
//   @override
//   void initState() {
//     super.initState();
//     // Get current state
//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() {
//         _bluetoothState = state;
//       });
//     });
//     if (!_bluetoothState.isEnabled) {
//       FlutterBluetoothSerial.instance.requestEnable();
//     }
//     isDiscovering = widget.start;
//     if (isDiscovering) {
//       _startDiscovery();
//     }
//   }
//
//   void _restartDiscovery() {
//     setState(() {
//       results.clear();
//       isDiscovering = true;
//     });
//
//     _startDiscovery();
//   }
//
//   void _startDiscovery() {
//     _streamSubscription =
//         FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
//       setState(() {
//         final existingIndex = results.indexWhere(
//             (element) => element.device.address == r.device.address);
//         if (existingIndex >= 0) {
//           results[existingIndex] = r;
//         } else {
//           results.add(r);
//         }
//       });
//     });
//
//     _streamSubscription!.onDone(() {
//       setState(() {
//         isDiscovering = false;
//       });
//     });
//   }
//
//   // @TODO . One day there should be `_pairDevice` on long tap on something... ;)
//
//   @override
//   void dispose() {
//     // Avoid memory leak (`setState` after dispose) and cancel discovery
//     _streamSubscription?.cancel();
//
//     FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
//     _discoverableTimeoutTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: isDiscovering
//             ? const Text('Discovering devices')
//             : const Text('Discovered devices'),
//         actions: <Widget>[
//           isDiscovering
//               ? FittedBox(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     child: const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   ),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.replay),
//                   onPressed: _restartDiscovery,
//                 )
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: results.length,
//         itemBuilder: (BuildContext context, index) {
//           BluetoothDiscoveryResult result = results[index];
//           final device = result.device;
//           final address = device.address;
//           return BluetoothDeviceListEntry(
//             device: device,
//             rssi: result.rssi,
//             onTap: () {
//               if (device.isBonded) {
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                   content: Text('Already bonded'),
//                 ));
//               }
//               EasyLoading.show(status: 'Connecting...');
//               FlutterBluetoothSerial.instance
//                   .bondDeviceAtAddress(result.device.address)
//                   .then((value) {
//                 print(value);
//                 if (value == true) {
//                   print("Bonded:${result.device.bondState}");
//                   setState(() {
//                     results[results.indexOf(result)] = BluetoothDiscoveryResult(
//                         device: BluetoothDevice(
//                             name: device.name ?? '',
//                             address: address,
//                             type: device.type,
//                             bondState: BluetoothBondState.bonded),
//                         rssi: result.rssi);
//                   });
//                   EasyLoading.show(status: 'Connected. Communicating...');
//                   tryEstablishLink(result);
//                 } else {
//                   print("Not Bonded");
//                   EasyLoading.showError(
//                       "Something went wrong. Please try again.");
//                 }
//               }).onError((error, stackTrace) {
//                 print("Error:$error");
//                 print("StackTrace:$stackTrace");
//                 if (error.toString().contains("already bonded")) {
//                   print("Bonded:${result.device.bondState}");
//                   EasyLoading.show(status: 'Connected. Communicating...');
//                   setState(() {
//                     results[results.indexOf(result)] = BluetoothDiscoveryResult(
//                         device: BluetoothDevice(
//                             name: device.name ?? '',
//                             address: address,
//                             type: device.type,
//                             bondState: BluetoothBondState.bonded),
//                         rssi: result.rssi);
//                   });
//                   tryEstablishLink(result);
//                 } else {
//                   print("Not Bonded");
//                   EasyLoading.showError(
//                       "Something went wrong. Please try again.");
//                 }
//               });
//               // Navigator.of(context).pop(result.device);
//             },
//             onLongPress: () async {
//               try {} catch (ex) {
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Text('Error occured while bonding'),
//                       content: Text(ex.toString()),
//                       actions: <Widget>[
//                         TextButton(
//                           child: const Text("Close"),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> tryEstablishLink(BluetoothDiscoveryResult result) async {
//     if (_connection != null && _connection?.isConnected == true) {
//       print("Connection still active");
//       EasyLoading.dismiss();
//       hostname = result.device.name?.trim().split('-')[1];
//       //addDeviceToDashboard(hostname!);
//       scanForWifiNetworks();
//       return;
//     } else {
//       BluetoothConnection.toAddress(result.device.address).then((connection) {
//         _connection = connection;
//         print('Connected to the device ${result.device.name}');
//         hostname = result.device.name?.trim().split('-')[1];
//         //addDeviceToDashboard(hostname!);
//         //connection.input?.listen((Uint8List data) {
//         //String received = ascii.decode(data);
//         //print('Data incoming: $received');
//         //if(received.isNotEmpty){
//         /*}
//         if (ascii.decode(data).contains('!')) {
//           connection.finish(); // Closing connection
//           print('Disconnecting by local host');
//         }
//       }).onDone(() {
//         print('Disconnected by remote request');
//       }); */
//         //Future.delayed(const Duration(seconds: 1), () {
//         if (connection.isConnected) {
//           EasyLoading.showSuccess("Link established");
//           scanForWifiNetworks();
//         } else {
//           EasyLoading.showError("Could not establish link. Please try again.");
//         }
//         //});
//         /*}).catchError((error) {
//       EasyLoading.showError("Could not establish link. Please try again.");
//       print('Cannot connect, exception occured');
//       print(error); */
//       });
//     }
//   }
//
//   Future<void> scanForWifiNetworks() async {
//     // EasyLoading.show(status: 'Scanning for wifi networks...');
//     if (await WiFiScan.instance.hasCapability()) {
//       // can safely call scan related functionalities
//       final error = await WiFiScan.instance.startScan(askPermissions: true);
//       if (error != null) {
//         print('Error: $error');
//       } else {
//         print('Scan started');
//         final result =
//             await WiFiScan.instance.getScannedResults(askPermissions: true);
//         if (result.hasError) {
//           switch (error) {
//             // handle error for values of GetScannedResultErrors
//           }
//         } else {
//           EasyLoading.dismiss();
//           final accessPoints = result.value;
//           print('Scan result: $accessPoints');
//           //show access points in a dialog list
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 shape: RoundedRectangleBorder(
//                     borderRadius:
//                     BorderRadius.circular(20.0)),
//                   title: const Text('Select Your Wifi Network'),
//                   content: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.7,
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: accessPoints?.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         final accessPoint = accessPoints![index];
//                         return ListTile(
//                           title: Text(accessPoint.ssid),
//                           //subtitle: Text(accessPoint.bssid),
//                           onTap: () {
//                             Navigator.of(context).pop();
//                             _selectedWifiNetwork = accessPoint;
//                             EasyLoading.show(status: 'Saving WiFi network name...');
//                             if (_connection != null) {
//                               _connection?.output.add(ascii.encode(accessPoint.ssid));
//                               EasyLoading.showSuccess("Network name set");
//                               Future.delayed(const Duration(seconds: 1), () {
//                                 getWifiPassword(accessPoint);
//                               });
//                             }
//                           },
//                         );
//                       },
//                     )),
//                     actions: <Widget>[
//                       TextButton(
//                         child: const Text("Close"),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   );
//             },
//           );
//         }
//       }
//     } else {
//       // fallback mechanism, like - show user that "scan" is not possible
//     }
//   }
//
//   void getWifiPassword(WiFiAccessPoint accessPoint) {
//     //show password dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//               borderRadius:
//               BorderRadius.circular(20.0)),
//           title: const Text('WiFi Password'),
//           content: SizedBox(
//             height: 125,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'Tap to Enter WiFi Password',
//                     ),
//                     onChanged: (String value){
//                       _password = value;
//                     },
//                   ),
//                   SizedBox(
//                     width: 320.0,
//                     child: RaisedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         EasyLoading.show(status: 'Sending password...');
//                           if (_connection != null) {
//                             //String? message = _password;
//                             _connection?.output.add(ascii.encode(_password!));
//                             EasyLoading.showSuccess("Password sent");
//                             Future.delayed(const Duration(seconds: 1), () {
//                               setUpSensorName();
//                           });
//                         }
//         },
//                       child: const Text(
//                         "Save",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       color: const Color(0xFF1BC0C5),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//   void setUpSensorName() {
//     //show sensor name dialog
//     String sensorName = "";
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//               borderRadius:
//               BorderRadius.circular(20.0)),
//           title: const Text('Plant Name'),
//           content: SizedBox(
//             height: 125,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   //const Text('Tap to enter plant name'),
//                   TextField(
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: 'Tap to enter plant name',
//                     ),
//                     onChanged: (String value) {
//                       sensorName = value;
//                     },
//                   ),
//                   SizedBox(
//                     width: 320.0,
//                     child: RaisedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         EasyLoading.show(status: 'Sending Sensor name...');
//                         if (_connection != null) {
//                           //String message = sensorName;
//                           _connection?.output.add(ascii.encode(sensorName));
//                           EasyLoading.showSuccess("Sensor name sent");
//                           Future.delayed(const Duration(seconds: 1), () {
//                             setUpSensorLocation();
//                           });
//                         }
//                       },
//                       child: const Text(
//                         "Save",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       color: const Color(0xFF1BC0C5),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void setUpSensorLocation() {
//
//    String sensorLocation = "";
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          shape: RoundedRectangleBorder(
//              borderRadius:
//              BorderRadius.circular(20.0)),
//          title: const Text('Plant Location'),
//          content: SizedBox(
//            height: 125,
//            child: Padding(
//              padding: const EdgeInsets.all(12.0),
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                  //const Text('Tap to enter plant name'),
//                  TextField(
//                    decoration: const InputDecoration(
//                      border: InputBorder.none,
//                      hintText: 'Tap to enter plant location',
//                    ),
//                    onChanged: (String value) {
//                      sensorLocation = value;
//                    },
//                  ),
//                  SizedBox(
//                    width: 320.0,
//                    child: RaisedButton(
//                      onPressed: () {
//                        Navigator.of(context).pop();
//                        EasyLoading.show(status: 'Sending Sensor location...');
//                        print("sensor location: " + sensorLocation);
//                        if (_connection != null) {
//                          //String message = sensorName;
//                          _connection?.output.add(ascii.encode(sensorLocation));
//                          EasyLoading.showSuccess("Sensor location sent");
//                          Future.delayed(const Duration(seconds: 3), () {
//                          });
//                        }
//                        addDeviceToDashboard(hostname!);
//                        Navigator.of(context).popUntil((route) => route.isFirst);
//                      },
//                      child: const Text(
//                        "Save",
//                        style: TextStyle(color: Colors.white),
//                      ),
//                      color: const Color(0xFF1BC0C5),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          ),
//        );
//      },
//    );
//   }
//
//   void addDeviceToDashboard(String received) {
//     print("Adding device to dashboard");
//     NetworkRequests().saveDevice(received)
//                         .then((value) async {
//                       EasyLoading.dismiss();
//                       if (value.success == true) {
//                         print("Adding to firebase:");
//                         await FirebaseMessaging.instance
//                             .subscribeToTopic("host_" + received);
//                         EasyLoading.showSuccess("Adding device to dashboard...");
//                         Future.delayed(const Duration(seconds: 1), () {
//                           Navigator.pop(context, true);
//                         });
//                       } else {
//                         EasyLoading.showError(value.message??'Error adding device');
//                       }
//                     }).catchError((error) {
//                       EasyLoading.dismiss();
//                       EasyLoading.showError('Error adding device');
//                     });
//   }
// }