import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rodland_farms/network/get_user_devices_response.dart';
import 'package:rodland_farms/network/save_device_response.dart';
import 'package:rodland_farms/network/save_user_response.dart';
import 'package:http/http.dart' as http;

import 'get_device_data_response.dart';

class NetworkRequests {
  String base = "https://athome.rodlandfarms.com";
  String baseUrl = "https://athome.rodlandfarms.com/api";
  Future<String?> apiToken = FlutterSecureStorage().read(key: 'api_token');

  NetworkRequests();

  Future<SaveUserResponse> saveUser(String login_token) async {
    final response = await http.post(Uri.parse(base + "/user/save"),
        body: {"login_token": login_token});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return SaveUserResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return SaveUserResponse(
        success: false,
        apiToken: response.body,
      );
    }
  }

  Future<GetUserDeviceResponse> getUserDevices() async {
    String? apiToken = await FlutterSecureStorage().read(key: 'api_token');
    final response = await http
        .get(Uri.parse(baseUrl + "/user/devices?api_token=" + apiToken!));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return GetUserDeviceResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return GetUserDeviceResponse(
        success: false,
        devices: [],
      );
    }
  }

  Future<GetDeviceDataResponse> getLatestDeviceData(String hostname) async {
    String? apiToken = await FlutterSecureStorage().read(key: 'api_token');
    final response = await http.get(Uri.parse(
        baseUrl + "/user/" + hostname + "/latest?api_token=" + apiToken!));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return GetDeviceDataResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return GetDeviceDataResponse(
        success: false,
        data: [],
      );
    }
  }

  Future<GetDeviceDataResponse> getFullDeviceData(String hostname) async {
    // await Future.delayed(Duration(seconds: 100));
    String? apiToken = await FlutterSecureStorage().read(key: 'api_token');
    final response = await http.get(Uri.parse(baseUrl +
        "/user/devices/" +
        hostname +
        "/data?api_token=" +
        apiToken!));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return GetDeviceDataResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return GetDeviceDataResponse(
        success: false,
        data: [],
      );
    }
  }

  Future<SaveDeviceResponse> saveDevice(String hostname) async {
    String? apiToken = await FlutterSecureStorage().read(key: 'api_token');
    final response = await http.post(Uri.parse(
        baseUrl + "/user/save/" + hostname + "?api_token=" + apiToken!));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return SaveDeviceResponse.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return SaveDeviceResponse(
        success: false,
        message: "could not save device",
      );
    }
  }
}
