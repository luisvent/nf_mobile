import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/RequestData.dart';
import 'package:nf_mobile/main.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';

class APIManager {
  static Future<RequestData> GetData({required String urlPath, bool token = true}) async {
    var headers = {'Content-Type': 'application/json'};
    if (token) {
      final userToken = await GetUserToken();
      headers['Authorization'] = 'bearer ' + userToken;
    }
    String backendServiceHost = urlPath;
    var response;
    try {
      response = await http.get(
        Uri.parse(backendServiceHost),
        headers: headers,
      );

      final result = ProcessResponse(response);
      return result;
    } on SocketException {
      return RequestData(title: 'RequestErrorinternetConnectionError', message: 'no internet connection', error: true);
    }
  }

  static Future<RequestData> PostData({required String urlPath, required dynamic data, bool token = true}) async {
    var headers = {'Content-Type': 'application/json'};
    if (token) {
      final userToken = await GetUserToken();
      headers['Authorization'] = 'bearer ' + userToken;
    }

    String backendServiceHost = urlPath;
    var response;
    try {
      response = await http.post(
        Uri.parse(backendServiceHost),
        headers: headers,
        body: jsonEncode(data),
      );

      final result = ProcessResponse(response);
      return result;
    } on SocketException {
      return RequestData(title: 'RequestErrorinternetConnectionError', message: 'no internet connection', error: true);
    }
  }

  static Future<int> checkUrlValidity(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      return response.statusCode;
    } catch (e) {
      return 404;
    }
  }

  static Future<RequestData> ProcessResponse(response) async {
    print('response:');
    print(response);
    RequestData result = RequestData();
    try {
      final body;
      result.statusCode = response.statusCode;
      body = response.body;

      // unauthorized
      if (result.statusCode == 401) {
        final sessionActive = await EvaluateSession();

        if (!sessionActive) {
          Tools.CloseSession();
        }
      }

      final decodedResponse = body == '' ? '' : jsonDecode(body);
      if (result.statusCode != 200) {
        result.title = 'Error';
        result.error = true;
        result.message = 'Request Error';
        result.data = null;
        // result.title = decodedResponse['title'];
        // result.error = true;
        // result.message = decodedResponse['errors'][0];
        // result.data = decodedResponse['details'];
      } else {
        result.title = 'Response';
        result.error = false;
        result.message = '';
        result.data = decodedResponse;
      }
    } on Exception catch (_) {
      result.title = 'Request Error';
      result.error = true;
      result.message = 'Error processing request';
      result.data = null;
    }
    return result;
  }

  static Future<String> GetUserToken() async {
    UserDataStorage userDataStorage = UserDataStorage();
    final userData = await userDataStorage.GetUserData();
    return userData == null ? '' : userData.token;
  }

  static Future<bool> EvaluateSession() async {
    if (AppNavigatorKey.currentContext != null) {
      final sessionActive = await Providers.UserState(AppNavigatorKey.currentContext as BuildContext).isSessionActive();
      return sessionActive;
    } else {
      return false;
    }
  }
}
