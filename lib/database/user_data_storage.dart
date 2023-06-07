import 'dart:developer';

import 'package:nf_mobile/database/storage_manager.dart';
import 'package:nf_mobile/interface/User.dart';

class UserDataStorage extends StorageManager {
  var filename = 'user_data';

  UserDataStorage() : super();

  Future<bool> StoreUserData(dynamic userData) {
    return StoreData(userData);
  }

  Future<User?> GetUserData() async {
    final storeData = await GetData();
    print('use data:');
    inspect(storeData);
    return storeData.error || storeData.data == null ? null : User.fromJson(storeData.data);
  }

  Future<int> getUserId() async {
    final userData = await UserDataStorage().GetUserData();
    return userData == null ? 0 : userData.id;
  }
}
