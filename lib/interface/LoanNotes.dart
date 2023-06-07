import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nf_mobile/interface/Activity.dart';
import 'package:nf_mobile/utilities/tools.dart';

LoanNotes loanNotesFromJson(String str) => LoanNotes.fromJson(json.decode(str));
String loanNotesToJson(LoanNotes data) => json.encode(data.toJson());

class LoanNotes {
  LoanNotes({
    num? id,
    String? description,
    String? date,
    String? followingDate,
    num? loanId,
    num? employeeId,
    String? employee,
    num? longitude,
    num? latitude,
    bool synced = false,
  }) {
    _id = id;
    _description = description;
    _date = date;
    _followingDate = followingDate;
    _loanId = loanId;
    _employeeId = employeeId;
    _employee = employee;
    _longitude = longitude;
    _latitude = latitude;
    _synced = synced;
  }

  LoanNotes.fromJson(dynamic json) {
    _id = json['id'];
    _description = json['description'];
    _date = json['date'];
    _followingDate = json['followingDate'];
    _loanId = json['loanId'];
    _employeeId = json['employeeId'];
    _employee = json['employee'];
    _longitude = json['longitude'];
    _latitude = json['latitude'];
    _synced = json['synced'] == null ? false : json['synced'];
  }
  num? _id;
  String? _description;
  String? _date;
  String? _followingDate;
  num? _loanId;
  num? _employeeId;
  String? _employee;
  num? _longitude;
  num? _latitude;
  bool _synced = false;
  LoanNotes copyWith({
    num? id,
    String? description,
    String? date,
    String? followingDate,
    num? loanId,
    num? employeeId,
    String? employee,
    num? longitude,
    num? latitude,
    bool synced = false,
  }) =>
      LoanNotes(
        id: id ?? _id,
        description: description ?? _description,
        date: date ?? _date,
        followingDate: followingDate ?? _followingDate,
        loanId: loanId ?? _loanId,
        employeeId: employeeId ?? _employeeId,
        employee: employee ?? _employee,
        longitude: longitude ?? _longitude,
        latitude: latitude ?? _latitude,
        synced: synced ?? _synced,
      );
  num? get id => _id;
  String? get description => _description;
  String? get date => _date;
  String? get followingDate => _followingDate;
  num? get loanId => _loanId;
  num? get employeeId => _employeeId;
  String? get employee => _employee;
  num? get longitude => _longitude;
  num? get latitude => _latitude;
  bool get synced => _synced;

  void set synced(bool s) {
    _synced = s;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['description'] = _description;
    map['date'] = _date;
    map['followingDate'] = _followingDate;
    map['loanId'] = _loanId;
    map['employeeId'] = _employeeId;
    map['employee'] = _employee;
    map['longitude'] = _longitude;
    map['latitude'] = _latitude;
    map['synced'] = _synced;
    return map;
  }

  Activity ToActivity() {
    return Activity(
        id: date.toString(),
        type: Activity.LoanNote,
        title: _description!,
        message: 'Prestamo No. ${_loanId} - ${date}',
        trail: '',
        date: _date!,
        icon: Icons.comment,
        latitude: _latitude as double,
        longitude: _longitude as double);
  }

  Future<bool> SetLocation() async {
    final location = await Tools.GetLocation();
    _latitude = location.latitude;
    _longitude = location.longitude;
    return true;
  }
}
