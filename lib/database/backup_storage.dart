import 'package:nf_mobile/database/storage_manager.dart';
import 'package:nf_mobile/interface/LoanInteractions.dart';
import 'package:nf_mobile/interface/LoanNotes.dart';
import 'package:nf_mobile/interface/Payment.dart';

class BackupStorage extends StorageManager {
  var filename = 'backup_data';

  BackupStorage() : super();

  Future<bool> SaveData({List<Payment>? payments, List<LoanInteractions>? interactions, List<LoanNotes>? notes}) async {
    final backup = await GetBackupData();

    final paymentsToSave = payments == null ? [] : payments;
    final notesToSave = notes == null ? [] : notes;
    final interactionsToSave = interactions == null ? [] : interactions;

    if (paymentsToSave.length == 0 && notesToSave.length == 0 && interactionsToSave == 0) {
      return true;
    }

    final newBackup = {'date': DateTime.now().toString(), 'payments': paymentsToSave, 'notes': notesToSave, 'interactions': interactionsToSave};

    backup.add(newBackup);

    // limit of 5 backups
    if (backup.length > 5) {
      backup.removeAt(0);
    }

    final backupSaved = await _storeBackup(backup);

    final backupStored = await GetBackupData();
    print(backupStored);

    return backupSaved;
  }

  Future<bool> _storeBackup(List<dynamic> backup) async {
    return StoreData(backup);
  }

  Future<List<dynamic>> GetBackupData() async {
    final storeData = await GetData();
    print(storeData);
    final data = storeData.error ? null : storeData.data;

    if (data != null) {
      return data;
    } else {
      return [];
    }
  }
}
