// import 'package:esp_provisioning_example/wifi_screen/wifi.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rodland_farms/network/network_requests.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../ble.dart';
import 'device_screen.dart';

class BlEScreen extends StatefulWidget {
  bool start = true;

  BlEScreen();

  @override
  _BlEScreenState createState() => _BlEScreenState();
}

class _BlEScreenState extends State<BlEScreen> {

  BluetoothState state = BluetoothState.unknown;

  Timer? _discoverableTimeoutTimer;

  WiFiAccessPoint? _selectedWifiNetwork;
  String? _password = "password123", _sensorLocation = "bar", _sensorName = "foo", hostname, _network = "sableBusiness";

  @override
  void initState() {
    super.initState();
  }

  void _restartDiscovery() {
    setState(() {
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    FlutterBlue.instance
        .startScan(timeout: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Find Devices'),
              ),
              body: RefreshIndicator(
                onRefresh: () =>
                    FlutterBlue.instance.startScan(timeout: const Duration(seconds: 4)),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      //  @ TODO add if statement to only display ble devices that being with "Rodland"
                      StreamBuilder<List<BluetoothDevice>>(
                        stream: Stream.periodic(const Duration(seconds: 2))
                            .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                        initialData: const [],
                        builder: (c, snapshot) => Column(
                          children: snapshot.data!.map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return ElevatedButton(
                                    child: const Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceScreen(device: d))),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                      StreamBuilder<List<ScanResult>>(
                        stream: FlutterBlue.instance.scanResults,
                        initialData: const [],
                        builder: (c, snapshot) => Column(
                          children: snapshot.data!
                              .map(
                                (r) => ScanResultTile(
                              result: r,
                              onTap:
                              //  @TODO if device not paired, _pairDevice
                              //  @TODO onConnect to device read input to hostname variable
                              //  @TODO call scanForWifiNetworks()
                              //  @TODO move ESP.BLE call to device addDeviceToDashboard
                                  () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                r.device.connect();
                                ESPBLE().scanForESPDevice(_sensorName!, _sensorLocation!, _network!, _password!);
                                return DeviceScreen(device: r.device);
                              })),
                            ),
                          )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: StreamBuilder<bool>(
                stream: FlutterBlue.instance.isScanning,
                initialData: false,
                builder: (c, snapshot) {
                  if (snapshot.data!) {
                    return FloatingActionButton(
                      onPressed: () => FlutterBlue.instance.stopScan(),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.stop),
                    );
                  } else {
                    return FloatingActionButton(
                        child: const Icon(Icons.search),
                        onPressed: () => FlutterBlue.instance
                            .startScan(timeout: const Duration(seconds: 4)));
                  }
                },
              ),
            );
            ;
          }
          return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              const Text("Press the button to request turning on Bluetooth"),
          const SizedBox(height: 20.0),
          const SizedBox(height: 10.0),
          RaisedButton(
            onPressed: (() async {
              customEnableBT(context);
            }),
            child: const Text('Enable Bluetooth'),
          ),
          ]);

        });

  }

  Future<void> scanForWifiNetworks() async {
    // EasyLoading.show(status: 'Scanning for wifi networks...');
    if (await WiFiScan.instance.hasCapability()) {
      // can safely call scan related functionalities
      final error = await WiFiScan.instance.startScan(askPermissions: true);
      if (error != null) {
        print('Error: $error');
      } else {
        print('Scan started');
        final result =
        await WiFiScan.instance.getScannedResults(askPermissions: true);
        if (result.hasError) {
          switch (error) {
          // handle error for values of GetScannedResultErrors
          }
        } else {
          EasyLoading.dismiss();
          final accessPoints = result.value;
          if (kDebugMode) {
            print('Scan result: $accessPoints');
          }
          //show access points in a dialog list
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(20.0)),
                title: const Text('Select Your Wifi Network'),
                content: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: accessPoints?.length,
                      itemBuilder: (BuildContext context, int index) {
                        final accessPoint = accessPoints![index];
                        return ListTile(
                          title: Text(accessPoint.ssid),
                          //subtitle: Text(accessPoint.bssid),
                          onTap: () {
                            Navigator.of(context).pop();
                            _selectedWifiNetwork = accessPoint;
                            EasyLoading.show(status: 'Saving WiFi network name...');
                            getWifiPassword(accessPoint);
                          },
                        );
                      },
                    )),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      // @TODO fallback mechanism, like - show user that "scan" is not possible
    }
  }

  void getWifiPassword(WiFiAccessPoint accessPoint) {
    //show password dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20.0)),
          title: const Text('WiFi Password'),
          content: SizedBox(
            height: 125,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tap to Enter WiFi Password',
                    ),
                    onChanged: (String value){
                      _password = value;
                    },
                  ),
                  SizedBox(
                    width: 320.0,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        EasyLoading.show(status: 'Sending password...');
                        //   if (_connection != null) {
                        //     //String? message = _password;
                        //     _connection?.output.add(ascii.encode(_password!));
                        //     EasyLoading.showSuccess("Password sent");
                        //     Future.delayed(const Duration(seconds: 1), () {
                               setUpSensorName();
                        //     });
                        // }
                      },
                      color: const Color(0xFF1BC0C5),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  String sensorName = "";
  void setUpSensorName() {
    //show sensor name dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20.0)),
          title: const Text('Plant Name'),
          content: SizedBox(
            height: 125,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //const Text('Tap to enter plant name'),
                  TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tap to enter plant name',
                    ),
                    onChanged: (String value) {
                      _sensorName = value;
                    },
                  ),
                  SizedBox(
                    width: 320.0,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        EasyLoading.show(status: 'Sending Sensor name...');
                        // if (_connection != null) {
                        //   //String message = sensorName;
                        //   _connection?.output.add(ascii.encode(sensorName));
                        //   EasyLoading.showSuccess("Sensor name sent");
                        //   Future.delayed(const Duration(seconds: 1), () {
                             setUpSensorLocation();
                        //   });
                        // }
                      },
                      color: const Color(0xFF1BC0C5),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void setUpSensorLocation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20.0)),
          title: const Text('Plant Location'),
          content: SizedBox(
            height: 125,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //const Text('Tap to enter plant name'),
                  TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tap to enter plant location',
                    ),
                    onChanged: (String value) {
                      _sensorLocation = value;
                    },
                  ),
                  SizedBox(
                    width: 320.0,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        EasyLoading.show(status: 'Sending Sensor location...');
                        addDeviceToDashboard(hostname!);
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      color: const Color(0xFF1BC0C5),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void addDeviceToDashboard(String received) {
    print("Adding device to dashboard");
    NetworkRequests().saveDevice(received)
        .then((value) async {
      EasyLoading.dismiss();
      if (value.success == true) {
        print("Adding to firebase:");
        await FirebaseMessaging.instance
            .subscribeToTopic("host_$received");
        EasyLoading.showSuccess("Adding device to dashboard...");
        //  @TODO call to ESPBLE().scanForESPDevice(_sensorName!, _sensorLocation!, _network!, _password!);
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context, true);
        });
      } else {
        EasyLoading.showError(value.message??'Error adding device');
      }
    }).catchError((error) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error adding device');
    });
  }

  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) {
      print(value);
    });
  }

  Future<void> customEnableBT(BuildContext context) async {
    String dialogTitle = "Bluetooth Permission Required";
    bool displayDialogContent = true;
    String dialogContent = "This app requires Bluetooth to connect to device.";
    //or
    // bool displayDialogContent = false;
    // String dialogContent = "";
    String cancelBtnText = "No";
    String acceptBtnText = "Yes";
    double dialogRadius = 10.0;
    bool barrierDismissible = true; //

    BluetoothEnable.customBluetoothRequest(
        context,
        dialogTitle,
        displayDialogContent,
        dialogContent,
        cancelBtnText,
        acceptBtnText,
        dialogRadius,
        barrierDismissible)
        .then((value) {
      if (kDebugMode) {
        print(value);
      }
    });
  }
}