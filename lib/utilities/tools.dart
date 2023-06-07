import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nf_mobile/api/api.email.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/database/settings_storage.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/Installments.dart';
import 'package:nf_mobile/interface/Loan.dart';
import 'package:nf_mobile/interface/Payment.dart';
import 'package:nf_mobile/interface/PaymentDistribution.dart';
import 'package:nf_mobile/interface/Settings.dart';
import 'package:nf_mobile/main.dart';
import 'package:nf_mobile/resources/constants.dart';
import 'package:nf_mobile/resources/printer.dart';
import 'package:nf_mobile/screens/login_screen.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as CPrinting;
import 'package:stack_trace/stack_trace.dart';

class Tools {
  static String FormatCurrency(num amount, [int decimals = 2]) {
    final oCcy = new NumberFormat("#,##0" + (decimals > 0 ? '.' + ('0' * decimals) : ''), "en_US");
    return oCcy.format(amount);
  }

  static String LongDate([DateTime? date]) {
    return DateFormat('dd/MM/yyyy h:mm a').format(date == null ? DateTime.now() : date);
  }

  static void ShowSnackbar(BuildContext context, String message, [Color color = Colors.blue, int time = 1]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: time), content: Text(message), backgroundColor: color));
  }

  static void ShowConfirmDialog(BuildContext context, String title, String message, String confirmText, Function confirmAction, String cancelText) {
    Decoration buttonDecoration = BoxDecoration(
      boxShadow: [BoxShadow(color: Colors.blueGrey.shade100, offset: Offset(0, 4), blurRadius: 5.0)],
      gradient: RadialGradient(colors: [Color(0xff0070BA), Color(0xff1546A0)], radius: 8.4, center: Alignment(-0.24, -0.36)),
      borderRadius: BorderRadius.circular(10),
    );
    ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      primary: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: Text(
                message,
                textAlign: TextAlign.center,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (cancelText != '')
                          Container(
                            height: 48,
                            width: 100,
                            decoration: buttonDecoration,
                            child: ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text(cancelText), style: buttonStyle),
                          ),
                        if (cancelText != '')
                          SizedBox(
                            width: 24,
                          ),
                        if (confirmText != '')
                          Container(
                            height: 48,
                            width: 100,
                            decoration: buttonDecoration,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  confirmAction();
                                },
                                child: Text(confirmText),
                                style: buttonStyle),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                  ],
                )
              ],
            ));
  }

  static Future<Position> GetLocation({BuildContext? context = null, String? loadingMessage = 'Obteninendo ubicación...'}) async {
    final locations = [
      [19.392448728575445, -70.53130882699622],
      [19.390384204708667, -70.53087967355373],
      [19.387955319578708, -70.53033250291492],
      [19.38716592411005, -70.53488152940389],
      [19.384058907330598, -70.53433435876508],
      [19.3919397904138, -70.52543605012073],
      [19.38817503899142, -70.52539313477678],
      [19.391808227988633, -70.52410567444929],
      [19.397741863309022, -70.52807336689864],
      [19.400996639181955, -70.52320251225439],
      [19.39774488738378, -70.51940597145062],
      [19.391002959292763, -70.51324083854479],
      [19.380480520303536, -70.51696145557793],
      [19.376432112092303, -70.51678979420115],
      [19.378123889152675, -70.52264210903184],
      [19.378689954304136, -70.52722468867523],
      [19.368387386255293, -70.53454488674743],
      [19.369056385008847, -70.54451295830694],
      [19.39147055781656, -70.54205063189727],
      [19.386519605684285, -70.53867504175628],
      [19.39428249428211, -70.53581359199552],
    ];

    final location = locations[new Random().nextInt((locations.length - 1))];

    return Position(
        longitude: location[1], latitude: location[0], timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);

    LocationPermission permission;
    bool stillLoading = true;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (stillLoading) ShowLoading(loadingMessage: loadingMessage);
    });
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (context != null) {
        ShowSnackbar(context, 'Habilite los permisos de ubicación', Colors.blue);
      }
      permission = await Geolocator.requestPermission();
    }
    try {
      var position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        stillLoading = false;
        HideLoading();
        return Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
      } else {
        position = await Geolocator.getCurrentPosition();
      }
      stillLoading = false;
      HideLoading();
      return position;
    } catch (e) {
      stillLoading = false;
      HideLoading();
      return Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
    }
  }

  static void ShowLoading({num? dismissAfterMilliseconds = null, num? showAfterMilliseconds = null, String? loadingMessage = '', Widget? indicator}) {
    if (showAfterMilliseconds == null) {
      EasyLoading.show(status: loadingMessage, maskType: EasyLoadingMaskType.black, dismissOnTap: false, indicator: indicator);
    } else {
      Future.delayed(Duration(milliseconds: showAfterMilliseconds as int), () {
        EasyLoading.show(status: loadingMessage, maskType: EasyLoadingMaskType.black, dismissOnTap: false, indicator: indicator);
      });
    }

    if (dismissAfterMilliseconds != null) {
      Future.delayed(Duration(milliseconds: dismissAfterMilliseconds as int), () {
        HideLoading();
      });
    }
  }

  static void HideLoading() {
    EasyLoading.dismiss();
  }

  static Future<String> CreateTextReceipt(Payment payment, [bool thermalPrint = true]) async {
    UserDataStorage userDataStorage = UserDataStorage();
    SettingsStorage settingsStorage = SettingsStorage();
    final settings = await settingsStorage.GetSettings();
    final userData = await userDataStorage.GetUserData();
    final userName = userData!.fullname;
    Printer printerController = Printer();
    String receipt = '';

    if (thermalPrint && settings.receiptLogoType == ReceiptLogoType.Image) {
      final image = await printerController.LoadImage('assets/images/company_logo_wb3_small.png');
      if (image != '') {
        receipt += CreateReceiptLine('#IMG#${image}');
      } else {
        receipt += CreateReceiptLine(Constants.CompanyName.toUpperCase());
      }
    } else {
      receipt += CreateReceiptLine(Constants.CompanyName.toUpperCase());
    }
    receipt += CreateReceiptLine(Constants.CompanyAddress);
    receipt += CreateReceiptLine(Constants.CompanyPhoneNumber);
    receipt += CreateReceiptLine('${payment.date}');
    receipt += CreateReceiptLine('------------------------------');
    receipt += CreateReceiptLine('# de Recibo: ${payment.code}');
    receipt += CreateReceiptLine('------------------------------');
    receipt += CreateReceiptLine('CLIENTE: ${payment.clientName}');
    receipt += CreateReceiptLine('NEGOCIO: ${payment.clientBusiness}');
    receipt += CreateReceiptLine('------------------------------');
    receipt += CreateReceiptLine('Prestamo No.${payment.loanId} : \$${FormatCurrency(payment.loanAmount)}');
    receipt += CreateReceiptLine('');
    receipt += CreateReceiptLine('MONTO PAGADO:');
    receipt += CreateReceiptLine('\$${FormatCurrency(payment.amount)}');
    receipt += CreateReceiptLine('');

    payment.installments!.forEach((installment) {
      var installmentLine = '';
      receipt += CreateReceiptLine('Cuota ${installment.number}/${payment.loanInstallments}:');

      if (installment.arrears! > 0) {
        installmentLine += ' M: \$${FormatCurrency(installment.arrears as num)}';
      }
      if (installment.capital! > 0) {
        installmentLine += ' C: \$${FormatCurrency(installment.capital as num)}';
      }
      if (installment.charges! > 0) {
        installmentLine += ' CA: \$${FormatCurrency(installment.charges as num)}';
      }
      if (installment.interest! > 0) {
        installmentLine += ' I: \$${FormatCurrency(installment.interest as num)}';
      }
      receipt += CreateReceiptLine(installmentLine);
    });

    receipt += CreateReceiptLine('');
    receipt += CreateReceiptLine('Restante: \$ ${FormatCurrency(payment.loanDebtBeforePayment - payment.amount)}');
    receipt += CreateReceiptLine('------------------------------');
    receipt += CreateReceiptLine('COBRADOR: ${userName}');
    receipt += CreateReceiptLine('Revise su recibo y conservelo');
    receipt += CreateReceiptLine('para cualquier reclamacion');
    receipt += CreateReceiptLine('Impreso ' + LongDate());
    return receipt;
  }

  static String CreateReceiptLine(String text, [String spaceCharacter = ' ']) {
    return text + '\n';
    const lineLength = 50;
    final textLength = text.length;
    final emptySpaces = lineLength - textLength;
    final sideSpaces = (emptySpaces / 2).floor();
    final line = (spaceCharacter * sideSpaces) + text + (spaceCharacter * sideSpaces);

    return (line.length == lineLength ? line : ' ' + line) + '\n';
  }

  static PaymentDistribution DistributePayment(Loan loan, double amountToDistribute) {
    final distribution = new PaymentDistribution();
    distribution.amountPaid = amountToDistribute;
    distribution.loanDelayedAmount = loan.delayedAmount!.truncateToDouble();
    distribution.paidInstallments = loan.paidInstallments as int;

    distribution.loanDelayedAmount = distribution.loanDelayedAmount - amountToDistribute;
    final List<Installments> installmentsPaid = [];

    final notPaidInstallments = loan.installments!.where((installment) => !installment.paid!).toList();
    notPaidInstallments.sort((a, b) => (a.number!) < (b.number!) ? -1 : 1);

    for (final loanInstallment in notPaidInstallments) {
      if (amountToDistribute.abs() < 0.99) break;

      var installmentPaid = Installments.fromJson(loanInstallment.toJson());
      var paidCharges = 0.0;
      var paidCapital = 0.0;
      var paidInterest = 0.0;
      var paidArrears = 0.0;

      if (loanInstallment.charges! <= amountToDistribute) {
        paidCharges = loanInstallment.charges as double;
        amountToDistribute -= loanInstallment.charges as double;
        loanInstallment.charges = 0;
        installmentPaid.charges = loanInstallment.charges;
      } else if (amountToDistribute > 0) {
        paidCharges += amountToDistribute;
        loanInstallment.charges = loanInstallment.charges! - amountToDistribute;
        installmentPaid.charges = amountToDistribute;
        amountToDistribute = 0;
      }

      if (loanInstallment.arrears! <= amountToDistribute) {
        paidArrears = loanInstallment.arrears as double;
        amountToDistribute -= loanInstallment.arrears as double;
        installmentPaid.arrears = loanInstallment.arrears;
        loanInstallment.arrears = 0;
      } else if (amountToDistribute > 0) {
        paidArrears += amountToDistribute;
        loanInstallment.arrears = loanInstallment.arrears! - amountToDistribute;
        installmentPaid.arrears = amountToDistribute;
        amountToDistribute = 0;
      }

      if (loanInstallment.interest! <= amountToDistribute) {
        paidInterest = loanInstallment.interest as double;
        amountToDistribute -= loanInstallment.interest as double;

        loanInstallment.interest = 0;
      } else if (amountToDistribute > 0) {
        paidInterest += amountToDistribute;
        loanInstallment.interest = loanInstallment.interest! - amountToDistribute;
        amountToDistribute = 0;
      }

      installmentPaid.interest = paidInterest;

      if (loanInstallment.capital! <= amountToDistribute) {
        paidCapital = loanInstallment.capital as double;
        amountToDistribute -= loanInstallment.capital as double;

        loanInstallment.capital = 0;
        loanInstallment.Paid();
        installmentPaid.Paid();
      } else if (amountToDistribute > 0) {
        paidCapital += amountToDistribute;
        loanInstallment.capital = loanInstallment.capital! - amountToDistribute;
        amountToDistribute = 0;
      }

      if (loanInstallment.capital!.abs() < 0.99) distribution.paidInstallments = distribution.paidInstallments + 1;

      installmentPaid.capital = paidCapital;
      installmentsPaid.add(installmentPaid);

      if (amountToDistribute.abs() < 0.99) break;
    }

    distribution.installmentsPaid = installmentsPaid;
    distribution.loanExpiredInstallments = loan.installments!
        .where((i) => DateFormat('dd/MM/yyyy').parse(i.date as String).isBefore(DateTime.now()) && !i.paid!)
        .length
        .truncateToDouble();

    return distribution;
  }

  static Future<bool> ProcessPayment(Loan loan, Payment payment) async {
    // var amount = payment.amount as double;
    //
    // loan.delayedAmount = loan.delayedAmount! - amount;
    // final List<Installments> installmentsPaid = [];
    //
    // final notPaidInstallments = loan.installments!.where((installment) => !installment.paid!).toList();
    // notPaidInstallments.sort((a, b) => (a.number!) < (b.number!) ? -1 : 1);
    //
    // for (final loanInstallment in notPaidInstallments) {
    //   var installmentPaid = Installments.fromJson(loanInstallment.toJson());
    //   var paidCharges = 0.0;
    //   var paidCapital = 0.0;
    //   var paidInterest = 0.0;
    //   var paidArrears = 0.0;
    //
    //   if (loanInstallment.charges! <= amount) {
    //     paidCharges = loanInstallment.charges as double;
    //     amount -= loanInstallment.charges as double;
    //     loanInstallment.charges = 0;
    //     installmentPaid.charges = loanInstallment.charges;
    //   } else if (amount > 0) {
    //     paidCharges += amount;
    //     loanInstallment.charges = loanInstallment.charges! - amount;
    //     installmentPaid.charges = amount;
    //     amount = 0;
    //   }
    //
    //   if (loanInstallment.arrears! <= amount) {
    //     paidArrears = loanInstallment.arrears as double;
    //     amount -= loanInstallment.arrears as double;
    //     installmentPaid.arrears = loanInstallment.arrears;
    //     loanInstallment.arrears = 0;
    //   } else if (amount > 0) {
    //     paidArrears += amount;
    //     loanInstallment.arrears = loanInstallment.arrears! - amount;
    //     installmentPaid.arrears = amount;
    //     amount = 0;
    //   }
    //
    //   if (loanInstallment.interest! <= amount) {
    //     paidInterest = loanInstallment.interest as double;
    //     amount -= loanInstallment.interest as double;
    //
    //     loanInstallment.interest = 0;
    //   } else if (amount > 0) {
    //     paidInterest += amount;
    //     loanInstallment.interest = loanInstallment.interest! - amount;
    //     amount = 0;
    //   }
    //
    //   installmentPaid.interest = paidInterest;
    //
    //   if (loanInstallment.capital! <= amount) {
    //     paidCapital = loanInstallment.capital as double;
    //     amount -= loanInstallment.capital as double;
    //
    //     loanInstallment.capital = 0;
    //     loanInstallment.Paid();
    //     installmentPaid.Paid();
    //     if (widget.installment.number == loanInstallment.number) {
    //       setState(() {
    //         widget.installment.Paid();
    //       });
    //     }
    //   } else if (amount > 0) {
    //     paidCapital += amount;
    //     loanInstallment.capital = loanInstallment.capital! - amount;
    //     amount = 0;
    //   }
    //
    //   if (loanInstallment.capital!.abs() < 0.99) loan.paidInstallments = loan.paidInstallments! + 1;
    //
    //   installmentPaid.capital = paidCapital;
    //
    //   installmentsPaid.add(installmentPaid);
    //
    //   // save installment
    //
    //   if (amount.abs() < 0.99) break;
    // }
    //
    // payment.installments = installmentsPaid;
    // loan.expiredInstallments =
    //     loan.installments!.where((i) => DateFormat('dd/MM/yyyy').parse(i.date as String).isBefore(DateTime.now()) && !i.paid!).length;

    final distribution = DistributePayment(loan, payment.amount as double);
    loan.delayedAmount = distribution.loanDelayedAmount;
    loan.expiredInstallments = distribution.loanExpiredInstallments;
    loan.paidInstallments = distribution.paidInstallments;
    payment.installments = distribution.installmentsPaid;
    await payment.SetLocation();

    LoansStorage loansStorage = LoansStorage();
    PaymentStorage paymentStorage = PaymentStorage();

    final loanUpdated = await loansStorage.SaveLoan(loan);
    final savedPayment = await paymentStorage.StorePayment(payment);

    return loanUpdated && savedPayment;
  }

  static Future<bool> PayInstallment({required Loan loan, required Payment payment, BuildContext? context}) async {
    if (context != null) ShowSnackbar(context, 'Procesando pago', Colors.blue, 2);

    final result = await ProcessPayment(loan, payment);
    if (result) {
      if (context != null) {
        ShowSnackbar(context, "Cuota Pagada!", Colors.green);
      }
    } else {
      if (context != null) {
        ShowSnackbar(context, "Error registrando el pago", Colors.red);
      }
    }

    return result;
  }

  static Future<String> FormatStackTrace(StackTrace trace, [String error = '']) async {
    final titlePlaceholder = '##ERROR_TITLE##';
    final tracePlaceholder = '##STACk_TRACE##';
    String template = await GetErrorHTMLTemplate();

    final formatted = Trace.format(trace);
    final separatedStack = formatted.split('\n');

    separatedStack.forEach((line) => '<dd>$line</dd>');

    template = template.replaceFirst(titlePlaceholder, error);
    template = template.replaceFirst(tracePlaceholder, separatedStack.join('<br>'));
    return template;
  }

  static FormatErrorAndSend(String error, StackTrace? trace) async {
    String formattedTrace = '';

    if (trace == null) {
      formattedTrace = 'No Error Trace';
    } else {
      formattedTrace = await FormatStackTrace(trace, error);
    }

    APIEmail.SendErrorEmail(error, formattedTrace);
  }

  static Future<String> GetErrorHTMLTemplate() async {
    final path = 'error_template.html';
    final template = await LoadAsset(path) as String;
    return template;
  }

  static Future<dynamic> LoadAsset(String path) async {
    final asset = await rootBundle.loadString('assets/$path');
    return asset;
  }

  static Future<bool> HasInternetConnectivity() async {
    bool connection = false;

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile) {
      connection = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      connection = true;
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      connection = true;
    }

    return connection;
  }

  static CloseSession() async {
    if (AppNavigatorKey.currentContext != null) {
      Providers.UserState(AppNavigatorKey.currentContext as BuildContext).clearUserData();
      final result = await Navigator.of(AppNavigatorKey.currentContext as BuildContext)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
    }
  }

  static NormalPrint(String title, String content, [bool alignLeft = false]) async {
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
                pw.Text(title, style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Text(content, textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center, style: pw.TextStyle(fontSize: 14))
              ],
            );
          },
        ),
      );

      return doc.save();
    });
  }
}
