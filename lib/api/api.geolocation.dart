import 'package:nf_mobile/api/api.manager.dart';
import 'package:nf_mobile/interface/RequestData.dart';
import 'package:nf_mobile/resources/constants.dart';

class APIGeolocation {
  static String API_URL = "https://api.geoapify.com/v1/geocode/";

  static Future<RequestData> TranslateCoordinatesToAddress(double latitude, double longitude) async {
    final geolocationUrl = '${API_URL}reverse?lat=$latitude&lon=$longitude&format=json&apiKey=${Constants.geoapifyApiKey}';
    final response = await APIManager.GetData(urlPath: geolocationUrl);
    return response;
  }

  static Future<RequestData> GoogleTranslateCoordinatesToAddress(double latitude, double longitude) async {
    final geolocationUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${Constants.googleApiKey}';
    final response = await APIManager.GetData(urlPath: geolocationUrl);
    return response;
  }
}
