import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nf_mobile/interface/Activity.dart';
import 'package:nf_mobile/utilities/tools.dart';

LoanInteractions loanInteractionsFromJson(String str) => LoanInteractions.fromJson(json.decode(str));
String loanInteractionsToJson(LoanInteractions data) => json.encode(data.toJson());

class LoanInteractions {
  LoanInteractions({
    num? id,
    String? date,
    num? loanId,
    num? interactionTypeId,
    num? employeeId,
    String? employee,
    String? interactionType,
    num? longitude,
    num? latitude,
    bool synced = false,
  }) {
    _id = id;
    _date = date;
    _loanId = loanId;
    _interactionTypeId = interactionTypeId;
    _employeeId = employeeId;
    _employee = employee;
    _interactionType = interactionType;
    _longitude = longitude;
    _latitude = latitude;
    _synced = synced;
  }

  LoanInteractions.fromJson(dynamic json) {
    _id = json['id'];
    _date = json['date'];
    _loanId = json['loanId'];
    _interactionTypeId = json['interactionTypeId'];
    _employeeId = json['employeeId'];
    _employee = json['employee'];
    _interactionType = json['interactionType'];
    _longitude = json['longitude'];
    _latitude = json['latitude'];
    _synced = json['synced'] == null ? false : json['synced'];
  }
  num? _id;
  String? _date;
  num? _loanId;
  num? _interactionTypeId;
  num? _employeeId;
  String? _employee;
  String? _interactionType;
  num? _longitude;
  num? _latitude;
  bool _synced = false;
  LoanInteractions copyWith({
    num? id,
    String? date,
    num? loanId,
    num? interactionTypeId,
    num? employeeId,
    String? employee,
    String? interactionType,
    num? longitude,
    num? latitude,
    bool synced = false,
  }) =>
      LoanInteractions(
        id: id ?? _id,
        date: date ?? _date,
        loanId: loanId ?? _loanId,
        interactionTypeId: interactionTypeId ?? _interactionTypeId,
        employeeId: employeeId ?? _employeeId,
        employee: employee ?? _employee,
        interactionType: interactionType ?? _interactionType,
        longitude: longitude ?? _longitude,
        latitude: latitude ?? _latitude,
        synced: synced ?? _synced,
      );
  num? get id => _id;
  String? get date => _date;
  num? get loanId => _loanId;
  num? get interactionTypeId => _interactionTypeId;
  num? get employeeId => _employeeId;
  String? get employee => _employee;
  String? get interactionType => _interactionType;
  num? get longitude => _longitude;
  num? get latitude => _latitude;
  bool get synced => _synced;

  void set synced(bool s) {
    _synced = s;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['date'] = _date;
    map['loanId'] = _loanId;
    map['interactionTypeId'] = _interactionTypeId;
    map['employeeId'] = _employeeId;
    map['employee'] = _employee;
    map['interactionType'] = _interactionType;
    map['longitude'] = _longitude;
    map['latitude'] = _latitude;
    map['synced'] = _synced;
    return map;
  }

  Activity ToActivity() {
    return Activity(
        id: date.toString(),
        type: Activity.LoanInteraction,
        title: _interactionTypes[_interactionTypeId]!,
        message: 'Prestamo No. ${_loanId} - ${date}',
        trail: '',
        date: _date!,
        icon: _interactionIcons[_interactionTypeId]!,
        latitude: _latitude as double,
        longitude: _longitude as double);
  }

  Future<bool> SetLocation() async {
    final location = await Tools.GetLocation();
    _latitude = location.latitude;
    _longitude = location.longitude;
    return true;
  }

  Map<int, String> _interactionTypes = {
    1: 'Llamada sin comunicación',
    2: 'Visita, cliente no estaba',
    3: 'Visita de cobro/sin pago',
    4: 'Envío de cartas de cobros',
    5: 'Negocio cerrado'
  };

  Map<int, IconData> _interactionIcons = {
    1: Icons.phone_disabled,
    2: Icons.person_off_outlined,
    3: Icons.money_off,
    4: Icons.local_post_office_outlined,
    5: Icons.highlight_off_rounded
  };
}
