import 'package:collection/collection.dart';
import 'package:nf_mobile/interface/Installments.dart';

class PaymentDistribution {
  PaymentDistribution();

  late List<Installments> installmentsPaid = [];

  late double loanDelayedAmount = 0;
  late double loanExpiredInstallments = 0;
  late int paidInstallments = 0;
  late double amountPaid = 0;

  double get paidCharges => installmentsPaid.map((i) => i.charges as double).sum;
  double get paidCapital => installmentsPaid.map((i) => i.capital as double).sum;
  double get paidInterest => installmentsPaid.map((i) => i.interest as double).sum;
  double get paidArrears => installmentsPaid.map((i) => i.arrears as double).sum;
}
