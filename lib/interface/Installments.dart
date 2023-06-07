import 'dart:convert';

Installments installmentsFromJson(String str) => Installments.fromJson(json.decode(str));
String installmentsToJson(Installments data) => json.encode(data.toJson());

class Installments {
  Installments({
    num? id,
    num? number,
    num? loanId,
    String? date,
    num? amount,
    double? capital,
    double? interest,
    double? arrears,
    double? charges,
    bool? paid,
  }) {
    _id = id;
    _number = number;
    _loanId = loanId;
    _date = date;
    _amount = amount;
    _capital = capital;
    _interest = interest;
    _arrears = arrears;
    _paid = paid;
    _charges = charges;
  }

  Installments.fromJson(dynamic json) {
    _id = json['id'];
    _number = json['number'];
    _loanId = json['loanId'];
    _date = json['date'];
    _amount = json['amount'];
    _capital = (json['capital'] as num).truncateToDouble();
    _interest = (json['interest'] as num).truncateToDouble();
    _arrears = (json['arrears'] as num).truncateToDouble();
    _charges = (json['charges'] as num).truncateToDouble();
    _paid = json['paid'] == null ? false : json['paid'];
  }
  num? _id;
  num? _number;
  num? _loanId;
  String? _date;
  num? _amount;
  double? _capital;
  double? _interest;
  double? _arrears;
  double? _charges;
  bool? _paid;

  Installments copyWith({
    num? id,
    num? number,
    num? loanId,
    String? date,
    num? amount,
    double? capital,
    double? interest,
    double? arrears,
    double? charges,
    bool? paid,
  }) =>
      Installments(
        id: id ?? _id,
        number: number ?? _number,
        loanId: loanId ?? _loanId,
        date: date ?? _date,
        amount: amount ?? _amount,
        capital: capital ?? _capital,
        interest: interest ?? _interest,
        arrears: arrears ?? _arrears,
        charges: charges ?? _charges,
        paid: paid ?? _paid,
      );
  num? get id => _id;
  num? get number => _number;
  num? get loanId => _loanId;
  String? get date => _date;
  num? get amount => _amount;
  double? get capital => _capital;
  double? get interest => _interest;
  double? get arrears => _arrears;
  double? get charges => _charges;
  bool? get paid => _paid;
  double get totalDebt => _capital! + _charges! + _interest! + _arrears!;

  void set capital(double? c) {
    _capital = c;
  }

  void set arrears(double? a) {
    _arrears = a;
  }

  void set interest(double? i) {
    _interest = i;
  }

  void set charges(double? c) {
    _charges = c;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['number'] = _number;
    map['loanId'] = _loanId;
    map['date'] = _date;
    map['amount'] = _amount;
    map['capital'] = _capital;
    map['interest'] = _interest;
    map['arrears'] = _arrears;
    map['charges'] = _charges;
    map['paid'] = _paid;
    return map;
  }

  Paid() {
    _paid = true;
  }
}
