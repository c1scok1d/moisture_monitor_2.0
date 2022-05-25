import 'dart:convert';

import 'package:rodland_farms/network/save_device_response.dart';
import 'package:http/http.dart' as http;

class NetworkRequests {
  String base = "https://athome.rodlandfarms.com";
  String baseUrl = "https://athome.rodlandfarms.com/api/";
  NetworkRequests();

  Future<SaveDeviceResponse> saveDevice(String login_token) async {
    final response = await http
        .post(Uri.parse(base), body: {"login_token": login_token});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return SaveDeviceResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return SaveDeviceResponse(
        success: false,
        apiToken: '',
      );
    }
  }
}