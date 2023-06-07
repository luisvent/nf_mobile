import 'package:nf_mobile/database/loan_interaction_storage.dart';
import 'package:nf_mobile/database/loan_note_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/database/storage_manager.dart';
import 'package:nf_mobile/interface/Activity.dart';

class ActivityStorage extends StorageManager {
  var filename = 'activities_data';

  ActivityStorage() : super();

  Future<bool> AddActivity(dynamic activity) async {
    final activities = await GetActivitiesData();
    activities.add(activity);
    return StoreData(activities);
  }

  Future<bool> AddActivities(dynamic activities) async {
    return StoreData(activities);
  }

  Future<List<Activity>> GetActivitiesData() async {
    final storeData = await GetData();
    if (storeData.error) {
      return [];
    } else {
      return storeData.data.map<Activity>((e) => new Activity.fromJson(e)).toList();
    }
  }

  Future<List<Activity>> GetAllActivities() async {
    LoanInteractionStorage loanInteractionStorage = LoanInteractionStorage();
    PaymentStorage paymentStorage = PaymentStorage();
    LoanNoteStorage loanNoteStorage = LoanNoteStorage();

    final activities = await GetActivitiesData();
    activities.addAll((await loanNoteStorage.GetNotesData()).map<Activity>((e) => e.ToActivity()).toList());
    activities.addAll((await loanInteractionStorage.GetInteractionsData()).map<Activity>((e) => e.ToActivity()).toList());
    activities.addAll((await paymentStorage.GetPaymentsData()).map<Activity>((p) => p.ToActivity()));

    return activities;
  }
}
