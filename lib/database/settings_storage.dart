import 'package:nf_mobile/database/storage_manager.dart';
import 'package:nf_mobile/interface/Settings.dart';

class SettingsStorage extends StorageManager {
  var filename = 'settings_data';

  SettingsStorage() : super();

  Future<bool> StoreSettingsData(dynamic settingsData) {
    return StoreData(settingsData);
  }

  Future<Settings> GetSettings() async {
    final storeData = await GetData();
    return storeData.error || storeData.data == null ? Settings.Empty() : Settings.fromJson(storeData.data);
  }
}
