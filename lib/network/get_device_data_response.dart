import 'dart:ui';

import 'package:syncfusion_flutter_charts/charts.dart';

class GetDeviceDataResponse {
  bool? success;
  List<Records>? data;

  GetDeviceDataResponse({this.success, this.data});

  GetDeviceDataResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Records>[];
      json['data'].forEach((v) {
        data!.add(new Records.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Records {
  int? id;
  int? deviceId;
  String? sensor;
  String? location;
  num? temperature;
  num? humidity;
  num? moisture;
  num? vpd;
  String? readAt;
  String? createdAt;
  String? updatedAt;
  String? image;

  Records(
      {this.id,
      this.deviceId,
      this.sensor,
      this.location,
      this.temperature,
      this.humidity,
      this.moisture,
      this.vpd,
      this.readAt,
      this.createdAt,
      this.updatedAt,
      this.image});

  Records.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceId = json['device_id'];
    sensor = json['sensor'];
    location = json['location'];
    temperature = json['temperature'];
    humidity = json['humidity'];
    moisture = json['moisture'];
    vpd = json['vpd'];
    readAt = json['read_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['device_id'] = this.deviceId;
    data['sensor'] = this.sensor;
    data['location'] = this.location;
    data['temperature'] = this.temperature;
    data['humidity'] = this.humidity;
    data['moisture'] = this.moisture;
    data['vpd'] = this.vpd;
    data['read_at'] = this.readAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['image'] = this.image;
    return data;
  }

  DateTime getGraphTime() {
    // print(createdAt!);
    print(DateTime.parse(createdAt!).toIso8601String());

    String isoString = DateTime.parse(createdAt!)
        .toIso8601String(); // say "2020-08-20 01:30:00.000Z" in ISO8601 format.

    // On conversion, changes to "2020-08-20 01:30:00.000"

    String convertedString = isoString.replaceAll(RegExp(r'Z'), '');
    convertedString = convertedString.replaceAll('T', ' ');
    convertedString = convertedString.replaceAll('.000', '');
    print(convertedString);
    // The converted timestamp string is then parsed to DateTime type and returned

    // toxValueMapper

    DateTime correctTime = DateTime.parse(convertedString);

    return correctTime; //returned the CorrectTimestamp
    return DateTime.parse(createdAt!);
    // return DateTime.parse(createdAt!).hour.toString()+":"+DateTime.parse(createdAt!).minute.toString();
    // return DateTime.parse(createdAt!).month.toString()+"/"+DateTime.parse(createdAt!).day.toString()+"/"+DateTime.parse(createdAt!).year.toString()+"-"+DateTime.parse(createdAt!).hour.toString()+":"+DateTime.parse(createdAt!).minute.toString()+":"+DateTime.parse(createdAt!).second.toString();
    // return DateTime.parse(createdAt!).day.toString() + ", " + DateTime.parse(createdAt!).hour.toString() + ":" + DateTime.parse(createdAt!).minute.toString();
  }
}

class ChartData {
  List<Records>? deviceRecords;

  ChartData({this.deviceRecords});

  List<SplineSeries<Records, DateTime>>? getSpineTempData() {
    return <SplineSeries<Records, DateTime>>[
      SplineSeries<Records, DateTime>(
        dataSource: deviceRecords!,
        xValueMapper: (Records d, _) => d.getGraphTime(),
        yValueMapper: (Records d, _) => d.temperature ?? 0,
        sortFieldValueMapper: (Records d, _) => d.createdAt,
        sortingOrder: SortingOrder.ascending,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'Temp',
      ),
    ];
  }

  List<SplineSeries<Records, DateTime>>? getSpineMoistureData() {
    return <SplineSeries<Records, DateTime>>[
      SplineSeries<Records, DateTime>(
        dataSource: deviceRecords!,
        xValueMapper: (Records d, _) => d.getGraphTime(),
        yValueMapper: (Records d, _) => d.moisture ?? 0,
        sortFieldValueMapper: (Records d, _) => d.createdAt,
        sortingOrder: SortingOrder.ascending,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'Moisture',
      ),
    ];
  }

  List<SplineSeries<Records, DateTime>>? getSpineVpdData() {
    return <SplineSeries<Records, DateTime>>[
      SplineSeries<Records, DateTime>(
        dataSource: deviceRecords!,
        xValueMapper: (Records d, _) => d.getGraphTime(),
        yValueMapper: (Records d, _) => d.vpd ?? 0,
        sortFieldValueMapper: (Records d, _) => d.createdAt,
        sortingOrder: SortingOrder.ascending,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'VPD',
      ),
    ];
  }

  List<AreaSeries<Records, DateTime>>? getAreaHumidData() {
    // <ChartSeries<_ChartData, String>>[
    //   AreaSeries<_ChartData, String>(
    //       dataSource: data,
    //       xValueMapper: (_ChartData data, _) => data.x,
    //       yValueMapper: (_ChartData data, _) => data.y,
    //       name: 'Gold',
    //       color: Color.fromRGBO(8, 142, 255, 1))
    // ];
    return <AreaSeries<Records, DateTime>>[
      AreaSeries<Records, DateTime>(
        dataSource: deviceRecords!,
        xValueMapper: (Records d, _) => d.getGraphTime(),
        yValueMapper: (Records d, _) => d.humidity ?? 0,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'Humidity',
        legendItemText: 'Humidity',
      ),
    ];
  }
}
