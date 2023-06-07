import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nf_mobile/components/sheet_options/android_sheet_options.dart';
import 'package:nf_mobile/interface/Loan.dart';
import 'package:nf_mobile/interface/Payment.dart';
import 'package:nf_mobile/interface/PaymentDistribution.dart';
import 'package:nf_mobile/resources/printer.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart' as CPrinting;
import 'package:share_plus/share_plus.dart';

class PayLoanScreen extends StatefulWidget {
  final Loan loan;
  PayLoanScreen({Key? key, required this.loan}) : super(key: key);

  @override
  PayLoanScreenState createState() => PayLoanScreenState();
}

class PayLoanScreenState extends State<PayLoanScreen> {
  Printer printerController = Printer();
  TextEditingController _transactionAmountController = TextEditingController();
  PaymentDistribution distribution = PaymentDistribution();
  bool paying = false;

  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );

  String ticket = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _transactionAmountController.dispose();
    super.dispose();
  }

  Future<void> payLoan() async {
    paying = true;
    distributeAmountToPay();
    Future.delayed(Duration(milliseconds: 1000), () async {
      final amount = double.parse(_transactionAmountController.value.text);
      if (amount == 0) return;

      final payment = Payment(loan: widget.loan, context: context);
      payment.amount = amount;

      final result = await Tools.PayInstallment(loan: widget.loan, payment: payment, context: context);
      paymentCompleted(result);
    });
  }

  Future<void> paymentCompleted(bool completed) async {
    paying = false;
    _transactionAmountController.text = '0';
    Navigator.of(context).pop();
  }

  void shareReceipt() async {
    Share.share(ticket);
  }

  void normalPrintReceipt(String title, String content) async {
    print(content);
    await CPrinting.Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      var doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 20),
                pw.Text(content, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 14))
              ],
            );
          },
        ),
      );

      return doc.save();
    });
  }

  Future<void> thermalPrintReceipt() async {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.light
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;

    EasyLoading.show(status: 'Imprimiendo Recibo...', maskType: EasyLoadingMaskType.black, dismissOnTap: false);

    final settings = await Providers.Settings(context).GetSettings();
    final printerName = settings.printerName;
    final result = await printerController.Print(printerName, ticket);

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
        normalPrintReceipt('', ticket);
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
          normalPrintReceipt('', ticket);
        }
      }),
    );
  }

  void distributeAmountToPay() {
    final distributedPayment = Tools.DistributePayment(Loan.fromJson(widget.loan.toJson()),
        _transactionAmountController.value.text == '' ? 0.0 : double.parse(_transactionAmountController.value.text));

    setState(() {
      distribution = distributedPayment;
    });
  }

  Widget distributionWidget() {
    List<Widget> children = [];

    children.add(Text(
      'Capital: \$ ${Tools.FormatCurrency(distribution.paidCapital)}',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ));
    children.add(Text(
      'Mora: \$ ${Tools.FormatCurrency(distribution.paidArrears)}',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ));
    children.add(Text(
      'Interés: \$ ${Tools.FormatCurrency(distribution.paidInterest)}',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ));
    children.add(Text(
      'Cargos: \$ ${Tools.FormatCurrency(distribution.paidCharges)}',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ));
    children.add(SizedBox(
      height: 10,
    ));
    children.add(Text(
      'Restante: \$ ${Tools.FormatCurrency(widget.loan.totalDebt - (distribution.paidArrears + distribution.paidInterest + distribution.paidCharges + distribution.paidCapital))}',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
    ));

    distribution.installmentsPaid.forEach((installment) {
      print(installment.totalDebt);
      children.add(Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Text(
            'Cuota #${installment.number}:\nCapital: \$ ${Tools.FormatCurrency(installment.capital as double)} / '
            'Mora: \$ ${Tools.FormatCurrency(installment.arrears as double)} /'
            ' Interés: \$ ${Tools.FormatCurrency(installment.interest as double)}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: installment.paid! ? Colors.blue : Colors.black),
            textAlign: TextAlign.left,
          ),
        ),
      ));
    });

    return Column(
      children: children,
      mainAxisAlignment: MainAxisAlignment.start,
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
        title: Text("Pago a Préstamo No. " + widget.loan.id.toString(), style: TextStyle(fontSize: 16, color: Color(0xff243656))),
        centerTitle: true,
        actions: [],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    /*
                    color: Color(0xffF5F7FA),
                    blurRadius: 4,
                    offset: Offset(0.0, 3),
                    spreadRadius: 0
                    */
                    color: Color(0xff1546a0).withOpacity(0.1),
                    blurRadius: 48,
                    offset: Offset(2, 8),
                    spreadRadius: -16),
              ],
              color: Colors.white,
            ),
            child: ListTile(
                contentPadding: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 6.18),
                leading: CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xffF5F7FA),
                  child: Icon(
                    FluentIcons.money_calculator_24_regular,
                    size: 30,
                  ),
                ),
                title: Text(
                  widget.loan.idClient as String,
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  'Deuda: \$ ' + Tools.FormatCurrency(widget.loan.totalDebt),
                  style: TextStyle(fontSize: 13, color: Colors.red),
                )),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 27, vertical: 13),
            child: TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _transactionAmountController,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: Color(0xff243656)),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Color(0xFF0070BA), width: 2.0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Color(0xFF0070BA))),
                prefix: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Text(
                      "\$",
                      style: GoogleFonts.manrope(fontSize: 40, fontWeight: FontWeight.w600, color: Color(0xff243656)),
                    )),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 45,
            height: 64,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Color(0xffF5F7FA), offset: Offset(0, 4), blurRadius: 5.0)],
              gradient: RadialGradient(colors: [Color(0xff0070BA), Color(0xff1546A0)], radius: 8.4, center: Alignment(-0.24, -0.36)),
              color: Color(0xFF0070BA), // the middle one among 3 colors if possible
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: paying ? null : () => {payLoan()},
              child: Text('Pagar'),
              style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
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
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(bottom: 10),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50]!.withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: OutlinedButton.icon(
                      label: Text(
                        "Ver Distribución",
                        style: TextStyle(color: Color(0xff929BAB)),
                      ),
                      icon: Icon(
                        Icons.low_priority,
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
                        distributeAmountToPay();
                      },
                    ),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: distributionWidget(),
                  ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
