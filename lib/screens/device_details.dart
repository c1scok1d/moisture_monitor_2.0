import 'package:flutter/material.dart';
import 'package:rodland_farms/data/device_record.dart';

class DeviceDetailsScreen extends StatefulWidget {
  late DeviceRecord deviceRecord;

  DeviceDetailsScreen(this.deviceRecord);

  @override
  _DeviceDetailsScreenState createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceRecord.name!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text('Device Details'),
      ),
    );
  }
}