import 'package:nf_mobile/database/storage_manager.dart';
import 'package:nf_mobile/interface/Installments.dart';
import 'package:nf_mobile/interface/Loan.dart';

class LoansStorage extends StorageManager {
  var filename = 'pending_payment_loans_data';

  LoansStorage() : super();

  Future<bool> StorePendingPayments(dynamic paymentsData) {
    return StoreData(paymentsData);
  }

  Future<List<Loan>> GetPendingPaymentLoansData() async {
    final storeData = await GetData();
    print('GetPendingPaymentLoansData');
    print(storeData);

    if (storeData.error) {
      return [];
    } else {
      return storeData.data.map<Loan>((e) => new Loan.fromJson(e)).toList();
    }
  }

  Future<bool> SaveLoan(Loan loanToSave) async {
    print('SaveLoan');
    print('save loan');
    final loans = await GetPendingPaymentLoansData();
    loans.removeWhere((loan) => loan.id == loanToSave.id);
    loans.add(loanToSave);
    return StorePendingPayments(loans);
  }

  Future<Loan> GetLoan(int loanId) async {
    print('GetLoan');
    final loans = await GetPendingPaymentLoansData();
    return loans.firstWhere((loan) => loan.id == loanId);
  }

  Future<List<Installments>> GetInstallments() async {
    final pendingPaymentLoans = await GetPendingPaymentLoansData();
    return pendingPaymentLoans.map((p) => p.installments).expand<Installments>((i) => i as List<Installments>).toList();
  }
}
