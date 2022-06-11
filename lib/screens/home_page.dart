import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rodland_farms/data/device_record.dart';
import 'package:rodland_farms/data/dummy.dart';
import 'package:rodland_farms/network/get_device_data_response.dart';
import 'package:rodland_farms/network/network_requests.dart';
import 'package:rodland_farms/screens/authentication/register.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../network/get_user_devices_response.dart';
import 'device_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.id}) : super(key: key);
  final String? id;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _devices=NetworkRequests().getUserDevices();

  @override
  Widget build(BuildContext context) {
    print("HomePage: ${widget.id}");
    return Scaffold(
      body: Container(
        color: Colors.white,
        child:
        SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const SizedBox(height: 40),
          Stack(
            children: [
              Center(
                child: const CircleAvatar(
                  radius: 50,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 20, top: 20),
                  child: GestureDetector(
                    onTap: () async {
                      //logout()
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.logout,
                      size: 30,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Hello Rodland Farmer,\nWelcome to your dashboard",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.grey[200],
            height: MediaQuery.of(context).size.height - 250,
            child: FutureBuilder<GetUserDeviceResponse>(
              future: _devices,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data?.devices?.isEmpty == true) {
                    return Center(
                      child: const Text(
                        "You have no devices",
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data?.devices?.length ?? 0,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      print("List<String>:" + snapshot.connectionState.name);
                      if (snapshot.hasData) {
                        Devices device = snapshot.data!.devices![index];
                        return Container(
                            height: 130,
                            child: Card(
                              child: FutureBuilder<GetDeviceDataResponse>(
                                  future: NetworkRequests()
                                      .getLatestDeviceData(device.hostname!),
                                  builder: (context, snapshot) {
                                    print("DeviceRecord:" +
                                        snapshot.connectionState.name);
                                    if (snapshot.hasData) {
                                      if (snapshot.data?.data?.isEmpty ==
                                          true) {
                                        return Center(
                                          child: const Text(
                                            "No data available",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        );
                                      }

                                      Records record = snapshot.data!.data![0];

                                      print("ID${record.id}");
                                      print("Location${record.location}");
                                      return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DeviceDetailsScreen(
                                                            device)));
                                          },
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 120,
                                                  child: SfRadialGauge(axes: <
                                                      RadialAxis>[
                                                    RadialAxis(
                                                        minimum: -58,
                                                        maximum: 134,
                                                        ranges: <GaugeRange>[
                                                          GaugeRange(
                                                              startValue: -58,
                                                              endValue: 6,
                                                              color: Colors
                                                                  .orange),
                                                          GaugeRange(
                                                              startValue: 6,
                                                              endValue: 70,
                                                              color:
                                                                  Colors.green),
                                                          GaugeRange(
                                                              startValue: 70,
                                                              endValue: 134,
                                                              color: Colors.red)
                                                        ],
                                                        pointers: <
                                                            GaugePointer>[
                                                          NeedlePointer(
                                                            value: record
                                                                    .temperature
                                                                    ?.toDouble() ??
                                                                0,
                                                            needleEndWidth: 3,
                                                          )
                                                        ],
                                                        annotations: <
                                                            GaugeAnnotation>[
                                                          GaugeAnnotation(
                                                              widget: Container(
                                                                  child: Text(
                                                                      '${record.temperature}°F',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .bold))),
                                                              angle: 90,
                                                              positionFactor:
                                                                  0.7)
                                                        ]),
                                                  ]),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text(
                                                      'Sensor:  ${record.sensor}',
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      '${record.temperature}°F',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Text.rich(
                                                      TextSpan(
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                        children: [
                                                          const WidgetSpan(
                                                            child: Icon(Icons
                                                                .location_on_outlined),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                '${record.location}',
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      '${timeago.format(DateTime.parse(record.createdAt!))}',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                )
                                              ]));
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                  }),
                            ));
                      } else {
                        print("No data");
                        return Container();
                      }
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var _controller=TextEditingController();
          //create dialog
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Add Device"),
                  content: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        labelText: "Hostname",
                        hintText: "Enter device name",
                        border: OutlineInputBorder()),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Add"),
                      onPressed: () {
                        if (_controller.text.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content: Text("Hostname cannot be empty"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("Ok"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        } else {
                          Navigator.of(context).pop();
                          EasyLoading.show(status: 'Adding device...');
                          NetworkRequests().saveDevice(_controller.text).then(
                              (value) async {
                            EasyLoading.dismiss();
                            if (value.success == true) {
                              print("Adding to firebase:");
                              await FirebaseMessaging.instance.subscribeToTopic("host_"+_controller.text);
                              EasyLoading.showSuccess('Device added');
                              setState(() {
                                _devices=NetworkRequests().getUserDevices();
                              });
                            } else {
                              EasyLoading.showError('Error adding device');
                            }
                          }).catchError((error) {
                            EasyLoading.dismiss();
                            EasyLoading.showError('Error adding device');
                          });

                        }
                      },
                    )
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
