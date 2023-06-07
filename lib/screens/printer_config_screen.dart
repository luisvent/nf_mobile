import 'package:datecs_printer/datecs_printer.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nf_mobile/resources/printer.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterConfigScreen extends StatefulWidget {
  const PrinterConfigScreen({Key? key}) : super(key: key);

  @override
  PrinterConfigScreenState createState() => PrinterConfigScreenState();
}

class PrinterConfigScreenState extends State<PrinterConfigScreen> {
  String deviceNameSelected = '';
  bool bluetoothPermissionGranted = true;
  late TextEditingController activitySearch;
  Printer printerController = Printer();
  List<DatecsDevice> devices = [];
  Widget appBarTitle = Text("Configurar Printer", style: TextStyle(color: Color(0xff243656)));
  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );
  @override
  void initState() {
    super.initState();
    getDeviceSaved();
    Permission.bluetoothConnect.isGranted.then((bluetoothPermissionStatus) {
      setState(() {
        bluetoothPermissionGranted = bluetoothPermissionStatus;
      });
    });
  }

  Future<bool> searchBluetoothDevices() async {
    Tools.ShowSnackbar(context, 'Buscando Dispositiovs Bluetooth...', Colors.blue, 5);

    final btDevices = await printerController.GetBluetoothList();

    setState(() {
      devices = btDevices;
    });

    return true;
  }

  Future<void> getDeviceSaved() async {
    final settings = await Providers.Settings(context).GetSettings();

    setState(() {
      deviceNameSelected = settings.printerName;
    });
  }

  Future<void> selectDevice(DatecsDevice device) async {
    final saved = await Providers.Settings(context).SaveSetting('printerName', device.name);
    setState(() {
      deviceNameSelected = device.name;
    });
    Tools.ShowSnackbar(context, 'Impresora Seleccionada', Colors.green, 3);
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
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: Text('Impresora'),
                ),
                Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.all(7),
                    alignment: Alignment.center,
                    child: Text(
                      deviceNameSelected,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: bluetoothPermissionGranted
                      ? OutlinedButton.icon(
                          label: Text("Buscar"),
                          icon: Icon(
                            Icons.search,
                            size: 24.0,
                          ),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.blue,
                            side: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                          onPressed: () {
                            searchBluetoothDevices();
                          },
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
                        ),
                ),
                SizedBox(height: 30),
                Container(
                  height: 150,
                  child: ListView.separated(
                    padding: EdgeInsets.all(0),
                    separatorBuilder: (_, b) => Divider(
                      height: 14,
                      color: Colors.transparent,
                    ),
                    itemCount: devices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: Color(0xff1546a0).withOpacity(0.1), blurRadius: 48, offset: Offset(2, 8), spreadRadius: 0),
                          ],
                          color: Colors.white,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.only(left: 8, top: 0, bottom: 0, right: 6.18),
                          title: Text(
                            devices[index].name,
                            style: TextStyle(fontSize: 12, color: Color(0xff243656)),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              devices[index].address,
                              style: TextStyle(fontSize: 12, color: Color(0xff929BAB)),
                            ),
                          ),
                          trailing: OutlinedButton.icon(
                            label: Text(devices[index].name == deviceNameSelected ? "Seleccionado" : 'Seleccionar'),
                            icon: Icon(
                              Icons.print,
                              size: 24.0,
                            ),
                            style: OutlinedButton.styleFrom(
                              primary: devices[index].name == deviceNameSelected ? Colors.green : Colors.blue,
                              side: BorderSide(
                                color: devices[index].name == deviceNameSelected ? Colors.green : Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              selectDevice(devices[index]);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )),
        ]));
  }
}
