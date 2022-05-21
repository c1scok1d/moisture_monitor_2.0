import 'package:flutter/material.dart';
import 'package:rodland_farms/data/device_record.dart';
import 'package:rodland_farms/data/dummy.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'device_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.id}) : super(key: key);
  final String? id;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    print("HomePage: ${widget.id}");
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Hello Rodland Farmer,\nWelcome to your dashboard",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal,
              ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.grey[200],
            height: MediaQuery.of(context).size.height - 250,
            child: FutureBuilder<List<String>>(
              future: Dummy().getDevices(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      print("List<String>:" + snapshot.connectionState.name);
                      if (snapshot.hasData) {
                        String device = snapshot.data![index];
                        return Container(
                            height: 130,
                            child: Card(
                              child: FutureBuilder<DeviceRecord>(
                                  future: Dummy().mostRecentReading(device),
                                  builder: (context, snapshot) {
                                    print("DeviceRecord:" +
                                        snapshot.connectionState.name);
                                    if (snapshot.hasData) {
                                      DeviceRecord record = snapshot.data!;
                                      print("ID${record.id}");
                                      print("Location${record.location}");
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context) =>
                                                  DeviceDetailsScreen(record)));
                                        },
                                        child:Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child:
                                              SfRadialGauge(axes: <RadialAxis>[
                                                RadialAxis(
                                                    minimum: -58,
                                                    maximum: 134,
                                                    ranges: <GaugeRange>[
                                                      GaugeRange(
                                                          startValue: -58,
                                                          endValue: 6,
                                                          color: Colors.orange),
                                                      GaugeRange(
                                                          startValue: 6,
                                                          endValue: 70,
                                                          color: Colors.green),
                                                      GaugeRange(
                                                          startValue: 70,
                                                          endValue: 134,
                                                          color: Colors.red)
                                                    ],
                                                    pointers: <GaugePointer>[
                                                      NeedlePointer(
                                                        value: double.parse(
                                                            record.temp!),
                                                        needleEndWidth: 3,
                                                      )
                                                    ],
                                                    annotations: <GaugeAnnotation>[
                                                      GaugeAnnotation(
                                                          widget: Container(
                                                              child: Text(
                                                                  '${record.temp}°F',
                                                                  style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold))),
                                                          angle: 90,
                                                          positionFactor: 0.7)
                                                    ]),
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  'Sensor:  ${record.sensor}',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  '${record.temp}°F',
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
                                                        text: '${record.location}',
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  '${timeago.format(DateTime.parse(record.readingTime!))}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold),
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
    ) ;

  }
}
