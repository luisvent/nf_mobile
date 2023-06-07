import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/interface/Installments.dart';
import 'package:nf_mobile/screens/payment_screen.dart';
import 'package:nf_mobile/utilities/custom_date_grouping.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:nf_mobile/utilities/widget_factory.dart';

class InstallmentsList extends StatefulWidget {
  final List<Installments> installments;
  late TextEditingController? activitySearch;
  List<bool> activeToggleMenu = [];
  bool loadingInstallments = true;
  bool noData = false;
  int installmentsQuantity = 0;
  Function reloadData;

  InstallmentsList(
      {required this.installments, required this.installmentsQuantity, required this.activeToggleMenu, required this.reloadData, this.activitySearch})
      : super() {}

  @override
  State<InstallmentsList> createState() => _InstallmentsListState();
}

class _InstallmentsListState extends State<InstallmentsList> {
  LoansStorage loansStorage = LoansStorage();

  Future<void> loadPaymentScreen(Installments installment) async {
    final loan = await loansStorage.GetLoan(installment.loanId as int);

    final installmentToOpen;

    if (installment.paid!) {
      installmentToOpen = installment;
    } else {
      final installmentsToBePaid = loan.installments!.where((i) => !i.paid!);
      if (installmentsToBePaid.length == 0) {
        installmentToOpen = installment;
      } else {
        installmentToOpen = installmentsToBePaid.first;
      }
    }

    bool result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentScreen(installment: installmentToOpen, loan: loan)));

    if (result) {
      setState(() {
        widget.reloadData();
      });
    }

    // bool result = await Navigator.push(context,
    //     SlideRightRoute(page: PaymentScreen(installment: installment)));
    // if (result) {
    //   setState(() {});
    // }
  }

  @override
  void initState() {
    super.initState();
    runEmptyLoaderTimeout();
  }

  void runEmptyLoaderTimeout() {
    widget.noData = false;
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (widget.installments.length == 0) {
        if (mounted)
          setState(() {
            widget.noData = true;
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      height: 300,
      width: double.infinity,
      child: Builder(builder: (context) {
        List<dynamic> currentInstallments;
        if (widget.activitySearch != null && widget.activitySearch!.text.isEmpty) {
          currentInstallments = List.from(widget.installments);
        } else {
          currentInstallments = widget.installments;
          // filter installments
        }
        if (widget.activeToggleMenu[1] == true) {
          currentInstallments = currentInstallments.where((installment) => !installment.paid).toList();
        }
        if (widget.activeToggleMenu[2] == true) {
          currentInstallments = currentInstallments.where((installment) => installment.paid).toList();
        }

        if (widget.noData) {
          return Center(
            child: Text('No Hay Cuotas'),
          );
        } else {
          if (widget.installmentsQuantity > 0 && widget.installments.length > 0 && !currentInstallments.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: AnimationLimiter(
                child: GroupedListView<dynamic, String>(
                  padding: EdgeInsets.all(0),
                  groupComparator: (a, b) => customGroupComparator(a, b),
                  useStickyGroupSeparators: false,
                  stickyHeaderBackgroundColor: Color.fromARGB(252, 252, 252, 252),
                  elements: currentInstallments,
                  groupBy: (installment) => installment.loanId.toString(),
                  groupSeparatorBuilder: (String groupByValue) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Préstamo: ' + groupByValue,
                          style: TextStyle(color: Colors.blueGrey.shade700),
                        ),
                        Text(
                          '',
                          style: TextStyle(color: Colors.blueGrey.shade700),
                        ),
                      ],
                    ),
                  ),
                  separator: Divider(
                    height: 14,
                    color: Colors.transparent,
                  ),
                  itemComparator: (a, b) => a.number < b.number ? -1 : 1,
                  indexedItemBuilder: (context, installment, index) {
                    Widget transactionMemberImage = FutureBuilder<int>(
                      builder: (context, snapshot) {
                        return Text(
                          "#" + installment.number.toString(),
                          style: TextStyle(fontSize: 20, color: Color(0xff243656)),
                        );
                      },
                    );
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Hero(
                              tag: 'installment-' + installment.number.toString(),
                              child: Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.symmetric(horizontal: 10),
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
                                        spreadRadius: -10),
                                  ],
                                  color: Colors.white,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 6.18),
                                  leading: CircleAvatar(radius: 38, backgroundColor: Color(0xffF5F7FA), child: transactionMemberImage),
                                  title: Row(
                                    children: [
                                      Text(
                                        '\$' + Tools.FormatCurrency(installment.amount),
                                        style: TextStyle(fontSize: 16.5, color: Colors.blueGrey),
                                      ),
                                      Text(
                                        '  /  ' + '\$' + Tools.FormatCurrency(installment.totalDebt),
                                        style: TextStyle(fontSize: 12, color: Colors.blueGrey[200]),
                                      )
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      'Fecha de Pago: ' + dateFormatter(installment.date, DateFormat('dd/mm/yyyy').parse(installment.date)),
                                      style: TextStyle(fontSize: 12, color: Color(0xff929BAB)),
                                    ),
                                  ),
                                  trailing: Text(
                                    installment.paid ? "Pago" : "Pendiente",
                                    style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600, color: installment.paid ? Color(0xff37d39b) : Color(0xfff47090)),
                                  ),
                                  onTap: () => {loadPaymentScreen(installment)},
                                ),
                              )),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (widget.installmentsQuantity > 0 && widget.installments.length > 0 && currentInstallments.isEmpty) {
            return Center(
              child: Text('No Hay Resultados'),
            );
          } else {
            return WidgetFactory.LoadingList(10);
          }
        }
      }),
    ));
  }
}
