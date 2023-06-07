import 'package:flutter/foundation.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:nf_mobile/database/loan_interaction_storage.dart';
import 'package:nf_mobile/database/loan_note_storage.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/User.dart';

class UserStateProvider with ChangeNotifier {
  User? userData;
  UserDataStorage userDataStorage = UserDataStorage();
  LoansStorage loansStorage = LoansStorage();
  PaymentStorage paymentStorage = PaymentStorage();
  LoanNoteStorage loanNoteStorage = LoanNoteStorage();
  LoanInteractionStorage loanInteractionStorage = LoanInteractionStorage();

  Future<bool> isUserLoggedIn() async {
    final userData = await UserDataStorage().GetUserData();
    return userData != null && userData.id > 0;
  }

  Future<bool> isTokenExpired() async {
    final userData = await UserDataStorage().GetUserData();
    if (userData != null) {
      bool hasExpired = Jwt.isExpired(userData.token);
      return hasExpired;
    } else {
      return true;
    }
  }

  Future<bool> isSessionActive() async {
    final userLoggedIn = await isUserLoggedIn();
    final tokenExpired = await isTokenExpired();

    return userLoggedIn && !tokenExpired;
  }

  Future<bool> logOutUser() async {
    final userClear = await clearUserData();
    final results = await clearData();
    return (results && userClear);
  }

  Future<bool> clearUserData() async {
    return userDataStorage.DeleteFile();
  }

  Future<bool> clearData() async {
    final results = await Future.wait(
        [loansStorage.DeleteFile(), paymentStorage.DeleteFile(), loanInteractionStorage.DeleteFile(), loanNoteStorage.DeleteFile()]);

    return !results.any((result) => !result);
  }
}
