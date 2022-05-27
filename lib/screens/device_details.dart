import 'package:flutter/material.dart';
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
      body: SingleChildScrollView(
        child: FutureBuilder<GetDeviceDataResponse>(
          future: NetworkRequests().getFullDeviceData(widget.deviceRecord.hostname!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      title:
                      ChartTitle(text: 'Temp of ${widget.deviceRecord.hostname}'),
                      legend: Legend(isVisible: true),
                      primaryXAxis: CategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                          labelPlacement: LabelPlacement.onTicks),
                      primaryYAxis: NumericAxis(
                          minimum: 30,
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
                      title:
                      ChartTitle(text: 'Humidity of ${widget.deviceRecord.hostname}'),
                      legend: Legend(isVisible: true),
                      primaryXAxis: CategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                          labelPlacement: LabelPlacement.onTicks),
                      primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: 100,
                          axisLine: const AxisLine(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          labelFormat: '{value}%',
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: ChartData(deviceRecords: snapshot.data?.data!)
                          .getAreaHumidData(),
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                  Card(
                      margin: const EdgeInsets.all(8),
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: ChartData(deviceRecords: snapshot.data?.data!)
                            .getAreaHumidData(),)
                  )

                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
