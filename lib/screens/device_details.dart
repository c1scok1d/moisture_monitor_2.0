
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rodland_farms/network/get_device_data_response.dart';
import 'package:rodland_farms/network/network_requests.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../network/get_user_devices_response.dart';

class DeviceDetailsScreen extends StatefulWidget {
  late Devices deviceRecord;
  String sensorName;

  DeviceDetailsScreen(this.deviceRecord,this.sensorName);

  @override
  _DeviceDetailsScreenState createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  late ZoomPanBehavior _zoom1Behavior;
  late ZoomPanBehavior _zoom2Behavior;
  late ZoomPanBehavior _zoom3Behavior;
  @override
  initState() {
    _zoom1Behavior=ZoomPanBehavior(
        enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    _zoom2Behavior=ZoomPanBehavior(
        enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    _zoom3Behavior=ZoomPanBehavior(
        enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sensorName),
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
                    Visibility(
                      visible: snapshot.data?.data != null &&
                          snapshot.data?.data?.isNotEmpty == true &&
                          snapshot.data?.data![0].moisture != 0,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: SfCartesianChart(
                          zoomPanBehavior: _zoom1Behavior,

                          plotAreaBorderWidth: 0,
                          title: ChartTitle(text: 'Moisture'),
                          legend: Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              overflowMode: LegendItemOverflowMode.scroll),
                          primaryXAxis: DateTimeCategoryAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              dateFormat: DateFormat('h:mm a'),
                              ),
                          primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: 100,
                              axisLine: const AxisLine(width: 0),
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              labelFormat: '{value}%',
                              majorTickLines: const MajorTickLines(size: 0)),
                          series: ChartData(deviceRecords: snapshot.data?.data!)
                              .getAreaMoistureData(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
                    ),//Moisture Chart
                    Visibility(
                      visible: snapshot.data?.data != null &&
                          snapshot.data?.data?.isNotEmpty == true &&
                          snapshot.data?.data![0].humidity != 0,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: SfCartesianChart(
                          zoomPanBehavior: _zoom2Behavior,
                          onZoomEnd: (ZoomPanArgs args) {
                            print("currentZoomFactor"+args.currentZoomFactor.toString());
                          },
                          plotAreaBorderWidth: 0,
                          title: ChartTitle(text: 'Humidity and Temperature'),
                          legend: Legend(
                              isVisible: true, position: LegendPosition.bottom),
                          primaryXAxis: DateTimeCategoryAxis(
                            majorGridLines: const MajorGridLines(width: 0.9),
                            dateFormat: DateFormat('h:mm a'),
                          ),
                          primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: 100,
                              axisLine: const AxisLine(width: 0),
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              labelFormat: '{value}',
                              majorTickLines: const MajorTickLines(size: 0.9)),
                          series: ChartData(deviceRecords: snapshot.data?.data!)
                              .getAreaHumidAndTempData(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
                    ),//Temp and humidity chart
                    Visibility(
                      visible: snapshot.data?.data != null &&
                          snapshot.data?.data?.isNotEmpty == true &&
                          snapshot.data?.data![0].vpd != 0,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: SfCartesianChart(
                          zoomPanBehavior: _zoom3Behavior,
                          plotAreaBorderWidth: 0,
                          title: ChartTitle(text: 'VPD'),
                          legend: Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              overflowMode: LegendItemOverflowMode.scroll),
                          primaryXAxis: DateTimeCategoryAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            dateFormat: DateFormat('h:mm a'),
                          ),
                          primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: 3,
                              axisLine: const AxisLine(width: 0),
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              // labelFormat: '{value}°F',
                              majorTickLines: const MajorTickLines(size: 0)),
                          series: ChartData(deviceRecords: snapshot.data?.data!)
                              .getSpineVpdData(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: snapshot.data?.data != null &&
                          snapshot.data?.data?.isNotEmpty == true &&
                          snapshot.data?.data![0].batt != 0,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: SfCartesianChart(
                          zoomPanBehavior: _zoom1Behavior,

                          plotAreaBorderWidth: 0,
                          title: ChartTitle(text: 'Battery'),
                          legend: Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              overflowMode: LegendItemOverflowMode.scroll),
                          primaryXAxis: DateTimeCategoryAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            dateFormat: DateFormat('h:mm a'),
                          ),
                          primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: 100,
                              axisLine: const AxisLine(width: 0),
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              labelFormat: '{value}%',
                              majorTickLines: const MajorTickLines(size: 0)),
                          series: ChartData(deviceRecords: snapshot.data?.data!)
                              .getAreaBattData(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
                    ),//vpd chart
                  ],
                );
              } else {
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(child: CircularProgressIndicator()));
              }
            },
          ),
        ),
      ),
    );
  }
}
