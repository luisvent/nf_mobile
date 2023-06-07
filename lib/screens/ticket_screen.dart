import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nf_mobile/components/sheet_options/android_sheet_options.dart';
import 'package:nf_mobile/interface/Payment.dart';
import 'package:nf_mobile/resources/printer.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class TicketScreen extends StatefulWidget {
  final List<Payment> payments;
  TicketScreen({Key? key, required this.payments}) : super(key: key);

  @override
  TicketScreenState createState() => TicketScreenState();
}

class TicketScreenState extends State<TicketScreen> {
  late TextEditingController activitySearch;
  Printer printerController = Printer();
  Widget appBarTitle = Text("Recibo", style: TextStyle(color: Color(0xff243656)));

  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );

  String ticket = '';

  @override
  void initState() {
    super.initState();
    activitySearch = TextEditingController();
    initTicket();
  }

  initTicket() async {
    final createdTicket = await createTicket();
    setState(() {
      ticket = createdTicket as String;
    });
  }

  Future<String?> createTicket([bool thermalPrint = false]) async {
    String createdTickets = '';

    for (var i = 0; i < widget.payments.length; i++) {
      final payment = widget.payments[i];

      final createdTicket = await Tools.CreateTextReceipt(payment, thermalPrint);
      createdTickets += createdTicket + '\n\n';

      if (i == widget.payments.length - 1) {
        return createdTickets;
      } else {
        createdTickets += '______________Ticket [${i + 2}]______________\n\n\n';
      }
    }
  }

  void shareReceipt() async {
    Share.share(ticket);
  }

  Future<void> thermalPrintReceipt() async {
    EasyLoading.show(status: 'Imprimiendo Recibo...', maskType: EasyLoadingMaskType.black, dismissOnTap: false);

    final settings = await Providers.Settings(context).GetSettings();
    final printerName = settings.printerName;

    final ticketCreated = await createTicket(true);
    final result = await printerController.Print(printerName, ticketCreated as String);

    if (result.error) {
      EasyLoading.dismiss();
      Tools.ShowSnackbar(context, result.message, result.error ? Colors.red : Colors.green, 4);
    } else {
      Future.delayed(const Duration(milliseconds: 3000), () {
        EasyLoading.dismiss();
        Tools.ShowSnackbar(context, result.message, result.error ? Colors.red : Colors.green, 4);
      });
    }
  }

  Future<void> attempPrint() async {
    final settings = await Providers.Settings(context).GetSettings();

    String errorMessage = '';

    if (settings.printerName == '') {
      errorMessage = 'No se ha configurado una impresora';
    }

    final bluetoothPermissionGranted = await Permission.bluetoothConnect.isGranted;

    if (!bluetoothPermissionGranted) {
      errorMessage = '${errorMessage == '' ? '' : errorMessage + ' o '}La aplicación no tiene permisos bluetooth para impresión';
    }

    if (errorMessage == '') {
      thermalPrintReceipt();
    } else {
      Tools.ShowConfirmDialog(context, 'No hay impresora Bluetooth', errorMessage + '. Desea hacer una impresión normal?', 'Ok', () {
        Navigator.of(context).pop();
        Tools.NormalPrint('', ticket);
      }, 'Cancelar');
    }
  }

  void openPrintOptionsModal() {
    final printOptions = [
      {'title': 'Impresora Bluetooth', 'id': 1, 'icon': Icons.settings_bluetooth_outlined},
      {'title': 'Impresión Normal', 'id': 2, 'icon': Icons.print_sharp},
    ];

    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => AndroidSheetOptions(printOptions, (option) {
        if (option['id'] == 1) {
          attempPrint();
        } else if (option['id'] == 2) {
          Tools.NormalPrint('', ticket);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close, color: Color(0xff243656))),
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
                      if (widget.payments.length > 1)
                        Container(
                          child: Text(
                            '${widget.payments.length} Recibos para pago',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                        ),
                      Container(
                        height: height - 250,
                        padding: EdgeInsets.all(30),
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          // color: Color(0xFF0070BA),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                /*
                                  color: Color(0xffF5F7FA),
                                  blurRadius: 4,
                                  offset: Offset(0.0, 3),
                                  spreadRadius: 0
                                  */
                                color: Color(0xff1546a0).withOpacity(0.2),
                                blurRadius: 48,
                                offset: Offset(2, 8),
                                spreadRadius: -10),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            ticket,
                            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.all(2),
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50]!.withOpacity(0.5),
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: Container(
                              child: OutlinedButton.icon(
                                label: Text(
                                  "Imprimir",
                                  style: TextStyle(color: Color(0xff929BAB)),
                                ),
                                icon: Icon(
                                  Icons.local_print_shop_outlined,
                                  size: 24.0,
                                  color: Color(0xff929BAB),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[50],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  primary: Colors.blue,
                                  side: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                onPressed: () {
                                  openPrintOptionsModal();
                                },
                              ),
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                            )),
                            Expanded(
                                child: Container(
                              child: OutlinedButton.icon(
                                label: Text(
                                  "Enviar",
                                  style: TextStyle(color: Color(0xff929BAB)),
                                ),
                                icon: Icon(
                                  Icons.send_outlined,
                                  size: 24.0,
                                  color: Color(0xff929BAB),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[50],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  primary: Colors.blue,
                                  side: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                onPressed: () {
                                  shareReceipt();
                                },
                              ),
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ))),
        ]));
  }
}
