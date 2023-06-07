import 'package:flutter/material.dart';
import 'package:nf_mobile/utilities/tools.dart';

class Activity {
  static const Payment = 'payment';
  static const LoanNote = 'loan_note';
  static const LoanInteraction = 'loan_interaction';

  Activity(
      {required this.id,
      required this.type,
      required this.title,
      required this.message,
      required this.trail,
      required this.icon,
      required this.date,
      this.latitude = 0.0,
      this.longitude = 0.0});

  Activity.Empty() {
    title = '';
    message = '';
    trail = '';
    icon = Icons.access_time_outlined;
    date = Tools.LongDate();
    latitude = 0.0;
    longitude = 0.0;
  }

  Activity.fromJson(dynamic json) {
    title = json['title'];
    message = json['message'];
    trail = json['trail'];
    type = json['type'];
    date = json['date'];
    icon = json['icon'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  late String id = '';
  late String type = '';
  late String title = '';
  late String message = '';
  late String trail = '';
  late String date = '';
  late IconData icon = Icons.access_time_outlined;
  late double latitude = 0.0;
  late double longitude = 0.0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['message'] = message;
    map['trail'] = trail;
    map['icon'] = icon;
    map['date'] = date;
    map['type'] = type;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    return map;
  }

  Map<String, dynamic> ToMarker() {
    return {'latitude': latitude, 'longitude': longitude, 'type': type, 'title': title, 'description': message};
  }
}
