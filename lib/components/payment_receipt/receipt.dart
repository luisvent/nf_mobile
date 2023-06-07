import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/interface/Installments.dart';
import 'package:nf_mobile/interface/Loan.dart';
import 'package:nf_mobile/interface/Payment.dart';
import 'package:nf_mobile/interface/Settings.dart';
import 'package:nf_mobile/resources/constants.dart';
import 'package:nf_mobile/screens/pay_loan_screen.dart';
import 'package:nf_mobile/screens/ticket_screen.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/slide_up_route.dart';
import 'package:nf_mobile/utilities/tools.dart';

class PaymentReceipt extends StatefulWidget {
  Payment payment = Payment.Empty();
  Installments installment;
  final Loan loan;
  bool isOldestInstallment = false;
  LoansStorage loansStorage = LoansStorage();
  PaymentStorage paymentStorage = PaymentStorage();

  PaymentReceipt({required this.installment, required this.loan}) : super() {}

  @override
  State<PaymentReceipt> createState() => _PaymentReceiptState();
}

class _PaymentReceiptState extends State<PaymentReceipt> {
  String userName = '';
  bool initiated = false;
  Settings settings = Settings.Empty();

  @override
  void initState() {
    super.initState();

    if (!mounted) return;
    getUserName();
    getSettings();
    createPayment();
    print(widget.installment.paid);
  }

  Future<void> createPayment() async {
    setState(() {
      widget.payment = Payment(loan: widget.loan, context: context);
    });
  }

  paymentCompleted(bool completed) async {
    refreshInstallment();
    showReceiptAfterPayment();

    if (settings.operationMode == OperationMode.Online) {
      Providers.Sync(context).SendLoanTransactions();
    }
  }

  getSettings() async {
    settings = await Providers.Settings(context).GetSettings();
  }

  showReceiptAfterPayment() async {
    Future.delayed(const Duration(milliseconds: 600), () async {
      final settings = await Providers.Settings(context).GetSettings();
      if (settings.showReceiptAfterPayment) {
        openReceipt();
      }
    });
  }

  Future<void> getUserName() async {
    final userData = await Providers.UserState(context).userData;
    setState(() {
      userName = userData!.fullname;
    });
  }

  refreshInstallment() async {
    final loan = await widget.loansStorage.GetLoan(widget.installment.loanId as int);
    setState(() {
      widget.installment = loan.installments!.firstWhere((i) => i.id == widget.installment.id);
    });
  }

  openReceipt() async {
    final payments = await widget.paymentStorage.GetPaymentsForInstallment(widget.installment.id as int);
    Navigator.push(context, SlideUpRoute(page: TicketScreen(payments: payments)));
  }

  Future<bool> ableToPay() async {
    if (settings.operationMode == OperationMode.Online) {
      final connectivity = await Tools.HasInternetConnectivity();

      if (!connectivity) {
        Tools.ShowSnackbar(context, 'No hay conexión a Internet', Colors.red, 4);
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  String _formatParticipantName(String name) {
    String formattedVersion = name;
    if (name.length > 26) {
      formattedVersion = name.substring(0, 23) + "...";
    }
    return formattedVersion;
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) =>
    //     Provider.of<LiveTransactionsProvider>(context, listen: false)
    //         .removeUnreadTransaction());

    double screenWidth = MediaQuery.of(context).size.width;

    TextStyle _receiptHeaders = GoogleFonts.lato(color: Color(0xff929bab), fontSize: screenWidth < 380 ? 14 : 16);
    TextStyle _receiptValues = GoogleFonts.chivo(fontSize: screenWidth < 380 ? 15 : 15, color: Color(0xff343a40), fontWeight: FontWeight.bold);

    return Scaffold(
        backgroundColor: Colors.blueGrey.shade300,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [Color(0xff495057), Colors.blueGrey.shade300], radius: 0.625),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                ),
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    ClipPath(
                      clipper: ReceiptClipper(),
                      child: Container(
                        // height: MediaQuery.of(context).size.height -36,
                        height: 618,
                        width: screenWidth - 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                        ),
                      ),
                    ),

                    widget.installment.totalDebt == 0
                        ? Positioned(
                            top: -40,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 39,
                              child: CircleAvatar(
                                child: Image.asset(
                                  'assets/images/checkmark.png',
                                ),
                                radius: 36,
                              ),
                            ))
                        : Container(),

                    Positioned(
                      top: 155,
                      child: DottedLine(
                        direction: Axis.horizontal,
                        lineLength: screenWidth - 120,
                        lineThickness: 2.4,
                        dashLength: 12,
                        dashColor: Colors.grey.shade500,
                        dashRadius: 0.0,
                        dashGapLength: 3.0,
                        dashGapColor: Colors.transparent,
                        dashGapRadius: 0.0,
                      ),
                    ),

                    //? RECEIPT HEADER ↴
                    Positioned(
                        top: 38,
                        child: Wrap(
                          direction: Axis.vertical,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 3.6,
                          children: [
                            Text(Constants.CompanyName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.heebo(fontSize: 24, color: Color(0xff343a40), fontWeight: FontWeight.bold)),
                            Text(
                              '${Constants.CompanyAddress}\n${Constants.CompanyPhoneNumber}\n${widget.payment.date}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.sarabun(
                                color: Color(0xff929bab),
                              ),
                            ),
                            Text(
                              '# de Recibo: ' + (widget.payment.code as String),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.sarabun(
                                color: Color(0xff929bab),
                              ),
                            )
                          ],
                        )),

                    //? RECEIPT BODY ↴
                    Positioned(
                        top: 180,
                        child: Container(
                          width: screenWidth - 120,
                          color: Colors.transparent,
                          child: Wrap(
                            direction: Axis.vertical,
                            spacing: 14,
                            children: [
                              //? DATE AND TIME OF TRANSACTION ↴
                              Container(
                                width: screenWidth - 120,
                                color: Colors.transparent,
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      direction: Axis.vertical,
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      spacing: 3.6,
                                      children: [
                                        Text('CLIENTE', style: _receiptHeaders),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width / 2.4,
                                          child: Text(
                                            widget.loan.loanApplication!.client!.fullName.toString(),
                                            style: _receiptValues,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      direction: Axis.vertical,
                                      crossAxisAlignment: WrapCrossAlignment.end,
                                      spacing: 3.6,
                                      children: [
                                        Text(
                                          'PRESTAMO #',
                                          style: _receiptHeaders,
                                        ),
                                        Text(
                                          widget.loan.id.toString(),
                                          style: _receiptValues,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              //? INFO AND SENDER OR RECEIPIENT ↴
                              Container(
                                width: screenWidth - 120,
                                color: Colors.transparent,
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      direction: Axis.vertical,
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      spacing: 1.6,
                                      children: [
                                        Text('CUOTA #', style: _receiptHeaders),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width / 2.4,
                                          child: Text(
                                            _formatParticipantName(widget.installment.number.toString()),
                                            style: _receiptValues,
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width,
                                            child: Text(
                                              'Monto Cuota: \$ ' + Tools.FormatCurrency(widget.installment.amount!.truncateToDouble()),
                                              style: GoogleFonts.sarabun(color: Color(0xff929bab), fontWeight: FontWeight.bold, fontSize: 13),
                                            ))
                                      ],
                                    ),
                                    Wrap(
                                      direction: Axis.vertical,
                                      crossAxisAlignment: WrapCrossAlignment.end,
                                      spacing: 3.6,
                                      children: [],
                                    ),
                                  ],
                                ),
                              ),
                              //? TRANSACTION AMOUNT ---  ↔  --- TRANSACTION STATUS ↴
                              Container(
                                width: screenWidth - 120,
                                color: Colors.transparent,
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      direction: Axis.vertical,
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      spacing: 3.6,
                                      children: [
                                        Text('MONTO A PAGAR', style: _receiptHeaders),
                                        Text(
                                          '\$ ${Tools.FormatCurrency((widget.installment.totalDebt))}',
                                          style: GoogleFonts.oswald(fontSize: 32, color: Color(0xff343a40), fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      direction: Axis.vertical,
                                      crossAxisAlignment: WrapCrossAlignment.end,
                                      spacing: 3.6,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(7.2),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: widget.installment.totalDebt == 0 ? Color(0xff76c893) : Colors.grey),
                                              borderRadius: BorderRadius.circular(6.18)),
                                          child: Text(
                                            widget.installment.totalDebt == 0 ? 'Pagado' : 'No Pago',
                                            style: GoogleFonts.quicksand(
                                                color: widget.installment.totalDebt == 0 ? Color(0xff76c893) : Colors.grey, fontSize: 12.84),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    Positioned(
                        bottom: 80,
                        child: Container(
                            height: 100,
                            width: screenWidth - 96,
                            decoration: BoxDecoration(color: Color(0xffbde0fe).withOpacity(0.618), borderRadius: BorderRadius.circular(7)),
                            // child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Wrap(
                              spacing: 6.4,
                              runSpacing: 6.4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runAlignment: WrapAlignment.center,
                              direction: Axis.horizontal,
                              children: [
                                Container(
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    spacing: 7.2,
                                    children: [
                                      Text(
                                        ' Capital: \$${Tools.FormatCurrency(widget.installment.capital!)}\n Interes: \$${Tools.FormatCurrency(widget.installment.interest!)}\n Mora: \$${Tools.FormatCurrency(widget.installment.arrears!)}',
                                        style: GoogleFonts.heebo(fontSize: 13, color: Colors.grey),
                                      ),
                                      Text(
                                        userName,
                                        style: GoogleFonts.heebo(fontSize: 18, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            // ),
                            )),
                    Positioned(
                        bottom: 15,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (widget.installment.totalDebt > 0)
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      label: Text(
                                        "Pagar Cuota",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Color(0xFF0070BA),
                                        side: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.attach_money_outlined,
                                        size: 24.0,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        final ableToPayment = await ableToPay();
                                        if (!ableToPayment) {
                                          return;
                                        }

                                        widget.payment.amount = widget.installment.totalDebt;
                                        final result = await Tools.PayInstallment(loan: widget.loan, payment: widget.payment, context: context);
                                        print(widget.loan.totalDebt);
                                        paymentCompleted(result);
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    OutlinedButton.icon(
                                      label: Text(
                                        "Otro Monto",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Color(0xFF0070BA),
                                        side: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.money,
                                        size: 24.0,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        final ableToPayment = await ableToPay();
                                        if (!ableToPayment) {
                                          return;
                                        }

                                        final result = await Navigator.push(context, SlideUpRoute(page: PayLoanScreen(loan: widget.loan)));
                                        paymentCompleted(true);
                                      },
                                    )
                                  ],
                                ),
                              if (widget.installment.totalDebt == 0)
                                OutlinedButton.icon(
                                  label: Text("Ver Recibo"),
                                  icon: Icon(
                                    Icons.receipt_long_outlined,
                                    size: 24.0,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    primary: Color(0xff8bb9df),
                                    side: BorderSide(
                                      color: Color(0xff8bb9df),
                                    ),
                                  ),
                                  onPressed: () {
                                    openReceipt();
                                  },
                                )
                            ],
                          ),
                        ))
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 140)
      ..cubicTo(size.width * .92, 140, size.width * .92, 170, size.width, 170)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, 170)
      ..cubicTo(size.width * .08, 170, size.width * .08, 140, 0, 140)
      ..lineTo(0, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
