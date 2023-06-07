import 'package:datecs_printer/datecs_printer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionConfigScreen extends StatefulWidget {
  const PermissionConfigScreen({Key? key}) : super(key: key);

  @override
  PermissionConfigScreenState createState() => PermissionConfigScreenState();
}

class PermissionConfigScreenState extends State<PermissionConfigScreen> {
  bool bluetoothPermissionGranted = false;
  bool locationPermissionGranted = false;
  late TextEditingController activitySearch;
  Widget appBarTitle = Text("Permisos", style: TextStyle(color: Color(0xff243656)));

  @override
  void initState() {
    super.initState();
    Permission.bluetoothConnect.isGranted.then((bluetoothPermissionStatus) {
      setState(() {
        bluetoothPermissionGranted = bluetoothPermissionStatus;
      });
    });

    detectLocationPermission();
  }

  Future<bool> detectLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    var locationPermission = false;

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      locationPermission = false;
    } else {
      locationPermission = true;
    }

    setState(() {
      locationPermissionGranted = locationPermission;
    });
    return locationPermission;
  }

  Future<void> selectDevice(DatecsDevice device) async {
    // final settings = await settingsStorage.GetSettings();
    // settings.printerName = device.name;
    // final saved = await settingsStorage.StoreSettingsData(settings);
    //
    // setState(() {
    //   deviceNameSelected = device.name;
    // });
    Tools.ShowSnackbar(context, 'Impresora Salvada', Colors.green, 3);
  }

  Future<void> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Tools.ShowSnackbar(context, 'Permiso concedido', Colors.green);
      setState(() {
        locationPermissionGranted = true;
      });
    } else {
      Tools.ShowSnackbar(context, 'Permiso negado', Colors.red);
      setState(() {
        locationPermissionGranted = false;
      });
    }
  }

  Future<void> requestBluetoothPermission() async {
    final status = await Permission.bluetoothConnect.request();

    if (status.isGranted) {
      Tools.ShowSnackbar(context, 'Permiso concedido', Colors.green);
      setState(() {
        bluetoothPermissionGranted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: Icon(Icons.arrow_back, color: Color(0xff243656))),
          title: appBarTitle,
          centerTitle: true,
          actions: [],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Column(children: <Widget>[
          SizedBox(
            height: 100,
          ),
          Expanded(
              child: Container(
            height: 300,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bluetooth,
                        color: Colors.blueGrey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Bluetooth',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blueGrey),
                      )
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(5),
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.all(7),
                    child: bluetoothPermissionGranted
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Permiso Concedido',
                                style: TextStyle(color: Colors.blueGrey, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.check_circle_outline_outlined,
                                color: Colors.green,
                              )
                            ],
                          )
                        : OutlinedButton.icon(
                            label: Text("Solicitar permiso Bluetooth"),
                            icon: Icon(
                              Icons.bluetooth,
                              size: 24.0,
                            ),
                            style: OutlinedButton.styleFrom(
                              primary: Colors.blue,
                              side: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              requestBluetoothPermission();
                            },
                          )),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.blueGrey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Ubicación',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blueGrey),
                      )
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(5),
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.all(7),
                    child: locationPermissionGranted
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Permiso Concedido',
                                style: TextStyle(color: Colors.blueGrey, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.check_circle_outline_outlined,
                                color: Colors.green,
                              )
                            ],
                          )
                        : OutlinedButton.icon(
                            label: Text("Solicitar permiso de Ubicación"),
                            icon: Icon(
                              Icons.location_on_outlined,
                              size: 24.0,
                            ),
                            style: OutlinedButton.styleFrom(
                              primary: Colors.blue,
                              side: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              requestLocationPermission();
                            },
                          )),
              ],
            ),
          )),
        ]));
  }
}
