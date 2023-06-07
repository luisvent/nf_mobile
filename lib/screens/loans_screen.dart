import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/interface/Loan.dart';
import 'package:nf_mobile/screens/loan_details_screen.dart';
import 'package:nf_mobile/utilities/custom_date_grouping.dart';
import 'package:nf_mobile/utilities/display_error_alert.dart';
import 'package:nf_mobile/utilities/slide_right_route.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:nf_mobile/utilities/widget_factory.dart';

class LoansScreen extends StatefulWidget {
  final Function setTab;
  bool noData = false;
  LoansScreen({Key? key, required this.setTab}) : super(key: key);

  @override
  LoansScreenState createState() => LoansScreenState();
}

class LoansScreenState extends State<LoansScreen> {
  // List<dynamic> allTransactions = [];
  Map<String, dynamic>? error = null;
  late TextEditingController activitySearch;
  List<Loan> paymentLoans = [];
  PaymentStorage paymentStorage = PaymentStorage();
  LoansStorage loansStorage = LoansStorage();

  Widget appBarTitle = Text("Préstamos", style: TextStyle(color: Color(0xff243656)));
  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );
  @override
  void initState() {
    super.initState();
    getPendingPaymentLoans();
    activitySearch = TextEditingController();
    runEmptyLoaderTimeout();
  }

  void runEmptyLoaderTimeout() {
    widget.noData = false;
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (paymentLoans.length == 0) {
        if (mounted)
          setState(() {
            widget.noData = true;
          });
      }
    });
  }

  void getPendingPaymentLoans() async {
    loansStorage.GetPendingPaymentLoansData().then((pendingLoans) {
      setState(() {
        paymentLoans = pendingLoans;
      });
    });
  }

  Future<void> loadLoanInstallments(Loan loan) async {
    final result = await Navigator.push(context, SlideRightRoute(page: LoanDetailsScreen(loan: loan, setTab: widget.setTab)));
    getPendingPaymentLoans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          title: appBarTitle,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  if (actionIcon.icon == FluentIcons.search_24_regular) {
                    setState(() {
                      appBarTitle = Container(
                        height: 48,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(color: Color(0xffF5F7FA), borderRadius: BorderRadius.all(Radius.circular(16.18))),
                        child: TextField(
                          controller: activitySearch,
                          autofocus: true,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (value) {
                            setState(() {});
                          },
                          style: TextStyle(color: Color(0xff929BAB)),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(6.18),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xffF5F7FA), width: 1.618),
                                  borderRadius: BorderRadius.all(Radius.circular(16))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xffF5F7FA), width: 1.618),
                                  borderRadius: BorderRadius.all(Radius.circular(16))),
                              hintText: 'Buscar...',
                              hintStyle: TextStyle(
                                color: Color(0xff929BAB),
                              )),
                        ),
                      );

                      actionIcon = Icon(
                        Icons.close,
                        color: Color(0xff243656),
                      );
                    });
                  } else {
                    activitySearch.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      appBarTitle = Text("Préstamos", style: TextStyle(color: Color(0xff243656)));
                      actionIcon = Icon(
                        FluentIcons.search_24_regular,
                        color: Color(0xff243656),
                      );
                    });
                  }
                },
                icon: actionIcon),
          ],
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
            child: Builder(builder: (context) {
              if (widget.noData) {
                return Center(
                  child: Text('No Hay Préstamos'),
                );
              } else {
                if (error != null) {
                  WidgetsBinding.instance!.addPostFrameCallback((_) => showErrorAlert(context, error!));

                  return WidgetFactory.LoadingList(10);
                } else if (paymentLoans.isEmpty) {
                  return WidgetFactory.LoadingList(10);
                } else if (error == null) {
                  List<dynamic> currentLoans;
                  if (activitySearch.text.isEmpty) {
                    currentLoans = List.from(paymentLoans);
                  } else {
                    List<dynamic> nameMatch =
                        paymentLoans.where((loan) => RegExp("${activitySearch.text.toLowerCase()}").hasMatch(loan.idClient!.toLowerCase())).toList();
                    List<dynamic> dateMatch = paymentLoans
                        .where((loan) => RegExp("${activitySearch.text.toLowerCase()}").hasMatch(
                            dateFormatter(loan.nextPaymentDate as String, DateFormat('dd/mm/yyyy').parse(loan.nextPaymentDate as String))
                                .toLowerCase()))
                        .toList();
                    List<dynamic> amountMatch = paymentLoans
                        .where((loan) => RegExp("${activitySearch.text.toLowerCase()}").hasMatch(loan.amount.toString().toLowerCase()))
                        .toList();
                    currentLoans = [...nameMatch, ...dateMatch, ...amountMatch].toSet().toList();
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: AnimationLimiter(
                      child: GroupedListView<dynamic, String>(
                        padding: EdgeInsets.all(0),
                        groupComparator: (a, b) => customGroupComparator(a, b),
                        useStickyGroupSeparators: false,
                        stickyHeaderBackgroundColor: Color.fromARGB(252, 252, 252, 252),
                        elements: currentLoans,
                        groupBy: (loan) => loan.delayed ? 'En Atraso' : 'Al Día',
                        groupSeparatorBuilder: (String groupByValue) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            groupByValue,
                            style: TextStyle(color: Colors.blueGrey.shade700),
                          ),
                        ),
                        separator: Divider(
                          height: 14,
                          color: Colors.transparent,
                        ),
                        itemComparator: (a, b) =>
                            a.loanApplication.client.fullName.toLowerCase().compareTo(b.loanApplication.client.fullName.toLowerCase()),
                        indexedItemBuilder: (context, loan, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Container(
                                  padding: EdgeInsets.only(left: 15, right: 5, top: 5, bottom: 5),
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          // color: Color(0xffF5F7FA),
                                          // blurRadius: 4,
                                          // offset: Offset(0.0, 3),
                                          // spreadRadius: 0

                                          color: Color(0xff1546a0).withOpacity(0.1),
                                          blurRadius: 48,
                                          offset: Offset(2, 8),
                                          spreadRadius: -10),
                                    ],
                                    color: Colors.white,
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 6.18),
                                    // leading: Container(
                                    //   width: 1,
                                    // ),
                                    title: Text(
                                      'Préstamo #' + loan.idClient,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
                                    ),
                                    subtitle: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                      child: Text(
                                        'Cuotas pendientes: ' + loan.installments.length.toString(),
                                        style: TextStyle(fontSize: 12, color: Color(0xff929BAB)),
                                      ),
                                    ),
                                    trailing: Text(
                                      "\$ ${Tools.FormatCurrency(loan.amount, 0)}",
                                      style: TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.w600, color: !loan.delayed ? Color(0xff37d39b) : Color(0xfff47090)),
                                    ),
                                    onTap: () => {loadLoanInstallments(loan)},
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  return WidgetFactory.LoadingList(10);
                }
              }
            }),
          )),
        ]));
  }
}
