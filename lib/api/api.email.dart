import 'dart:convert';

import 'package:nf_mobile/api/api.manager.dart';
import 'package:nf_mobile/interface/RequestData.dart';

import '../resources/constants.dart';

class APIEmail {
  static const controller = 'emails';
  static String API_URL = "${Constants.baseUrl}${controller}/";

  static Future<RequestData> SendEmail(String subject, String content) async {
    final response = await APIManager.PostData(urlPath: API_URL, data: {'subject': subject, 'htmlContent': content});
    return response;
  }

  static void SendErrorEmail(String error, String stack) async {
    SendEmail('NF Mobile App [Error]', stack);
  }

  static Future<RequestData> SendBackupEmail(dynamic backup) async {
    return SendEmail('NF Mobile App [Backup]', json.encode(backup));
  }
}
