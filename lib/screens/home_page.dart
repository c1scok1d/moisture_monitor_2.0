import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rodland_farms/deviceConnection/ble_screen/ble_screen.dart';
import 'package:rodland_farms/network/get_device_data_response.dart';
import 'package:rodland_farms/network/images_response.dart';
import 'package:rodland_farms/network/network_requests.dart';
import 'package:rodland_farms/screens/authentication/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:battery_indicator/battery_indicator.dart';
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
  var _devices = NetworkRequests().getUserDevices();
  var name = "Rodland Farmers";
  var _profileImage = "";
  GlobalKey _one = GlobalKey();
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 7), () {
      // WidgetsBinding.instance.addPostFrameCallback(
      //         (_) => ShowCaseWidget.of(context)
      //         ?.startShowCase([_one]));
    });
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context)?.startShowCase([_one]));
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser?.displayName?.isNotEmpty == true) {
      var foo = (FirebaseAuth.instance.currentUser?.displayName)!.split(" ");
      name = foo[0].trim();
    }
    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser?.photoURL?.isNotEmpty == true) {
      _profileImage = (FirebaseAuth.instance.currentUser?.photoURL)!;
    }
    print("HomePage: ${widget.id}");
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(height: 40),
            Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.transparent,
                    child: Image.asset('assets/images/logo.png'),

                    /*backgroundImage: NetworkImage(_profileImage == ""
                        ? "https://www.shareicon.net/download/128x128//2016/07/26/802016_man_512x512.png"
                        : _profileImage),*/
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
            Text(
              "Hello $name,\nWelcome to your dashboard",
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
                        // print("List<String>:" + snapshot.connectionState.name);
                        if (snapshot.hasData) {
                          Devices device = snapshot.data!.devices![index];
                          return FutureBuilder<SharedPreferences>(
                              future: (SharedPreferences.getInstance()),
                              builder: (context, mData) {
                                // print('hasdata: ${mData.hasData},$index');
                                // print('IsFirstTime:${mData.data?.getBool('isFirstTime') != false}');
                                if (mData.hasData &&
                                    (mData.data?.getBool('isFirstTime') !=
                                        false) &&
                                    index == 0) {
                                  // print('Should show here');
                                  return Showcase(
                                    key: _one,
                                    title: 'Controls',
                                    description:
                                        'Long press to delete, press once to view details',
                                    blurValue: 1,
                                    child: Container(
                                        height: 100,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child:
                                              FutureBuilder<
                                                      GetDeviceDataResponse>(
                                                  future: NetworkRequests()
                                                      .getLatestDeviceData(
                                                          device.hostname!),
                                                  builder: (context, snapshot) {
                                                    print("DeviceRecord:" +
                                                        snapshot.connectionState
                                                            .name);
                                                    if (snapshot.hasData) {
                                                      if (snapshot.data?.data
                                                              ?.isEmpty ==
                                                          true) {
                                                        return Center(
                                                          child: const Text(
                                                            "No data available",
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          ),
                                                        );
                                                      }

                                                      Records record = snapshot
                                                          .data!.data![0];

                                                      // print("ID${record.id}");
                                                      // print("Location${record.image}");
                                                      return InkWell(
                                                        onLongPress: () {
                                                          //Delete dialog
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title: const Text(
                                                                  "Delete"),
                                                              content: Text(
                                                                  "Are you sure you want to delete ${device.hostname ?? 'this'} device?"),
                                                              actions: [
                                                                FlatButton(
                                                                  child: const Text(
                                                                      "Cancel"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                FlatButton(
                                                                  child: const Text(
                                                                      "Delete"),
                                                                  onPressed:
                                                                      () async {
                                                                    EasyLoading.show(
                                                                        status:
                                                                            "Deleting...");
                                                                    var res = await NetworkRequests()
                                                                        .deleteDevice(
                                                                            device.hostname!);
                                                                    if (res.success ==
                                                                        true) {
                                                                      EasyLoading.showSuccess(
                                                                          res.message ??
                                                                              "Success");
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      setState(
                                                                          () {
                                                                        _devices =
                                                                            NetworkRequests().getUserDevices();
                                                                      });
                                                                    } else {
                                                                      EasyLoading.showError(
                                                                          res.message ??
                                                                              "Error deleting device");
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    }
                                                                    setState(
                                                                        () {
                                                                      _devices =
                                                                          NetworkRequests()
                                                                              .getUserDevices();
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      DeviceDetailsScreen(
                                                                          device,
                                                                          record.sensor ??
                                                                              device.hostname!)));
                                                        },
                                                        child: Row(
                                                            /*mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,*/

                                                            children: [
                                                              Expanded(
                                                                flex: 2,
                                                                child: SizedBox(
                                                                  width: 100,
                                                                  child: SfRadialGauge(
                                                                      //title: const GaugeTitle(text: 'Moisture', borderWidth: 10),
                                                                      enableLoadingAnimation: true,
                                                                      animationDuration: 4500,
                                                                      axes: <RadialAxis>[
                                                                        RadialAxis(
                                                                            showLabels:
                                                                                false,
                                                                            showAxisLine:
                                                                                false,
                                                                            showTicks:
                                                                                false,
                                                                            minimum:
                                                                                0,
                                                                            maximum:
                                                                                99,
                                                                            ranges: <GaugeRange>[
                                                                              GaugeRange(
                                                                                startValue: 0,
                                                                                endValue: 33,
                                                                                color: Color(0xFFFE2A25),
                                                                                label: 'Dry',
                                                                                sizeUnit: GaugeSizeUnit.factor,
                                                                                labelStyle: GaugeTextStyle(fontSize: 9),
                                                                                startWidth: 0.33,
                                                                                endWidth: 0.33,
                                                                              ),
                                                                              GaugeRange(
                                                                                startValue: 33,
                                                                                endValue: 66,
                                                                                color: const Color(0xFFFFBA00),
                                                                                label: 'OK',
                                                                                labelStyle: const GaugeTextStyle(fontSize: 9),
                                                                                startWidth: 0.33,
                                                                                endWidth: 0.33,
                                                                                sizeUnit: GaugeSizeUnit.factor,
                                                                              ),
                                                                              GaugeRange(
                                                                                startValue: 66,
                                                                                endValue: 99,
                                                                                color: const Color(0xFF00AB47),
                                                                                label: 'Good',
                                                                                labelStyle: const GaugeTextStyle(fontSize: 9),
                                                                                sizeUnit: GaugeSizeUnit.factor,
                                                                                startWidth: 0.33,
                                                                                endWidth: 0.33,
                                                                              ),
                                                                            ],
                                                                            pointers: <GaugePointer>[
                                                                              NeedlePointer(
                                                                                value: record.moisture?.toDouble() ?? 0,
                                                                                needleEndWidth: 1,
                                                                              )
                                                                            ],
                                                                            annotations: <GaugeAnnotation>[
                                                                              GaugeAnnotation(widget: Container(child: Text('${record.moisture}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))), angle: 90, positionFactor: .8)
                                                                            ]),
                                                                      ]),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                flex: 4,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text.rich(
                                                                      TextSpan(
                                                                        // Note: Styles for TextSpans must be explicitly defined.
                                                                        // Child text spans will inherit styles from parent
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        children: <
                                                                            TextSpan>[
                                                                          const TextSpan(
                                                                              text: 'Sensor: ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                                          TextSpan(
                                                                              text: '${record.sensor}'),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Text.rich(
                                                                      TextSpan(
                                                                        // Note: Styles for TextSpans must be explicitly defined.
                                                                        // Child text spans will inherit styles from parent
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        children: <
                                                                            TextSpan>[
                                                                          const TextSpan(
                                                                              text: 'Moisture: ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                                          TextSpan(
                                                                              text: '${record.moisture}%',
                                                                              style: TextStyle(
                                                                                color: (record.moisture! < 20 ? Colors.red : Colors.green),
                                                                              )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Text.rich(
                                                                      TextSpan(
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        children: <
                                                                            TextSpan>[
                                                                          /*  const WidgetSpan(
                                                            child: Icon(Icons
                                                                .location_on_outlined),
                                                          ),*/
                                                                          const TextSpan(
                                                                              text: 'Location: ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                                          TextSpan(
                                                                              text: '${record.location}')
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Text.rich(
                                                                      TextSpan(
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        children: <
                                                                            TextSpan>[
                                                                          const TextSpan(
                                                                              text: 'Updated: ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                                          TextSpan(
                                                                              text: '${timeago.format(DateTime.parse(record.createdAt!))}')
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                                child:
                                                                    Container(
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      right: 10,
                                                                      top: 15),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      //logout()
                                                                      await FirebaseAuth
                                                                          .instance
                                                                          .signOut();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pushReplacement(
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              RegisterPage(),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        BatteryIndicator(
                                                                      batteryFromPhone:
                                                                          false,
                                                                      batteryLevel:
                                                                          74,
                                                                      style: BatteryIndicatorStyle
                                                                          .skeumorphism,
                                                                      colorful:
                                                                          true,
                                                                      showPercentNum:
                                                                          true,
                                                                      mainColor:
                                                                          Colors
                                                                              .green /*( batteryLv < 15 ? Colors.red : batteryLv < 30 ? Colors.orange : Colors.green)*/,
                                                                      size: 8.0,
                                                                      ratio:
                                                                          2.5,
                                                                      showPercentSlide:
                                                                          true,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: snapshot.data?.data != null &&
                                                                    snapshot
                                                                            .data
                                                                            ?.data
                                                                            ?.isNotEmpty ==
                                                                        true &&
                                                                    snapshot
                                                                            .data
                                                                            ?.data![0]
                                                                            .image
                                                                            ?.isNotEmpty ==
                                                                        true,
                                                                child: Expanded(
                                                                  flex: 2,
                                                                  child: record
                                                                              .image ==
                                                                          null
                                                                      ? Container()
                                                                      : Card(
                                                                          shape:
                                                                              const RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(10),
                                                                                bottomRight: Radius.circular(10),
                                                                                topLeft: Radius.circular(10),
                                                                                bottomLeft: Radius.circular(10)),
                                                                          ),
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              showImageDialog(context, device.hostname, record.image);
                                                                            },
                                                                            child:
                                                                                SizedBox(
                                                                              width: 90,
                                                                              height: 90,
                                                                              child: Image.network(
                                                                                'https://athome.rodlandfarms.com/uploads/${record.image}',
                                                                                fit: BoxFit.fill,
                                                                                alignment: Alignment.center,
                                                                                colorBlendMode: BlendMode.darken,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                ),
                                                              )
                                                            ]),
                                                      );
                                                    } else {
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    }
                                                  }),
                                        )),
                                  );
                                } else {
                                  // print('Should not show here $index');
                                  return Container(
                                      height: 100,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child:
                                            FutureBuilder<
                                                    GetDeviceDataResponse>(
                                                future: NetworkRequests()
                                                    .getLatestDeviceData(
                                                        device.hostname!),
                                                builder: (context, snapshot) {
                                                  // print("DeviceRecord:" +
                                                  //     snapshot.connectionState.name);
                                                  if (snapshot.hasData) {
                                                    if (snapshot.data?.data
                                                            ?.isEmpty ==
                                                        true) {
                                                      return Center(
                                                        child: const Text(
                                                          "No data available",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      );
                                                    }

                                                    Records record =
                                                        snapshot.data!.data![0];

                                                    // print("ID${record.id}");
                                                    // print("Location${record.image}");
                                                    return InkWell(
                                                      onLongPress: () {
                                                        //Delete dialog
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              AlertDialog(
                                                            title: const Text(
                                                                "Delete"),
                                                            content: Text(
                                                                "Are you sure you want to delete ${device.hostname ?? 'this'} device?"),
                                                            actions: [
                                                              FlatButton(
                                                                child: const Text(
                                                                    "Cancel"),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                              FlatButton(
                                                                child: const Text(
                                                                    "Delete"),
                                                                onPressed:
                                                                    () async {
                                                                  EasyLoading.show(
                                                                      status:
                                                                          "Deleting...");
                                                                  var res = await NetworkRequests()
                                                                      .deleteDevice(
                                                                          device
                                                                              .hostname!);
                                                                  if (res.success ==
                                                                      true) {
                                                                    EasyLoading.showSuccess(
                                                                        res.message ??
                                                                            "Success");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    setState(
                                                                        () {
                                                                      _devices =
                                                                          NetworkRequests()
                                                                              .getUserDevices();
                                                                    });
                                                                  } else {
                                                                    EasyLoading.showError(
                                                                        res.message ??
                                                                            "Error deleting device");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
                                                                  setState(() {
                                                                    _devices =
                                                                        NetworkRequests()
                                                                            .getUserDevices();
                                                                  });
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    DeviceDetailsScreen(
                                                                        device,
                                                                        record.sensor ??
                                                                            device.hostname!)));
                                                      },
                                                      child: Row(
                                                          /*mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,*/

                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: SizedBox(
                                                                width: 100,
                                                                child: SfRadialGauge(
                                                                    //title: const GaugeTitle(text: 'Moisture', borderWidth: 10),
                                                                    enableLoadingAnimation: true,
                                                                    animationDuration: 4500,
                                                                    axes: <RadialAxis>[
                                                                      RadialAxis(
                                                                          showLabels:
                                                                              false,
                                                                          showAxisLine:
                                                                              false,
                                                                          showTicks:
                                                                              false,
                                                                          minimum:
                                                                              0,
                                                                          maximum:
                                                                              99,
                                                                          ranges: <
                                                                              GaugeRange>[
                                                                            GaugeRange(
                                                                              startValue: 0,
                                                                              endValue: 33,
                                                                              color: Color(0xFFFE2A25),
                                                                              label: 'Dry',
                                                                              sizeUnit: GaugeSizeUnit.factor,
                                                                              labelStyle: GaugeTextStyle(fontSize: 9),
                                                                              startWidth: 0.33,
                                                                              endWidth: 0.33,
                                                                            ),
                                                                            GaugeRange(
                                                                              startValue: 33,
                                                                              endValue: 66,
                                                                              color: const Color(0xFFFFBA00),
                                                                              label: 'OK',
                                                                              labelStyle: const GaugeTextStyle(fontSize: 9),
                                                                              startWidth: 0.33,
                                                                              endWidth: 0.33,
                                                                              sizeUnit: GaugeSizeUnit.factor,
                                                                            ),
                                                                            GaugeRange(
                                                                              startValue: 66,
                                                                              endValue: 99,
                                                                              color: const Color(0xFF00AB47),
                                                                              label: 'Good',
                                                                              labelStyle: const GaugeTextStyle(fontSize: 9),
                                                                              sizeUnit: GaugeSizeUnit.factor,
                                                                              startWidth: 0.33,
                                                                              endWidth: 0.33,
                                                                            ),
                                                                          ],
                                                                          pointers: <
                                                                              GaugePointer>[
                                                                            NeedlePointer(
                                                                              value: record.moisture?.toDouble() ?? 0,
                                                                              needleEndWidth: 1,
                                                                            )
                                                                          ],
                                                                          annotations: <
                                                                              GaugeAnnotation>[
                                                                            GaugeAnnotation(
                                                                                widget: Container(child: Text('${record.moisture}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                                                                                angle: 90,
                                                                                positionFactor: .8)
                                                                          ]),
                                                                    ]),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Expanded(
                                                              flex: 4,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      // Note: Styles for TextSpans must be explicitly defined.
                                                                      // Child text spans will inherit styles from parent
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      children: <
                                                                          TextSpan>[
                                                                        const TextSpan(
                                                                            text:
                                                                                'Sensor: ',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                '${record.sensor}'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      // Note: Styles for TextSpans must be explicitly defined.
                                                                      // Child text spans will inherit styles from parent
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      children: <
                                                                          TextSpan>[
                                                                        const TextSpan(
                                                                            text:
                                                                                'Moisture: ',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                '${record.moisture}%',
                                                                            style:
                                                                                TextStyle(
                                                                              color: (record.moisture! < 20 ? Colors.red : Colors.green),
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      children: <
                                                                          TextSpan>[
                                                                        /*  const WidgetSpan(
                                                            child: Icon(Icons
                                                                .location_on_outlined),
                                                          ),*/
                                                                        const TextSpan(
                                                                            text:
                                                                                'Location: ',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                '${record.location}')
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      children: <
                                                                          TextSpan>[
                                                                        const TextSpan(
                                                                            text:
                                                                                'Updated: ',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                '${timeago.format(DateTime.parse(record.createdAt!))}')
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            10,
                                                                        top:
                                                                            15),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    //logout()
                                                                    await FirebaseAuth
                                                                        .instance
                                                                        .signOut();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pushReplacement(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                RegisterPage(),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      BatteryIndicator(
                                                                    batteryFromPhone:
                                                                        false,
                                                                    batteryLevel:
                                                                        74,
                                                                    style: BatteryIndicatorStyle
                                                                        .skeumorphism,
                                                                    colorful:
                                                                        true,
                                                                    showPercentNum:
                                                                        true,
                                                                    mainColor:
                                                                        Colors
                                                                            .green /*( batteryLv < 15 ? Colors.red : batteryLv < 30 ? Colors.orange : Colors.green)*/,
                                                                    size: 8.0,
                                                                    ratio: 2.5,
                                                                    showPercentSlide:
                                                                        true,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: snapshot
                                                                          .data
                                                                          ?.data !=
                                                                      null &&
                                                                  snapshot
                                                                          .data
                                                                          ?.data
                                                                          ?.isNotEmpty ==
                                                                      true &&
                                                                  snapshot
                                                                          .data
                                                                          ?.data![
                                                                              0]
                                                                          .image
                                                                          ?.isNotEmpty ==
                                                                      true,
                                                              child: Expanded(
                                                                flex: 2,
                                                                child: record
                                                                            .image ==
                                                                        null
                                                                    ? Container()
                                                                    : Card(
                                                                        shape:
                                                                            const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.only(
                                                                              topRight: Radius.circular(10),
                                                                              bottomRight: Radius.circular(10),
                                                                              topLeft: Radius.circular(10),
                                                                              bottomLeft: Radius.circular(10)),
                                                                        ),
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            showImageDialog(
                                                                                context,
                                                                                device.hostname,
                                                                                record.image);
                                                                          },
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                90,
                                                                            height:
                                                                                90,
                                                                            child:
                                                                                Image.network(
                                                                              'https://athome.rodlandfarms.com/uploads/${record.image}',
                                                                              fit: BoxFit.fill,
                                                                              alignment: Alignment.center,
                                                                              colorBlendMode: BlendMode.darken,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                              ),
                                                            )
                                                          ]),
                                                    );
                                                  } else {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }
                                                }),
                                      ));
                                }
                              });
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
        onPressed: () async {
          final bool args = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BleScreen(),
            ),
          );
          print("args $args");
          if (args != null && args == true) {
            setState(() {

              _devices = NetworkRequests().getUserDevices();
            });
          }
          // var _controller = TextEditingController();
          //create dialog
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return AlertDialog(
          //         title: Text("Add Device"),
          //         content: TextField(
          //           controller: _controller,
          //           decoration: InputDecoration(
          //               labelText: "Hostname",
          //               hintText: "Enter device name",
          //               border: OutlineInputBorder()),
          //         ),
          //         actions: <Widget>[
          //           FlatButton(
          //             child: Text("Cancel"),
          //             onPressed: () {
          //               Navigator.of(context).pop();
          //             },
          //           ),
          //           FlatButton(
          //             child: Text("Add"),
          //             onPressed: () {
          //               if (_controller.text.isEmpty) {
          //                 showDialog(
          //                     context: context,
          //                     builder: (BuildContext context) {
          //                       return AlertDialog(
          //                         title: Text("Error"),
          //                         content: Text("Hostname cannot be empty"),
          //                         actions: <Widget>[
          //                           FlatButton(
          //                             child: Text("Ok"),
          //                             onPressed: () {
          //                               Navigator.of(context).pop();
          //                             },
          //                           )
          //                         ],
          //                       );
          //                     });
          //               } else {
          //                 Navigator.of(context).pop();
          //                 EasyLoading.show(status: 'Adding device...');
          //                 NetworkRequests()
          //                     .saveDevice(_controller.text)
          //                     .then((value) async {
          //                   EasyLoading.dismiss();
          //                   if (value.success == true) {
          //                     print("Adding to firebase:");
          //                     await FirebaseMessaging.instance
          //                         .subscribeToTopic("host_" + _controller.text);
          //                     EasyLoading.showSuccess('Device added');
          //                     setState(() {
          //                       _devices = NetworkRequests().getUserDevices();
          //                     });
          //                   } else {
          //                     EasyLoading.showError(value.message??'Error adding device');
          //                   }
          //                 }).catchError((error) {
          //                   EasyLoading.dismiss();
          //                   EasyLoading.showError('Error adding device');
          //                 });
          //               }
          //             },
          //           )
          //         ],
          //       );
          //     });
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  void showImageDialog(BuildContext context, String? hostname, String? image) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Images"),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close),
                ),
              ],
            ),
            content: FutureBuilder<ImagesResponse>(
                future: NetworkRequests().getAllImages(hostname!),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      (snapshot.data?.data!.length ?? 0 == 0) == true) {
                    return Center(
                      child: Text("No images"),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        //width: 100,
                        //height: 100,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    child: SizedBox(
                      //height: MediaQuery.of(context).size.height * 0.6,
                      child: CarouselSlider(
                        items: snapshot.data?.data?.map((i) {
                          print("Name:${i.name}");
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                width: MediaQuery.of(context).size.width * 0.7,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Image.network(
                                  'https://athome.rodlandfarms.com/uploads/${i.name}',
                                  fit: BoxFit.fill,
                                ),
                              );
                            },
                          );
                        }).toList(),
                        options: CarouselOptions(
                          /*height: 100,
                      aspectRatio: 16/9,*/
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll: false,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ),
                  );
                }),
          );
        });
  }
}
