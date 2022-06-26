// import 'package:esp_provisioning_example/wifi_screen/wifi.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rodland_farms/deviceConnection/BluetoothDeviceListEntry.dart';

class BleScreen extends StatefulWidget {
  bool start = true;

  BleScreen();

  @override
  _BleScreenState createState() => _BleScreenState();
}

class _BleScreenState extends State<BleScreen> {
  BluetoothState? _bluetoothState;
  bool _isScanning = false;
  List<ScanResult> results = [];

  @override
  void initState() {
    super.initState();

    _startDiscovery();
    // Get current state
    //   FlutterBluetoothSerial.instance.state.then((state) {
    //     setState(() {
    //       _bluetoothState = state;
    //       if (_bluetoothState == BluetoothState.STATE_OFF) {
    //          FlutterBluetoothSerial.instance.requestEnable();
    //       }
    //     });
    //   });
    //   isDiscovering = widget.start;
    //   Future.doWhile(() async {
    //     // Wait if adapter not enabled
    //     if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
    //       return false;
    //     }
    //     await Future.delayed(Duration(milliseconds: 0xDD));
    //     return true;
    //   }).then((_) {
    //     print('BT enabled');
    //     if (isDiscovering) {
    //       _startDiscovery();
    //     }
    //     // Update the address field
    //     FlutterBluetoothSerial.instance.address.then((address) {
    //
    //     });
    //   });
    //
    //
    //   // Listen for futher state changes
    //   FlutterBluetoothSerial.instance
    //       .onStateChanged()
    //       .listen((BluetoothState state) {
    //         print('State change: $state');
    //   });
    // }
    //
    //
    // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  }
  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    // _streamSubscription?.cancel();
    print('Scan stopping');
    FlutterBlue.instance.stopScan();
    super.dispose();
  }

  void _startDiscovery() {
    print('_startDiscovery');
    FlutterBlue.instance.scan().listen((scanResult) {
      print('Discovered ${scanResult.toString()}');

      final existingIndex = results.indexWhere(
          (element) => element.device.id.id == scanResult.device.id.id);
      if (existingIndex >= 0) {
        results[existingIndex] = scanResult;
      } else {
        results.add(scanResult);
      }
      setState(() {
        results.sort((a, b) => a.rssi.compareTo(b.rssi));
      });
    }, onDone: () {
      print('Scan completed');
      setState(() {
        _isScanning = false;
      });
    });
  }

  void _restartDiscovery() {
    FlutterBlue.instance.stopScan();
    setState(() {
      results.clear();
      _isScanning = true;
    });

    Future.delayed(Duration(milliseconds: 500)).then((_) {
      _startDiscovery();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          _bluetoothState = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: _isScanning
                  ? Text('Discovering devices')
                  : Text('Discovered devices'),
              actions: <Widget>[
                _bluetoothState == BluetoothState.on
                    ? FittedBox(
                        child: GestureDetector(
                          onTap: (){
                            FlutterBlue.instance.stopScan();
                          },
                          child: Container(
                          margin: new EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ))
                    : IconButton(
                        icon: Icon(Icons.replay),
                        onPressed: () {
                          _restartDiscovery();
                        },
                      )
              ],
            ),
            body: ListView.builder(
              itemCount: results.length,
              itemBuilder: (BuildContext context, index) {
                ScanResult result = results[index];
                final device = result;
                final address = device.device.id.id.toString();
                bool bonded = false;

                device.device.state.listen((event) {
                  print('Device ${device.device.id.id}...${event.toString()}');
                  setState(() {
                    bonded = event == BluetoothDeviceState.connected;
                  });
                });
                // print('Name:${result.device.toString()}-${result.advertisementData.toString()}');
                return BluetoothDeviceListEntry(
                  device: device,
                  rssi: result.rssi,
                  onTap: () {
                    // Navigator.of(context).pop(result.device);
                  },
                  onLongPress: () async {
                    try {
                      bool bonded = false;
                      FlutterBlue.instance.connectedDevices.then((value) async {
                        print('Connected devices: ${value.toString()}');
                        if (value.indexWhere((element) =>
                                element.id.id == device.device.id.id) >=
                            0) {
                          bonded = true;
                        }
                        if (bonded) {
                          print('Unbonding from ${device.device.id.id}...');
                          await device.device.disconnect();
                          print(
                              'Unbonding from ${device.device.name} has succed');
                        } else {
                          print('Bonding with ${device.device.name}...');
                          device.device.connect();

                        }
                      });
                    } catch (ex) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error occured while bonding'),
                            content: Text("${ex.toString()}"),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          );
        });
  }
}
