import 'package:nf_mobile/api/api.manager.dart';
import 'package:nf_mobile/interface/LoanInteractions.dart';
import 'package:nf_mobile/interface/LoanNotes.dart';
import 'package:nf_mobile/interface/Payment.dart';
import 'package:nf_mobile/interface/RequestData.dart';

import '../resources/constants.dart';

class APITransactions {
  static const controller = 'MobileTransactions';
  static String API_URL = "${Constants.baseUrl}${controller}/";

  static Future<RequestData> SaveTransactions(int userId, List<Payment> payments) async {
    final transaction = {'employeeId': userId, 'payments': payments, 'bankDeposits': [], 'officeDeposits': [], 'deliveredLoans': []};

    final response = await APIManager.PostData(urlPath: API_URL + 'SaveTransactions', data: transaction);

    return response;
  }

  static Future<RequestData> SaveLoanNotes(List<LoanNotes> notes) async {
    final notesToSend = notes.map((n) => n.toJson()).toList();

    final response = await APIManager.PostData(urlPath: API_URL + 'AddLoanNotes', data: notesToSend);

    return response;
  }

  static Future<RequestData> SaveLoanInteractions(List<LoanInteractions> interactions) async {
    final interactionsToSend = interactions.map((n) => n.toJson()).toList();

    final response = await APIManager.PostData(urlPath: API_URL + 'AddLoanInteractions', data: interactionsToSend);

    return response;
  }

  static Future<RequestData> SaveTransaction(int userId, Payment payment) async {
    return SaveTransactions(userId, [payment]);
  }

  static Future<RequestData> GetPendingPaymentLoans(int userId) async {
    final response = await APIManager.GetData(urlPath: API_URL + 'GetPendingPaymentLoans/' + userId.toString());

    //region MOCK
    // final result = new RequestData();
    // result.data = ApiConstants.pendingPayments;
    // result.error = false;
    // return result;
    //endregion
    return response;
  }
}
