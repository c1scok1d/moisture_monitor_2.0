// import 'package:esp_provisioning_example/wifi_screen/wifi.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rodland_farms/deviceConnection/BluetoothDeviceListEntry.dart';
import 'package:rodland_farms/network/network_requests.dart';
import 'package:wifi_scan/wifi_scan.dart';

class BleScreen extends StatefulWidget {
  bool start = true;

  BleScreen();

  @override
  _BleScreenState createState() => _BleScreenState();
}

class _BleScreenState extends State<BleScreen> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  bool _autoAcceptPairingRequests = false;
  BluetoothConnection? _connection = null;

  WiFiAccessPoint? _selectedWifiNetwork;
  String? _password;

  @override
  void initState() {
    super.initState();
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    if (!_bluetoothState.isEnabled) {
      FlutterBluetoothSerial.instance.requestEnable();
    }
    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0)
          results[existingIndex] = r;
        else
          results.add(r);
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering
            ? Text('Discovering devices')
            : Text('Discovered devices'),
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (BuildContext context, index) {
          BluetoothDiscoveryResult result = results[index];
          final device = result.device;
          final address = device.address;
          return BluetoothDeviceListEntry(
            device: device,
            rssi: result.rssi,
            onTap: () {
              if (device.isBonded) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Already bonded'),
                ));
              }
              EasyLoading.show(status: 'Connecting...');
              FlutterBluetoothSerial.instance
                  .bondDeviceAtAddress(result.device.address)
                  .then((value) {
                print(value);
                if (value == true) {
                  print("Bonded:${result.device.bondState}");
                  setState(() {
                    results[results.indexOf(result)] = BluetoothDiscoveryResult(
                        device: BluetoothDevice(
                            name: device.name ?? '',
                            address: address,
                            type: device.type,
                            bondState: BluetoothBondState.bonded),
                        rssi: result.rssi);
                  });
                  EasyLoading.show(status: 'Connected. Communicating...');
                  tryEstablishLink(result);
                } else {
                  print("Not Bonded");
                  EasyLoading.showError(
                      "Something went wrong. Please try again.");
                }
              }).onError((error, stackTrace) {
                print("Error:$error");
                print("StackTrace:$stackTrace");
                if (error.toString().contains("already bonded")) {
                  print("Bonded:${result.device.bondState}");
                  EasyLoading.show(status: 'Connected. Communicating...');
                  setState(() {
                    results[results.indexOf(result)] = BluetoothDiscoveryResult(
                        device: BluetoothDevice(
                            name: device.name ?? '',
                            address: address,
                            type: device.type,
                            bondState: BluetoothBondState.bonded),
                        rssi: result.rssi);
                  });
                  tryEstablishLink(result);
                } else {
                  print("Not Bonded");
                  EasyLoading.showError(
                      "Something went wrong. Please try again.");
                }
              });
              // Navigator.of(context).pop(result.device);
            },
            onLongPress: () async {
              try {} catch (ex) {
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
  }

  Future<void> tryEstablishLink(BluetoothDiscoveryResult result) async {
    if (_connection != null && _connection?.isConnected == true) {
      print("COnnection still active");
      EasyLoading.dismiss();
      scanForWifiNetworks();
      return;
    }
    BluetoothConnection.toAddress(result.device.address).then((connection) {
      _connection = connection;
      print('Connected to the device ${result.device.bondState}');
      connection.input?.listen((Uint8List data) {
        String received = ascii.decode(data);
        print('Data incoming: $received');
        if(received.contains("Hostname")){
          EasyLoading.show(status: "Hostname received. Adding device to dashboard...");
          addDeviceToDashboard(received);
        }
        // connection.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
          connection.finish(); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
      Future.delayed(Duration(seconds: 1), () {
        if (connection.isConnected) {
          EasyLoading.showSuccess("Link established");
          scanForWifiNetworks();
        } else {
          EasyLoading.showError("Could not establish link. Please try again.");
        }
      });
    }).catchError((error) {
      EasyLoading.showError("Could not establish link. Please try again.");
      print('Cannot connect, exception occured');
      print(error);
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
          print('Scan result: $accessPoints');
          //show access points in a dialog list
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: const Text('Wifi networks'),
                  content: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: accessPoints?.length,
                      itemBuilder: (BuildContext context, int index) {
                        final accessPoint = accessPoints![index];
                        return ListTile(
                          title: Text(accessPoint.ssid),
                          subtitle: Text(accessPoint.bssid),
                          onTap: () {
                            Navigator.of(context).pop();
                            _selectedWifiNetwork = accessPoint;
                            getWifiPassword(accessPoint);
                          },
                        );
                      },
                    )),
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
      }
    } else {
      // fallback mechanism, like - show user that "scan" is not possible
    }
  }

  void getWifiPassword(WiFiAccessPoint accessPoint) {
    //show password dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter password'),
          content: TextField(
            obscureText: true,
            onChanged: (String value) {
              _password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Send to device"),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show(status: 'Sending password...');
                if (_connection != null) {
                  String message =
                      'ssid "${_selectedWifiNetwork?.ssid}" password "$_password"';
                  _connection?.output.add(ascii.encode(message));
                  EasyLoading.showSuccess("Password sent");
                  Future.delayed(Duration(seconds: 1), () {
                    setUpSensorName();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void setUpSensorName() {
    //show sensor name dialog
String sensorName = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Sensor name'),
          content: TextField(
            obscureText: true,
            onChanged: (String value) {
              sensorName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Send to device"),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show(status: 'Sending Sensor name...');
                if (_connection != null) {
                  String message =
                      'sensorname "$sensorName"';
                  _connection?.output.add(ascii.encode(message));
                  EasyLoading.showSuccess("Sensor name sent");
                  Future.delayed(Duration(seconds: 1), () {
                    setUpSensorLocation();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void setUpSensorLocation() {
    String sensorLocation = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Sensor location'),
          content: TextField(
            obscureText: true,
            onChanged: (String value) {
              sensorLocation = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Send to device"),
              onPressed: () {
                Navigator.of(context).pop();
                EasyLoading.show(status: 'Sending Sensor location...');
                if (_connection != null) {
                  String message =
                      'sensorlocation "$sensorLocation"';
                  _connection?.output.add(ascii.encode(message));
                  EasyLoading.showSuccess("Sensor location sent");
                  Future.delayed(Duration(seconds: 1), () {
                    // setUpSensorLocation();
                  });
                }
              },
            ),
          ],
        );
      },
    );}

  void addDeviceToDashboard(String received) {
    String hostname = received.trim().split(' ')[1];
    NetworkRequests().saveDevice(hostname)
                        .then((value) async {
                      EasyLoading.dismiss();
                      if (value.success == true) {
                        print("Adding to firebase:");
                        await FirebaseMessaging.instance
                            .subscribeToTopic("host_" + hostname);
                        EasyLoading.showSuccess('Device added');
                        Future.delayed(Duration(seconds: 1), () {
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
}
