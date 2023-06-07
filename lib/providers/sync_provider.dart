import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nf_mobile/api/api.mobile_transactions.dart';
import 'package:nf_mobile/database/backup_storage.dart';
import 'package:nf_mobile/database/loan_interaction_storage.dart';
import 'package:nf_mobile/database/loan_note_storage.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/database/settings_storage.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/Loan.dart';
import 'package:nf_mobile/interface/LoanInteractions.dart';
import 'package:nf_mobile/interface/LoanNotes.dart';
import 'package:nf_mobile/interface/Payment.dart';
import 'package:nf_mobile/interface/Settings.dart';
import 'package:nf_mobile/utilities/tools.dart';

class SyncProvider with ChangeNotifier {
  bool sendDisabled = false;
  DateTime lastSyncDate = DateTime.now();
  bool syncError = false;
  bool syncing = false;
  bool allSynced = true;
  UserDataStorage userDataStorage = UserDataStorage();
  LoansStorage loansStorage = LoansStorage();
  PaymentStorage paymentStorage = PaymentStorage();
  LoanNoteStorage loanNoteStorage = LoanNoteStorage();
  LoanInteractionStorage loanInteractionStorage = LoanInteractionStorage();
  SettingsStorage settingsStorage = SettingsStorage();

  Future<bool> GetData() async {
    bool error = false;
    final clear = await LoansStorage().DeleteFile();
    int userId = await userDataStorage.getUserId();
    var pendingPaymentsData = await APITransactions.GetPendingPaymentLoans(userId);

    if (!pendingPaymentsData.error) {
      try {
        dynamic pendingPayments = (pendingPaymentsData.data as List<dynamic>);
        pendingPayments.forEach((loan) => Loan.fromJson(loan));
        error = !await loansStorage.StorePendingPayments(pendingPayments);
      } catch (e) {
        error = true;
      }
    } else {
      error = true;
    }

    return !error;
  }

  Future<bool> SendLoanTransactions([List<Payment>? payments]) async {
    if (sendDisabled) return true;

    final settings = await settingsStorage.GetSettings();
    if (settings.operationMode == OperationMode.Online) {
      Tools.ShowLoading();
    }

    bool error = false;
    int userId = await userDataStorage.getUserId();
    payments = payments == null ? await paymentStorage.GetPaymentsData() : payments;
    var paymentsToSync = payments.where((payment) => !payment.synced).toList();

    if (paymentsToSync.length == 0) {
      Tools.HideLoading();
      return true;
    }
    try {
      var sentResponse = await APITransactions.SaveTransactions(userId, paymentsToSync);

      if (!sentResponse.error) {
        // update synced payments
        paymentsToSync.forEach((payment) {
          payment.synced = true;
        });
        DateTime toTime = new DateTime.now();

        payments.removeWhere((payment) =>
            paymentsToSync.map((p) => p.code).contains(payment.code) ||
            DateFormat('dd/MM/yyyy h:mm a').parse(payment.date).isBefore(new DateTime(toTime.year, toTime.month, toTime.day)));
        payments.addAll(paymentsToSync);
        final clearPayments = await paymentStorage.DeleteFile();
        final paymentsSaved = await paymentStorage.StorePayments(payments);
      }

      error = sentResponse.error;
    } catch (e) {
      error = true;
    }

    Tools.HideLoading();
    return !error;
  }

  Future<bool> SendLoanNotes([List<LoanNotes>? notes]) async {
    if (sendDisabled) return true;

    final settings = await settingsStorage.GetSettings();
    if (settings.operationMode == OperationMode.Online) {
      Tools.ShowLoading();
    }

    bool error = false;
    notes = notes == null ? await loanNoteStorage.GetNotesData() : notes;
    var notesToSync = notes.where((note) => !note.synced).toList();

    if (notesToSync.length == 0) {
      Tools.HideLoading();
      return true;
    }

    try {
      var sentResponse = await APITransactions.SaveLoanNotes(notesToSync);

      if (!sentResponse.error) {
        // update synced payments
        notesToSync.forEach((note) {
          note.synced = true;
        });
        DateTime toTime = new DateTime.now();

        notes.removeWhere((note) =>
            notesToSync.map((n) => n.date).contains(note.date) ||
            DateFormat('dd/MM/yyyy h:mm a').parse(note.date!).isBefore(new DateTime(toTime.year, toTime.month, toTime.day)));
        notes.addAll(notesToSync);
        final clearPayments = await loanNoteStorage.DeleteFile();
        final paymentsSaved = await loanNoteStorage.AddLoanNotes(notes);
      }

      error = sentResponse.error;
    } catch (e) {
      error = true;
    }

    Tools.HideLoading();
    return !error;
  }

  Future<bool> SendLoanInteractions([List<LoanInteractions>? interactions]) async {
    if (sendDisabled) return true;

    final settings = await settingsStorage.GetSettings();
    if (settings.operationMode == OperationMode.Online) {
      Tools.ShowLoading();
    }

    bool error = false;
    interactions = interactions == null ? await loanInteractionStorage.GetInteractionsData() : interactions;
    var interactionsToSync = interactions.where((note) => !note.synced).toList();

    if (interactionsToSync.length == 0) {
      Tools.HideLoading();
      return true;
    }

    try {
      var sentResponse = await APITransactions.SaveLoanInteractions(interactionsToSync);

      if (!sentResponse.error) {
        // update synced payments
        interactionsToSync.forEach((interaction) {
          interaction.synced = true;
        });
        DateTime toTime = new DateTime.now();

        interactions.removeWhere((interaction) =>
            interactionsToSync.map((n) => n.date).contains(interaction.date) ||
            DateFormat('dd/MM/yyyy h:mm a').parse(interaction.date!).isBefore(new DateTime(toTime.year, toTime.month, toTime.day)));
        interactions.addAll(interactionsToSync);
        final clearInteractions = await loanInteractionStorage.DeleteFile();
        final interactionsSaved = await loanInteractionStorage.AddLoanInteractions(interactions);
      }

      error = sentResponse.error;
    } catch (e) {
      error = true;
    }

    Tools.HideLoading();
    return !error;
  }

  Future<bool> SyncData() async {
    syncing = true;
    // read data
    final payments = await paymentStorage.GetPaymentsData();
    final notes = await loanNoteStorage.GetNotesData();
    final interactions = await loanInteractionStorage.GetInteractionsData();

    // backup data
    BackupStorage backupStorage = BackupStorage();
    final backupSaved = backupStorage.SaveData(payments: payments, notes: notes, interactions: interactions);

    // save data
    final loanTransactionsSent = await SendLoanTransactions(payments);
    final loanNotesSent = await SendLoanNotes(notes);
    final loanInteractionsSent = await SendLoanInteractions(interactions);

    // get new data
    final dataObtained = await GetData();

    syncError = !(loanTransactionsSent && loanNotesSent && loanInteractionsSent && dataObtained);
    lastSyncDate = DateTime.now();
    syncing = false;
    allSynced = !syncError;
    return !syncError;
  }
}
