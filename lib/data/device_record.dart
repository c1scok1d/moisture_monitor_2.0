
class DeviceRecord{
  String? id;
  String? sensor;
  String? location;
  String? temp;
  String? humid;
  String? moisture;
  String? readingTime;
  String? name;



  DeviceRecord(
      {this.id,
        this.sensor,
        this.location,
        this.temp,
        this.humid,
        this.moisture,
        this.readingTime});

  DeviceRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sensor = json['sensor'];
    location = json['location'];
    temp = json['temp'];
    humid = json['humid'];
    moisture = json['moisture'];
    readingTime = json['reading_time'];
  }

  String getGraphTime(){
    return DateTime.parse(readingTime!).day.toString() + ", " + DateTime.parse(readingTime!).hour.toString() + ":" + DateTime.parse(readingTime!).minute.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sensor'] = sensor;
    data['location'] = location;
    data['temp'] = temp;
    data['humid'] = humid;
    data['moisture'] = moisture;
    data['reading_time'] = readingTime;
    return data;
  }
}
