import 'package:nf_mobile/api/api.manager.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/RequestData.dart';
import 'package:nf_mobile/interface/User.dart';

import '../resources/constants.dart';

class APIAuth {
  static const controller = 'accounts';
  static String API_URL = "${Constants.baseUrl}${controller}/";

  static Future<RequestData> AuthenticateUser(String username, String password) async {
    UserDataStorage userDataStorage = UserDataStorage();

    print(API_URL);
    final response = await APIManager.PostData(urlPath: API_URL + 'authenticate', data: {'username': username, 'password': password});

    if (!response.error) {
      final userIsSaved = await Future.wait([userDataStorage.StoreUserData(User.fromJson(response.data))]);
    }

    return response;
  }
}
