import 'package:nf_mobile/database/storage_manager.dart';
import 'package:nf_mobile/interface/Payment.dart';

class PaymentStorage extends StorageManager {
  var filename = 'payments_data';

  PaymentStorage() : super();

  Future<bool> StorePayment(Payment payment) async {
    var payments = await GetPaymentsData();
    payments.add(payment);
    return StoreData(payments);
  }

  Future<bool> StorePayments(List<Payment> paymentsToStore) async {
    var payments = await GetPaymentsData();
    paymentsToStore.forEach((payment) {
      payments.add(payment);
    });
    return StoreData(payments);
  }

  Future<List<Payment>> GetPaymentsData() async {
    final storeData = await GetData();
    print(storeData);
    final data = storeData.error ? null : storeData.data;

    if (data != null) {
      return data.map<Payment>((e) => new Payment.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<Payment>> GetPaymentsForInstallment(int installmentId) async {
    final allPayments = await GetPaymentsData();
    final payments = allPayments.where((p) => p.installments!.map((i) => i.id).contains(installmentId)).toList();
    return payments;
  }

  Future<List<Payment>> GetPaymentsForLoan(int loanId) async {
    final allPayments = await GetPaymentsData();
    final payments = allPayments.where((p) => p.loanId == loanId).toList();
    return payments;
  }

  Future<Payment> GetPayment(String code) async {
    final allPayments = await GetPaymentsData();
    final payment = allPayments.firstWhere((p) => p.code == code);
    return payment;
  }
}
