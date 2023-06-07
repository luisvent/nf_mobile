import 'package:nf_mobile/interface/Loan.dart';
import 'package:nf_mobile/resources/mock_data.dart';

class Constants {
  static bool production = false;
  static String version = '';
  static String geoapifyApiKey = '';
  static String googleApiKey = '';
  static String baseUrl = production ? '' : '';
  static var servers = [];
  static Map<String, dynamic> mockUserData = {
    "authorization_token":
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOjI4MjksImV4cCI6MTY4MTU0Njc0OX0.QYowT9yugDHnb6xWvnfQCM6RChADlisSCSX1dEHgmT0",
    "user": {
      "address": {
        "apartment_name": "Strosin Flats, city: Lettybury",
        "country": "United States",
        "state": "Missouri",
        "street_address": "8430 Jill Freeway",
        "zip_code": 41631
      },
      "avatar": "christina-wocintechchat-com-0Zx1bDv5BNY-unsplash.jpg",
      "bankDetails": [
        {"accountNumber": 99293629, "bankBalance": 143398.85, "bankName": "BANK OF AMERICA", "currency": "USD"}
      ],
      "date_of_birth": "22-06-1983",
      "email": "mary.kertzmann@notillegal.org",
      "employment": {"organisation": "NOT ILLEGAL PVT LTD", "title": "Regional Legal Specialist"},
      "first_name": "Mary",
      "gender": "Female",
      "id": 2829,
      "last_name": "Kertzmann",
      "password": "deer",
      "phone_number": "+352 109-507-1667",
      "uid": "8712c7de-ca40-45c0-a030-73f6904539b6",
      "username": "mary.kertzmann",
      "walletAddress": "19UBFtiqTgcWXkrfPsq1G2NXQYcfPUyqsW"
    }
  };
  static String CompanyName = '';
  static String CompanyLogoImg64 = '';
  static String CompanyPhoneNumber = '';
  static String CompanyAddress = '';
  static List<Loan> pendingPayments = pendingPaymentsData.map((e) => new Loan.fromJson(e)).toList();
}
