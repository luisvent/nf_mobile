import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/Activity.dart';
import 'package:nf_mobile/interface/Installments.dart';
import 'package:nf_mobile/interface/Loan.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';

class Payment {
  Payment({Loan? loan, BuildContext? context}) {
    _empty();
    GenerateCode(context);
    if (loan != null) {
      SetLoan(loan: loan, context: context);
    }
  }

  Payment.Empty() {
    _empty();
  }

  Payment.fromJson(dynamic json) {
    id = json['id'];
    employeeId = json['employeeId'];
    date = json['date'];
    loanId = json['loanId'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    code = json['code'];
    amount = json['amount'];
    synced = json['synced'] == null ? false : json['synced'];
    printed = json['printed'] == null ? false : json['printed'];
    if (json['installments'] != null) {
      installments = [];
      json['installments'].forEach((v) {
        installments?.add(Installments.fromJson(v));
      });
    }
    loanAmount = json['loanAmount'];
    loanInstallments = json['loanInstallments'];
    loanDebtBeforePayment = json['loanDebtBeforePayment'];
    clientName = json['clientName'];
    clientBusiness = json['clientBusiness'];
  }

  _empty() {
    id = 0;
    employeeId = 0;
    date = Tools.LongDate();
    loanId = 0;
    latitude = 0;
    longitude = 0;
    code = '';
    amount = 0;
    synced = false;
    printed = false;
    installments = [];
    loanAmount = 0;
    loanInstallments = 0;
    clientName = '';
    clientBusiness = '';
    loanDebtBeforePayment = 0;
  }

  num id = 0;
  late num loanId = 0;
  late String code = '';
  late int employeeId = 0;
  late String date = Tools.LongDate();
  late num amount = 0;
  late num longitude = 0;
  late num latitude = 0;
  late bool synced = false;
  late bool printed = false;
  late List<Installments>? installments;
  late double loanAmount = 0;
  late int loanInstallments = 0;
  late double loanDebtBeforePayment = 0;
  late String clientName;
  late String clientBusiness;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['employeeId'] = employeeId;
    map['date'] = date;
    map['loanId'] = loanId;
    map['code'] = code;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['amount'] = amount;
    map['synced'] = synced;
    map['printed'] = printed;
    if (installments != null) {
      map['installments'] = installments?.map((v) => v.toJson()).toList();
    }
    map['loanAmount'] = loanAmount;
    map['loanInstallments'] = loanInstallments;
    map['loanDebtBeforePayment'] = loanDebtBeforePayment;
    map['clientName'] = clientName;
    map['clientBusiness'] = clientBusiness;
    return map;
  }

  Future<void> GenerateCode(BuildContext? context) async {
    var userData;
    if (context != null) {
      userData = Providers.UserState(context).userData;
    } else {
      UserDataStorage userDataStorage = UserDataStorage();
      userData = await userDataStorage.GetUserData();
    }
    code = '${userData!.id.toString()}${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}';
  }

  Activity ToActivity() {
    return Activity(
        id: code,
        type: Activity.Payment,
        title: 'Préstamo #${loanId} - Recibo:${code}',
        message: date.toString(),
        trail: '\$ ${Tools.FormatCurrency(amount)}',
        date: date,
        icon: Icons.payments_rounded,
        latitude: latitude as double,
        longitude: longitude as double);
  }

  Future<void> SetLoan({required Loan loan, BuildContext? context}) async {
    var userData;
    if (context != null) {
      userData = Providers.UserState(context).userData;
    } else {
      UserDataStorage userDataStorage = UserDataStorage();
      userData = await userDataStorage.GetUserData();
    }
    loanId = loan.id as int;
    date = Tools.LongDate();
    employeeId = userData!.id;
    printed = true;
    loanInstallments = loan.totalInstallments! as int;
    loanAmount = loan.amount!;
    loanDebtBeforePayment = loan.totalDebt;
    clientName = loan.loanApplication!.client!.fullName as String;
    clientBusiness = loan.loanApplication!.client!.businessName as String;
  }

  Future<bool> SetLocation() async {
    final location = await Tools.GetLocation();
    latitude = location.latitude;
    longitude = location.longitude;
    return true;
  }
}
