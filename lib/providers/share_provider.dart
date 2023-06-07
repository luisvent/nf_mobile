import 'package:flutter/foundation.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/database/user_data_storage.dart';

class ShareProvider with ChangeNotifier {
  UserDataStorage userDataStorage = UserDataStorage();
  LoansStorage loansStorage = LoansStorage();
  PaymentStorage paymentStorage = PaymentStorage();

  Future<bool> Share(dynamic data) async {
    return true;
  }
}
