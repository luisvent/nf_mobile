import 'package:nf_mobile/database/storage_manager.dart';
import 'package:nf_mobile/interface/LoanInteractions.dart';

class LoanInteractionStorage extends StorageManager {
  var filename = 'interactions_data';

  LoanInteractionStorage() : super();

  Future<bool> AddLoanInteraction(dynamic interactionData) async {
    final interactions = await GetInteractionsData();
    interactions.add(interactionData);
    return StoreData(interactions);
  }

  Future<bool> AddLoanInteractions(dynamic interactionsData) async {
    return StoreData(interactionsData);
  }

  Future<List<LoanInteractions>> GetInteractionsData() async {
    final storeData = await GetData();
    if (storeData.error) {
      return [];
    } else {
      return storeData.data.map<LoanInteractions>((e) => new LoanInteractions.fromJson(e)).toList();
    }
  }
}
