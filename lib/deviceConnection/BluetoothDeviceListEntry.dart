import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    required ScanResult device,
    int? rssi,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool enabled = true,
  }) : super(
    onTap: onTap,
    onLongPress: onLongPress,
    enabled: enabled,
    leading:
    Icon(Icons.devices), // @TODO . !BluetoothClass! class aware icon
    title: Text(device.device.name?? ""),
    subtitle: Text(device.device.id.id.toString()),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        rssi != null
            ? Container(
          margin: new EdgeInsets.all(8.0),
          child: DefaultTextStyle(
            style: _computeTextStyle(rssi),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(rssi.toString()),
                Text('dBm'),
              ],
            ),
          ),
        )
            : Container(width: 0, height: 0),
        device.advertisementData.connectable
            ?

        StreamBuilder<BluetoothDeviceState>(
          stream: device.device.state,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothDeviceState.connected) {
              return IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  device.device.disconnect();
                },
              );
            } else if (state == BluetoothDeviceState.connecting) {
              return IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  device.device.disconnect();
                },
              );
            } else {
              return IconButton(
                icon: Icon(Icons.bluetooth_disabled, color: Colors.green),
                onPressed: () {
                  device.device.connect().then((value) => {
                    print('Connected to ${device.device.name}')

                  }).catchError((error) => {
                    print('Failed to connect to ${device.device.name}')
                  });
                },
              );
            }


        },): Icon(Icons.bluetooth_disabled, color: Colors.grey),
        // device.isConnected
        //     ? Icon(Icons.import_export)
        //     : Container(width: 0, height: 0),
        // device.isBonded
        //     ? Icon(Icons.link)
        //     : Container(width: 0, height: 0),
      ],
    ),
  );

  static TextStyle _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35)
      return TextStyle(color: Colors.greenAccent[700]);
    else if (rssi >= -45)
      return TextStyle(
          color: Color.lerp(
              Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
    else if (rssi >= -55)
      return TextStyle(
          color: Color.lerp(
              Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
    else if (rssi >= -65)
      return TextStyle(
          color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
    else if (rssi >= -75)
      return TextStyle(
          color: Color.lerp(
              Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
    else if (rssi >= -85)
      return TextStyle(
          color: Color.lerp(
              Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
    else
      /*code symmetry*/
      return TextStyle(color: Colors.redAccent);
  }
}