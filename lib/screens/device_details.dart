import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rodland_farms/data/device_record.dart';
import 'package:rodland_farms/data/dummy.dart';
import 'package:rodland_farms/network/get_device_data_response.dart';
import 'package:rodland_farms/network/network_requests.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../network/get_user_devices_response.dart';

class DeviceDetailsScreen extends StatefulWidget {
  late Devices deviceRecord;

  DeviceDetailsScreen(this.deviceRecord);

  @override
  _DeviceDetailsScreenState createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceRecord.hostname!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: FutureBuilder<GetDeviceDataResponse>(
            future: NetworkRequests()
                .getFullDeviceData(widget.deviceRecord.hostname!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data?.data.toString());
                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8),
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        title: ChartTitle(
                            text: 'Temp of ${widget.deviceRecord.hostname}'),
                        legend: Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.scroll),
                        primaryXAxis: DateTimeCategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                          dateFormat: DateFormat('h:mm a'),
                        ),
                        primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: 80,
                            axisLine: const AxisLine(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            labelFormat: '{value}°F',
                            majorTickLines: const MajorTickLines(size: 0)),
                        series: ChartData(deviceRecords: snapshot.data?.data!)
                            .getSpineTempData(),
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      margin: const EdgeInsets.all(8),
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        title: ChartTitle(
                            text:
                                'Humidity of ${widget.deviceRecord.hostname}'),
                        legend: Legend(isVisible: true),
                        primaryXAxis: DateTimeCategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                          dateFormat: DateFormat('h:mm a'),
                        ),
                        primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: (List.generate(
                                            snapshot.data?.data?.length ?? 0,
                                            (index) => snapshot.data?.data
                                                ?.elementAt(index)
                                                .humidity
                                                ?.toDouble()
                                                .round()).cast<num>().reduce(
                                            max) ??
                                        100)
                                    .toDouble() *
                                1.4,
                            axisLine: const AxisLine(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            labelFormat: '{value}%',
                            majorTickLines: const MajorTickLines(size: 0)),
                        series: ChartData(deviceRecords: snapshot.data?.data!)
                            .getAreaHumidData(),
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
