import 'package:flutter/widgets.dart';
import 'package:nf_mobile/providers/app_controller_provider.dart';
import 'package:nf_mobile/providers/settings_provider.dart';
import 'package:nf_mobile/providers/sync_provider.dart';
import 'package:nf_mobile/providers/user_state_provider.dart';
import 'package:provider/provider.dart';

class Providers {
  static SettingsProvider Settings(BuildContext context, [bool listen = false]) {
    return Provider.of<SettingsProvider>(context, listen: listen);
  }

  static SyncProvider Sync(BuildContext context, [bool listen = false]) {
    return Provider.of<SyncProvider>(context, listen: listen);
  }

  static UserStateProvider UserState(BuildContext context, [bool listen = false]) {
    return Provider.of<UserStateProvider>(context, listen: listen);
  }

  static AppControllerProvider AppController(BuildContext context, [bool listen = false]) {
    return Provider.of<AppControllerProvider>(context, listen: listen);
  }
}
