import 'package:flutter/material.dart';
import 'package:rodland_farms/data/device_record.dart';
import 'package:rodland_farms/data/dummy.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DeviceDetailsScreen extends StatefulWidget {
  late DeviceRecord deviceRecord;

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
        title: Text(widget.deviceRecord.name!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<DeviceRecord>>(
        future: Dummy().getRecords(widget.deviceRecord.name!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(8),
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    title:
                    ChartTitle(text: 'Temp of ${widget.deviceRecord.name}'),
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
                    series: ChartData(deviceRecords: snapshot.data!)
                        .getSpineTempData(),
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                )

              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
