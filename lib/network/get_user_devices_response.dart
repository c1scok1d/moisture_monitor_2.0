class GetUserDeviceResponse {
  bool? success;
  List<Devices>? devices;

  GetUserDeviceResponse({this.success, this.devices});

  GetUserDeviceResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['devices'] != null) {
      devices = <Devices>[];
      json['devices'].forEach((v) {
        devices!.add(new Devices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.devices != null) {
      data['devices'] = this.devices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Devices {
  int? id;
  int? userId;
  String? hostname;
  String? createdAt;
  String? updatedAt;

  Devices(
      {this.id, this.userId, this.hostname, this.createdAt, this.updatedAt});

  Devices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    hostname = json['hostname'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['hostname'] = this.hostname;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
