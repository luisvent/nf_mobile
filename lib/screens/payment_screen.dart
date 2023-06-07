import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nf_mobile/components/payment_receipt/receipt.dart';
import 'package:nf_mobile/interface/Installments.dart';
import 'package:nf_mobile/interface/Loan.dart';

class PaymentScreen extends StatefulWidget {
  final Installments installment;
  final Loan loan;

  PaymentScreen({Key? key, required this.installment, required this.loan}) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late TextEditingController activitySearch;
  Widget appBarTitle = Text("Pagar Cuota", style: TextStyle(color: Color(0xff243656)));
  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );
  @override
  void initState() {
    super.initState();
    activitySearch = TextEditingController();
  }

  void goBack() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                goBack();
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
              child: Hero(
            tag: 'installment-' + widget.installment.number.toString(),
            child: Container(
                height: 300,
                width: double.infinity,
                child:

                    // Container(
                    //   width: 100,
                    //   decoration: BoxDecoration(
                    //     gradient: RadialGradient(
                    //         colors: [Color(0xff495057), Colors.blueGrey.shade300],
                    //         radius: 0.625),
                    //   ),
                    // )

                    PaymentReceipt(installment: widget.installment, loan: widget.loan)),
          )),
        ]));
  }
}
