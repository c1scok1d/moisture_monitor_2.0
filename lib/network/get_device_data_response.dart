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
  int? temperature;
  int? humidity;
  int? moisture;
  String? readAt;
  String? createdAt;
  String? updatedAt;

  Records(
      {this.id,
        this.deviceId,
        this.sensor,
        this.location,
        this.temperature,
        this.humidity,
        this.moisture,
        this.readAt,
        this.createdAt,
        this.updatedAt});

  Records.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceId = json['device_id'];
    sensor = json['sensor'];
    location = json['location'];
    temperature = json['temperature'];
    humidity = json['humidity'];
    moisture = json['moisture'];
    readAt = json['read_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    data['read_at'] = this.readAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
  String getGraphTime(){
    return DateTime.parse(createdAt!).hour.toString()+":"+DateTime.parse(createdAt!).minute.toString();
    // return DateTime.parse(createdAt!).month.toString()+"/"+DateTime.parse(createdAt!).day.toString()+"/"+DateTime.parse(createdAt!).year.toString()+"-"+DateTime.parse(createdAt!).hour.toString()+":"+DateTime.parse(createdAt!).minute.toString()+":"+DateTime.parse(createdAt!).second.toString();
    // return DateTime.parse(createdAt!).day.toString() + ", " + DateTime.parse(createdAt!).hour.toString() + ":" + DateTime.parse(createdAt!).minute.toString();
  }
}


class ChartData{
  List<Records>? deviceRecords;

  ChartData({this.deviceRecords});



  List<SplineSeries<Records, String>>? getSpineTempData(){
    return <SplineSeries<Records, String>>[
      SplineSeries<Records, String>(
        dataSource: deviceRecords!,
        xValueMapper: (Records d, _) => d.createdAt,
        yValueMapper: (Records d, _) => d.temperature??0,
        sortFieldValueMapper: (Records d, _) => d.createdAt,
        sortingOrder: SortingOrder.ascending,
        dataLabelMapper: (Records d, _) => d.createdAt,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'Temp',
      ),
    ];
  }

  List<AreaSeries<Records, String>>? getAreaHumidData(){
    // <ChartSeries<_ChartData, String>>[
    //   AreaSeries<_ChartData, String>(
    //       dataSource: data,
    //       xValueMapper: (_ChartData data, _) => data.x,
    //       yValueMapper: (_ChartData data, _) => data.y,
    //       name: 'Gold',
    //       color: Color.fromRGBO(8, 142, 255, 1))
    // ];
    return <AreaSeries<Records, String>>[
      AreaSeries<Records, String>(
        dataSource: deviceRecords!,
        xValueMapper: (Records d, _) => d.getGraphTime(),
        yValueMapper: (Records d, _) => d.humidity??0,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'Humidity',
      ),
    ];
  }

}