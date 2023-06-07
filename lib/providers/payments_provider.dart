import 'package:flutter/foundation.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/database/user_data_storage.dart';

class PaymentsProvider with ChangeNotifier {
  dynamic pendingPayments;
  dynamic payments;
  PaymentStorage paymentStorage = PaymentStorage();
  UserDataStorage userDataStorage = UserDataStorage();
  LoansStorage loansStorage = LoansStorage();
}
