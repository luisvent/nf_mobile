import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:nf_mobile/interface/Installments.dart';
import 'package:nf_mobile/interface/LoanApplication.dart';
import 'package:nf_mobile/interface/LoanInteractions.dart';
import 'package:nf_mobile/interface/LoanNotes.dart';

Loan pendingPaymentLoantFromJson(String str) => Loan.fromJson(json.decode(str));
String pendingPaymentLoantToJson(Loan data) => json.encode(data.toJson());

class Loan {
  Loan({
    num? id,
    String? idClient,
    String? deliveredDate,
    String? startDate,
    double? amount,
    num? statusId,
    String? nextPaymentDate,
    String? lastExpiredPaymentDate,
    bool? delayed,
    bool? toBePaidToday,
    LoanApplication? loanApplication,
    List<Installments>? installments,
    num? totalInstallments,
    num? delayedAmount,
    num? installmentAmount,
    num? expiredInstallments,
    num? paidInstallments,
    List<LoanNotes>? loanNotes,
    List<LoanInteractions>? loanInteractions,
  }) {
    _id = id;
    _idClient = idClient;
    _deliveredDate = deliveredDate;
    _startDate = startDate;
    _amount = amount;
    _statusId = statusId;
    _nextPaymentDate = nextPaymentDate;
    _lastExpiredPaymentDate = lastExpiredPaymentDate;
    _delayed = delayed;
    _toBePaidToday = toBePaidToday;
    _loanApplication = loanApplication;
    _installments = installments;
    _totalInstallments = totalInstallments;
    _delayedAmount = delayedAmount;
    _installmentAmount = installmentAmount;
    _expiredInstallments = expiredInstallments;
    _paidInstallments = paidInstallments;
    _loanNotes = loanNotes;
    _loanInteractions = loanInteractions;
  }

  Loan.fromJson(dynamic json) {
    _id = json['id'];
    _idClient = json['idClient'];
    _deliveredDate = json['deliveredDate'];
    _startDate = json['startDate'];
    _amount = json['amount'];
    _statusId = json['statusId'];
    _nextPaymentDate = json['nextPaymentDate'];
    _lastExpiredPaymentDate = json['lastExpiredPaymentDate'];
    _delayed = json['delayed'];
    _toBePaidToday = json['toBePaidToday'];
    _loanApplication = json['loanApplication'] != null ? LoanApplication.fromJson(json['loanApplication']) : null;
    if (json['installments'] != null) {
      _installments = [];
      json['installments'].forEach((v) {
        _installments?.add(Installments.fromJson(v));
      });
    }
    _totalInstallments = json['totalInstallments'];
    _delayedAmount = json['delayedAmount'];
    _installmentAmount = json['installmentAmount'];
    _expiredInstallments = json['expiredInstallments'];
    _paidInstallments = json['paidInstallments'];
    if (json['loanNotes'] != null) {
      _loanNotes = [];
      json['loanNotes'].forEach((v) {
        _loanNotes?.add(LoanNotes.fromJson(v));
      });
    }
    if (json['loanInteractions'] != null) {
      _loanInteractions = [];
      json['loanInteractions'].forEach((v) {
        _loanInteractions?.add(LoanInteractions.fromJson(v));
      });
    }
  }

  num? _id;
  String? _idClient;
  String? _deliveredDate;
  String? _startDate;
  double? _amount;
  num? _statusId;
  String? _nextPaymentDate;
  String? _lastExpiredPaymentDate;
  bool? _delayed;
  bool? _toBePaidToday;
  LoanApplication? _loanApplication;
  List<Installments>? _installments;
  num? _totalInstallments;
  num? _delayedAmount;
  num? _installmentAmount;
  num? _expiredInstallments;
  num? _paidInstallments;
  List<LoanNotes>? _loanNotes;
  List<LoanInteractions>? _loanInteractions;

  Loan copyWith({
    num? id,
    String? idClient,
    String? deliveredDate,
    String? startDate,
    double? amount,
    num? statusId,
    String? nextPaymentDate,
    String? lastExpiredPaymentDate,
    bool? delayed,
    bool? toBePaidToday,
    LoanApplication? loanApplication,
    List<Installments>? installments,
    num? totalInstallments,
    num? delayedAmount,
    num? installmentAmount,
    num? expiredInstallments,
    num? paidInstallments,
    List<LoanNotes>? loanNotes,
    List<LoanInteractions>? loanInteractions,
  }) =>
      Loan(
        id: id ?? _id,
        idClient: idClient ?? _idClient,
        deliveredDate: deliveredDate ?? _deliveredDate,
        startDate: startDate ?? _startDate,
        amount: amount ?? _amount,
        statusId: statusId ?? _statusId,
        nextPaymentDate: nextPaymentDate ?? _nextPaymentDate,
        lastExpiredPaymentDate: lastExpiredPaymentDate ?? _lastExpiredPaymentDate,
        delayed: delayed ?? _delayed,
        toBePaidToday: toBePaidToday ?? _toBePaidToday,
        loanApplication: loanApplication ?? _loanApplication,
        installments: installments ?? _installments,
        totalInstallments: totalInstallments ?? _totalInstallments,
        delayedAmount: delayedAmount ?? _delayedAmount,
        installmentAmount: installmentAmount ?? _installmentAmount,
        expiredInstallments: expiredInstallments ?? _expiredInstallments,
        paidInstallments: paidInstallments ?? _paidInstallments,
        loanNotes: loanNotes ?? _loanNotes,
        loanInteractions: loanInteractions ?? _loanInteractions,
      );
  num? get id => _id;
  String? get idClient => _idClient;
  String? get deliveredDate => _deliveredDate;
  String? get startDate => _startDate;
  double? get amount => _amount;
  num? get statusId => _statusId;
  String? get nextPaymentDate => _nextPaymentDate;
  String? get lastExpiredPaymentDate => _lastExpiredPaymentDate;
  bool? get delayed => _delayed;
  bool? get toBePaidToday => _toBePaidToday;
  LoanApplication? get loanApplication => _loanApplication;
  List<Installments>? get installments => _installments;
  num? get totalInstallments => _totalInstallments;
  num? get delayedAmount => _delayedAmount;
  num? get installmentAmount => _installmentAmount;
  num? get expiredInstallments => _expiredInstallments;
  num? get paidInstallments => _paidInstallments;
  List<LoanNotes>? get loanNotes => _loanNotes;
  List<LoanInteractions>? get loanInteractions => _loanInteractions;
  double get totalDebt => installments!.map((i) => i.totalDebt).sum;

  void set expiredInstallments(num? ei) {
    _expiredInstallments = ei;
  }

  void set paidInstallments(num? pi) {
    _paidInstallments = pi;
  }

  void set delayedAmount(num? delayedAmount) {
    _delayedAmount = delayedAmount;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['idClient'] = _idClient;
    map['deliveredDate'] = _deliveredDate;
    map['startDate'] = _startDate;
    map['amount'] = _amount;
    map['statusId'] = _statusId;
    map['nextPaymentDate'] = _nextPaymentDate;
    map['lastExpiredPaymentDate'] = _lastExpiredPaymentDate;
    map['delayed'] = _delayed;
    map['toBePaidToday'] = _toBePaidToday;
    if (_loanApplication != null) {
      map['loanApplication'] = _loanApplication?.toJson();
    }
    if (_installments != null) {
      map['installments'] = _installments?.map((v) => v.toJson()).toList();
    }
    map['totalInstallments'] = _totalInstallments;
    map['delayedAmount'] = _delayedAmount;
    map['installmentAmount'] = _installmentAmount;
    map['expiredInstallments'] = _expiredInstallments;
    map['paidInstallments'] = _paidInstallments;
    if (_loanNotes != null) {
      map['loanNotes'] = _loanNotes?.map((v) => v.toJson()).toList();
    }
    if (_loanInteractions != null) {
      map['loanInteractions'] = _loanInteractions?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
