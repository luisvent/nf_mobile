import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nf_mobile/interface/StoredData.dart';
import 'package:path_provider/path_provider.dart';

class StorageManager {
  var filename = '';

  StorageManager() {
    filename = filename + '.json';
  }

  @protected
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @protected
  Future<File> get DataFile async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  @protected
  Future<StoredData> GetData() async {
    var storeData = StoredData();
    try {
      final file = await DataFile;
      final contents = await file.readAsString();
      storeData = ProcessStoredData(contents);
      return storeData;
    } catch (e) {
      print(e);
      storeData.title = 'localDBError';
      storeData.message = 'unable to parse data';
      storeData.error = true;
      storeData.data = null;
      return storeData;
    }
  }

  @protected
  Future<bool> StoreData(dynamic data) async {
    try {
      final file = await DataFile;
      return file.writeAsString(jsonEncode(data)).then((value) => true);
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> DeleteFile() async {
    try {
      final file = await DataFile;
      bool exists = await file.exists();
      if (exists) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @protected
  StoredData ProcessStoredData(data) {
    print('data:');
    // print(data);
    var storeData = StoredData();
    try {
      final decodedResponse = jsonDecode(data);
      storeData.title = 'Stored Data';
      storeData.error = false;
      storeData.message = '';
      storeData.data = decodedResponse;
    } catch (_) {
      storeData.title = 'localDBError';
      storeData.message = 'unable to parse data';
      storeData.error = true;
      storeData.data = null;
    }
    return storeData;
  }
}
