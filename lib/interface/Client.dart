import 'dart:convert';

Client clientFromJson(String str) => Client.fromJson(json.decode(str));
String clientToJson(Client data) => json.encode(data.toJson());

class Client {
  Client({
    num? id,
    String? documentId,
    String? commonName,
    String? fullName,
    String? address,
    String? phoneNumber,
    String? cellPhoneNumber,
    String? sector,
    String? reference,
    String? businessName,
    String? businessAddress,
    dynamic businessAddressReference,
  }) {
    _id = id;
    _documentId = documentId;
    _commonName = commonName;
    _fullName = fullName;
    _address = address;
    _phoneNumber = phoneNumber;
    _cellPhoneNumber = cellPhoneNumber;
    _sector = sector;
    _reference = reference;
    _businessName = businessName;
    _businessAddress = businessAddress;
    _businessAddressReference = businessAddressReference;
  }

  Client.fromJson(dynamic json) {
    _id = json['id'];
    _documentId = json['documentId'];
    _commonName = json['commonName'];
    _fullName = json['fullName'];
    _address = json['address'];
    _phoneNumber = json['phoneNumber'];
    _cellPhoneNumber = json['cellPhoneNumber'];
    _sector = json['sector'];
    _reference = json['reference'];
    _businessName = json['businessName'];
    _businessAddress = json['businessAddress'];
    _businessAddressReference = json['businessAddressReference'];
  }
  num? _id;
  String? _documentId;
  String? _commonName;
  String? _fullName;
  String? _address;
  String? _phoneNumber;
  String? _cellPhoneNumber;
  String? _sector;
  String? _reference;
  String? _businessName;
  String? _businessAddress;
  dynamic _businessAddressReference;
  Client copyWith({
    num? id,
    String? documentId,
    String? commonName,
    String? fullName,
    String? address,
    String? phoneNumber,
    String? cellPhoneNumber,
    String? sector,
    String? reference,
    String? businessName,
    String? businessAddress,
    dynamic businessAddressReference,
  }) =>
      Client(
        id: id ?? _id,
        documentId: documentId ?? _documentId,
        commonName: commonName ?? _commonName,
        fullName: fullName ?? _fullName,
        address: address ?? _address,
        phoneNumber: phoneNumber ?? _phoneNumber,
        cellPhoneNumber: cellPhoneNumber ?? _cellPhoneNumber,
        sector: sector ?? _sector,
        reference: reference ?? _reference,
        businessName: businessName ?? _businessName,
        businessAddress: businessAddress ?? _businessAddress,
        businessAddressReference: businessAddressReference ?? _businessAddressReference,
      );
  num? get id => _id;
  String? get documentId => _documentId;
  String? get commonName => _commonName;
  String? get fullName => _fullName;
  String? get address => _address;
  String? get phoneNumber => _phoneNumber;
  String? get cellPhoneNumber => _cellPhoneNumber;
  String? get sector => _sector;
  String? get reference => _reference;
  String? get businessName => _businessName;
  String? get businessAddress => _businessAddress;
  dynamic get businessAddressReference => _businessAddressReference;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['documentId'] = _documentId;
    map['commonName'] = _commonName;
    map['fullName'] = _fullName;
    map['address'] = _address;
    map['phoneNumber'] = _phoneNumber;
    map['cellPhoneNumber'] = _cellPhoneNumber;
    map['sector'] = _sector;
    map['reference'] = _reference;
    map['businessName'] = _businessName;
    map['businessAddress'] = _businessAddress;
    map['businessAddressReference'] = _businessAddressReference;
    return map;
  }
}
