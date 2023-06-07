import 'package:flutter/foundation.dart';
import 'package:nf_mobile/database/settings_storage.dart';
import 'package:nf_mobile/interface/Settings.dart';

class SettingsProvider with ChangeNotifier {
  Settings? settings;
  SettingsStorage settingsStorage = SettingsStorage();

  Future<Settings> GetSettings() async {
    if (settings != null) {
      return settings as Settings;
    } else {
      final obtainedSettings = await settingsStorage.GetSettings();
      settings = obtainedSettings;
      notifyListeners();
      return obtainedSettings;
    }
  }

  Future<bool> SaveSetting(String property, dynamic value) async {
    final obtainedSettings = await settingsStorage.GetSettings();
    final jsonSettings = obtainedSettings.toJson();
    jsonSettings[property] = value;
    final updatedSettings = Settings.fromJson(jsonSettings);
    final saved = SaveSettings(updatedSettings);
    return saved;
  }

  Future<bool> SaveSettings(Settings settingsToSave) async {
    settings = settingsToSave;
    notifyListeners();
    final saved = settingsStorage.StoreSettingsData(settingsToSave);
    return saved;
  }
}
