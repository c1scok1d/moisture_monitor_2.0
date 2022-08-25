import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:wifi_scan/wifi_scan.dart';


class ESPBLE {
  final flutterReactiveBle = FlutterReactiveBle();

  DiscoveredDevice? espDevice;
  final deviceGATTserviceUUID =
      Uuid.parse('021A9004-0382-4AEA-BFF4-6B3F1C5ADFB4');
  final deviceGATTInfoCharUUID =
      Uuid.parse('021AFF53-0382-4AEA-BFF4-6B3F1C5ADFB4');
  final deviceGATTCustomDataCharUUID =
      Uuid.parse('021AFF55-0382-4AEA-BFF4-6B3F1C5ADFB4');
  final deviceGATTProvConfigCharUUID =
      Uuid.parse('021AFF52-0382-4AEA-BFF4-6B3F1C5ADFB4');

  final applyConfigData = Uint8List.fromList([0x08, 0x04, 0x72, 0x00]);
  final startOfConfig = Uint8List.fromList([0x52, 0x03, 0xA2, 0x01, 0x00]);

  static final ESPBLE _singleton = ESPBLE._internal();

  bool isScanning = false;
  bool isConnecting = false;
  String _deviceName = "NULL";
  String _deviceLocation = "NULL";
  String _ssid = "networkSSID";
  String _password = "networkPassword";

  factory ESPBLE() {
    return _singleton;
  }
  ESPBLE._internal();

  Uint8List _getWiFiConfigDataToWrite() {
    //add actual wifi config. hope u don't mind me seeinf the wifi password. to se if it's connecting to wifi
    final ssid = _ssid.codeUnits;
    final password = _password.codeUnits;
    final startHeader = [0x08, 0x02, 0x62];
    const configStartByte = 0x0A;
    final ssidLength = ssid.length;
    final passwordLength = password.length;
    final payloadSize = [(ssidLength + passwordLength + 0x04)];
    const ssidPasswordSeperatorByte = 0x12;

    final configDataToWrite = Uint8List.fromList(startHeader +
        payloadSize +
        [configStartByte] +
        [ssidLength] +
        ssid +
        [ssidPasswordSeperatorByte] +
        [passwordLength] +
        password);

    return configDataToWrite;
  }

  void scanForESPDevice(String deviceName, String deviceLocation, String network, String password) {
    _deviceName = deviceName;
    _deviceLocation = deviceLocation;
    _ssid = network;
    _password = password;
    if (espDevice == null) {
      StreamSubscription<BleStatus>? statusStreamSubscirption;
      StreamSubscription<DiscoveredDevice>? scanStream;
      statusStreamSubscirption =
          flutterReactiveBle.statusStream.listen((status) async {
            // @TODO: if ble is not ready make ble ready
        if (status == BleStatus.ready) {
          await statusStreamSubscirption?.cancel();

          scanStream = flutterReactiveBle.scanForDevices(
              withServices: [deviceGATTserviceUUID],
              scanMode: ScanMode.lowLatency).listen((device) async {
            await scanStream?.cancel();
            espDevice = device;
            connectToDevice();
          });
        }
      });
    } else {
      connectToDevice();
    }
  }

  void connectToDevice() {
    if (isConnecting) {
      return;
    }

    isConnecting = true;
    StreamSubscription<ConnectionStateUpdate>? connectionStateStream;
    connectionStateStream =
        flutterReactiveBle.connectToDevice(id: espDevice!.id).listen((event) async{
      if (kDebugMode) {
        print(event);
      }
      if(event.connectionState == DeviceConnectionState.connected) {
        isConnecting = false;
      final infoCharacteristic = QualifiedCharacteristic(
          serviceId: deviceGATTserviceUUID,
          characteristicId: deviceGATTInfoCharUUID,
          deviceId: espDevice!.id);
      await flutterReactiveBle.writeCharacteristicWithResponse(infoCharacteristic,
          value: Uint8List.fromList('ESP'.codeUnits));
      final info = await flutterReactiveBle.readCharacteristic(infoCharacteristic);
      if (kDebugMode) {
        print(String.fromCharCodes(info));
      }
      final provConfigCharacteristic = QualifiedCharacteristic(
          serviceId: deviceGATTserviceUUID,
          characteristicId: deviceGATTProvConfigCharUUID,
          deviceId: espDevice!.id);

        await flutterReactiveBle.writeCharacteristicWithResponse(provConfigCharacteristic, value: startOfConfig);
        final readconfChar = await flutterReactiveBle.readCharacteristic(provConfigCharacteristic);
        if (kDebugMode) {
          print(readconfChar);
        }
        await Future.delayed(const Duration(seconds: 1));

        final customDataCharacteristic = QualifiedCharacteristic(
          serviceId: deviceGATTserviceUUID,
          characteristicId: deviceGATTCustomDataCharUUID,
          deviceId: espDevice!.id);

        //String name = "testDevice", location = "testLocation";
        await flutterReactiveBle.writeCharacteristicWithResponse(customDataCharacteristic, value: Uint8List.fromList("{\"name\":\"$_deviceName\",\"location\":\"$_deviceLocation\"}".codeUnits));
        await Future.delayed(const Duration(seconds: 2));
        await flutterReactiveBle.writeCharacteristicWithResponse(provConfigCharacteristic, value: _getWiFiConfigDataToWrite());
        final readconfChar2 = await flutterReactiveBle.readCharacteristic(provConfigCharacteristic);
        if (kDebugMode) {
          print(readconfChar2);
        }


        await flutterReactiveBle.writeCharacteristicWithResponse(provConfigCharacteristic, value: applyConfigData);
        await Future.delayed(const Duration(seconds: 1));
      

      }
    }, onDone: () {
      if (kDebugMode) {
        print('connected');
      }
          }, onError: (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      isConnecting = false;
    });
  }
}
