import 'dart:convert';

import 'package:nf_mobile/interface/Client.dart';

LoanApplication loanApplicationFromJson(String str) => LoanApplication.fromJson(json.decode(str));
String loanApplicationToJson(LoanApplication data) => json.encode(data.toJson());

class LoanApplication {
  LoanApplication({
    num? id,
    String? idClient,
    Client? client,
    num? loanId,
    String? official,
    String? officialCommonName,
    bool? renewal,
  }) {
    _id = id;
    _idClient = idClient;
    _client = client;
    _loanId = loanId;
    _official = official;
    _officialCommonName = officialCommonName;
    _renewal = renewal;
  }

  LoanApplication.fromJson(dynamic json) {
    _id = json['id'];
    _idClient = json['idClient'];
    _client = json['client'] != null ? Client.fromJson(json['client']) : null;
    _loanId = json['loanId'];
    _official = json['official'];
    _officialCommonName = json['officialCommonName'];
    _renewal = json['renewal'];
  }
  num? _id;
  String? _idClient;
  Client? _client;
  num? _loanId;
  String? _official;
  String? _officialCommonName;
  bool? _renewal;
  LoanApplication copyWith({
    num? id,
    String? idClient,
    Client? client,
    num? loanId,
    String? official,
    String? officialCommonName,
    bool? renewal,
  }) =>
      LoanApplication(
        id: id ?? _id,
        idClient: idClient ?? _idClient,
        client: client ?? _client,
        loanId: loanId ?? _loanId,
        official: official ?? _official,
        officialCommonName: officialCommonName ?? _officialCommonName,
        renewal: renewal ?? _renewal,
      );
  num? get id => _id;
  String? get idClient => _idClient;
  Client? get client => _client;
  num? get loanId => _loanId;
  String? get official => _official;
  String? get officialCommonName => _officialCommonName;
  bool? get renewal => _renewal;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['idClient'] = _idClient;
    if (_client != null) {
      map['client'] = _client?.toJson();
    }
    map['loanId'] = _loanId;
    map['official'] = _official;
    map['officialCommonName'] = _officialCommonName;
    map['renewal'] = _renewal;
    return map;
  }
}
