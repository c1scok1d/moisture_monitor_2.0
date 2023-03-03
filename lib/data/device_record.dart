
class DeviceRecord{
  String? id;
  String? sensor;
  String? location;
  String? temp;
  String? humid;
  String? moisture;
  String? readingTime;
  String? name;
  String? batt;



  DeviceRecord(
      {this.id,
        this.sensor,
        this.location,
        this.temp,
        this.humid,
        this.moisture,
        this.readingTime,
        this.batt});

  DeviceRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sensor = json['sensor'];
    location = json['location'];
    temp = json['temp'];
    humid = json['humid'];
    moisture = json['moisture'];
    readingTime = json['reading_time'];
    batt = json['batt'];
  }

  String getGraphTime(){
    return "${DateTime.parse(readingTime!).day}, ${DateTime.parse(readingTime!).hour}:${DateTime.parse(readingTime!).minute}";
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
    data['batt'] = batt;
    return data;
  }
}
