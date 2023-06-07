import 'dart:convert';

/// datasource : {"sourcename":"openstreetmap","attribution":"© OpenStreetMap contributors","license":"Open Database License","url":"https://www.openstreetmap.org/copyright"}
/// name : "RathausPassagen"
/// country : "Germany"
/// country_code : "de"
/// city : "Berlin"
/// postcode : "10178"
/// district : "Mitte"
/// neighbourhood : "Spandauer Vorstadt"
/// suburb : "Mitte"
/// street : "Rathausstraße"
/// housenumber : "1-14"
/// lon : 13.410578611162324
/// lat : 52.51933485
/// distance : 0
/// result_type : "amenity"
/// formatted : "RathausPassagen, Rathausstraße 1-14, 10178 Berlin, Germany"
/// address_line1 : "RathausPassagen"
/// address_line2 : "Rathausstraße 1-14, 10178 Berlin, Germany"
/// category : "commercial.shopping_mall"
/// timezone : {"name":"Europe/Berlin","offset_STD":"+01:00","offset_STD_seconds":3600,"offset_DST":"+02:00","offset_DST_seconds":7200,"abbreviation_STD":"CET","abbreviation_DST":"CEST"}
/// rank : {"importance":0.24585065784831783,"popularity":8.995467104553104}
/// place_id : "5131c2165c37d22a405927367a9079424a40f00102f9010ae87e0100000000c0020192030f52617468617573506173736167656e"
/// bbox : {"lon1":13.4090674,"lat1":52.5185192,"lon2":13.4118538,"lat2":52.5201379}

Geolocation geolocationFromJson(String str) => Geolocation.fromJson(json.decode(str));
String geolocationToJson(Geolocation data) => json.encode(data.toJson());

class Geolocation {
  Geolocation({
    Datasource? datasource,
    String? name,
    String? country,
    String? countryCode,
    String? city,
    String? postcode,
    String? district,
    String? neighbourhood,
    String? suburb,
    String? street,
    String? housenumber,
    num? lon,
    num? lat,
    num? distance,
    String? resultType,
    String? formatted,
    String? addressLine1,
    String? addressLine2,
    String? category,
    Timezone? timezone,
    Rank? rank,
    String? placeId,
    Bbox? bbox,
  }) {
    _datasource = datasource;
    _name = name;
    _country = country;
    _countryCode = countryCode;
    _city = city;
    _postcode = postcode;
    _district = district;
    _neighbourhood = neighbourhood;
    _suburb = suburb;
    _street = street;
    _housenumber = housenumber;
    _lon = lon;
    _lat = lat;
    _distance = distance;
    _resultType = resultType;
    _formatted = formatted;
    _addressLine1 = addressLine1;
    _addressLine2 = addressLine2;
    _category = category;
    _timezone = timezone;
    _rank = rank;
    _placeId = placeId;
    _bbox = bbox;
  }

  Geolocation.fromJson(dynamic json) {
    _datasource = json['datasource'] != null ? Datasource.fromJson(json['datasource']) : null;
    _name = json['name'];
    _country = json['country'];
    _countryCode = json['country_code'];
    _city = json['city'];
    _postcode = json['postcode'];
    _district = json['district'];
    _neighbourhood = json['neighbourhood'];
    _suburb = json['suburb'];
    _street = json['street'];
    _housenumber = json['housenumber'];
    _lon = json['lon'];
    _lat = json['lat'];
    _distance = json['distance'];
    _resultType = json['result_type'];
    _formatted = json['formatted'];
    _addressLine1 = json['address_line1'];
    _addressLine2 = json['address_line2'];
    _category = json['category'];
    _timezone = json['timezone'] != null ? Timezone.fromJson(json['timezone']) : null;
    _rank = json['rank'] != null ? Rank.fromJson(json['rank']) : null;
    _placeId = json['place_id'];
    _bbox = json['bbox'] != null ? Bbox.fromJson(json['bbox']) : null;
  }
  Datasource? _datasource;
  String? _name;
  String? _country;
  String? _countryCode;
  String? _city;
  String? _postcode;
  String? _district;
  String? _neighbourhood;
  String? _suburb;
  String? _street;
  String? _housenumber;
  num? _lon;
  num? _lat;
  num? _distance;
  String? _resultType;
  String? _formatted;
  String? _addressLine1;
  String? _addressLine2;
  String? _category;
  Timezone? _timezone;
  Rank? _rank;
  String? _placeId;
  Bbox? _bbox;
  Geolocation copyWith({
    Datasource? datasource,
    String? name,
    String? country,
    String? countryCode,
    String? city,
    String? postcode,
    String? district,
    String? neighbourhood,
    String? suburb,
    String? street,
    String? housenumber,
    num? lon,
    num? lat,
    num? distance,
    String? resultType,
    String? formatted,
    String? addressLine1,
    String? addressLine2,
    String? category,
    Timezone? timezone,
    Rank? rank,
    String? placeId,
    Bbox? bbox,
  }) =>
      Geolocation(
        datasource: datasource ?? _datasource,
        name: name ?? _name,
        country: country ?? _country,
        countryCode: countryCode ?? _countryCode,
        city: city ?? _city,
        postcode: postcode ?? _postcode,
        district: district ?? _district,
        neighbourhood: neighbourhood ?? _neighbourhood,
        suburb: suburb ?? _suburb,
        street: street ?? _street,
        housenumber: housenumber ?? _housenumber,
        lon: lon ?? _lon,
        lat: lat ?? _lat,
        distance: distance ?? _distance,
        resultType: resultType ?? _resultType,
        formatted: formatted ?? _formatted,
        addressLine1: addressLine1 ?? _addressLine1,
        addressLine2: addressLine2 ?? _addressLine2,
        category: category ?? _category,
        timezone: timezone ?? _timezone,
        rank: rank ?? _rank,
        placeId: placeId ?? _placeId,
        bbox: bbox ?? _bbox,
      );
  Datasource? get datasource => _datasource;
  String? get name => _name;
  String? get country => _country;
  String? get countryCode => _countryCode;
  String? get city => _city;
  String? get postcode => _postcode;
  String? get district => _district;
  String? get neighbourhood => _neighbourhood;
  String? get suburb => _suburb;
  String? get street => _street;
  String? get housenumber => _housenumber;
  num? get lon => _lon;
  num? get lat => _lat;
  num? get distance => _distance;
  String? get resultType => _resultType;
  String? get formatted => _formatted;
  String? get addressLine1 => _addressLine1;
  String? get addressLine2 => _addressLine2;
  String? get category => _category;
  Timezone? get timezone => _timezone;
  Rank? get rank => _rank;
  String? get placeId => _placeId;
  Bbox? get bbox => _bbox;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_datasource != null) {
      map['datasource'] = _datasource?.toJson();
    }
    map['name'] = _name;
    map['country'] = _country;
    map['country_code'] = _countryCode;
    map['city'] = _city;
    map['postcode'] = _postcode;
    map['district'] = _district;
    map['neighbourhood'] = _neighbourhood;
    map['suburb'] = _suburb;
    map['street'] = _street;
    map['housenumber'] = _housenumber;
    map['lon'] = _lon;
    map['lat'] = _lat;
    map['distance'] = _distance;
    map['result_type'] = _resultType;
    map['formatted'] = _formatted;
    map['address_line1'] = _addressLine1;
    map['address_line2'] = _addressLine2;
    map['category'] = _category;
    if (_timezone != null) {
      map['timezone'] = _timezone?.toJson();
    }
    if (_rank != null) {
      map['rank'] = _rank?.toJson();
    }
    map['place_id'] = _placeId;
    if (_bbox != null) {
      map['bbox'] = _bbox?.toJson();
    }
    return map;
  }
}

/// lon1 : 13.4090674
/// lat1 : 52.5185192
/// lon2 : 13.4118538
/// lat2 : 52.5201379

Bbox bboxFromJson(String str) => Bbox.fromJson(json.decode(str));
String bboxToJson(Bbox data) => json.encode(data.toJson());

class Bbox {
  Bbox({
    num? lon1,
    num? lat1,
    num? lon2,
    num? lat2,
  }) {
    _lon1 = lon1;
    _lat1 = lat1;
    _lon2 = lon2;
    _lat2 = lat2;
  }

  Bbox.fromJson(dynamic json) {
    _lon1 = json['lon1'];
    _lat1 = json['lat1'];
    _lon2 = json['lon2'];
    _lat2 = json['lat2'];
  }
  num? _lon1;
  num? _lat1;
  num? _lon2;
  num? _lat2;
  Bbox copyWith({
    num? lon1,
    num? lat1,
    num? lon2,
    num? lat2,
  }) =>
      Bbox(
        lon1: lon1 ?? _lon1,
        lat1: lat1 ?? _lat1,
        lon2: lon2 ?? _lon2,
        lat2: lat2 ?? _lat2,
      );
  num? get lon1 => _lon1;
  num? get lat1 => _lat1;
  num? get lon2 => _lon2;
  num? get lat2 => _lat2;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lon1'] = _lon1;
    map['lat1'] = _lat1;
    map['lon2'] = _lon2;
    map['lat2'] = _lat2;
    return map;
  }
}

/// importance : 0.24585065784831783
/// popularity : 8.995467104553104

Rank rankFromJson(String str) => Rank.fromJson(json.decode(str));
String rankToJson(Rank data) => json.encode(data.toJson());

class Rank {
  Rank({
    num? importance,
    num? popularity,
  }) {
    _importance = importance;
    _popularity = popularity;
  }

  Rank.fromJson(dynamic json) {
    _importance = json['importance'];
    _popularity = json['popularity'];
  }
  num? _importance;
  num? _popularity;
  Rank copyWith({
    num? importance,
    num? popularity,
  }) =>
      Rank(
        importance: importance ?? _importance,
        popularity: popularity ?? _popularity,
      );
  num? get importance => _importance;
  num? get popularity => _popularity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['importance'] = _importance;
    map['popularity'] = _popularity;
    return map;
  }
}

/// name : "Europe/Berlin"
/// offset_STD : "+01:00"
/// offset_STD_seconds : 3600
/// offset_DST : "+02:00"
/// offset_DST_seconds : 7200
/// abbreviation_STD : "CET"
/// abbreviation_DST : "CEST"

Timezone timezoneFromJson(String str) => Timezone.fromJson(json.decode(str));
String timezoneToJson(Timezone data) => json.encode(data.toJson());

class Timezone {
  Timezone({
    String? name,
    String? offsetSTD,
    num? offsetSTDSeconds,
    String? offsetDST,
    num? offsetDSTSeconds,
    String? abbreviationSTD,
    String? abbreviationDST,
  }) {
    _name = name;
    _offsetSTD = offsetSTD;
    _offsetSTDSeconds = offsetSTDSeconds;
    _offsetDST = offsetDST;
    _offsetDSTSeconds = offsetDSTSeconds;
    _abbreviationSTD = abbreviationSTD;
    _abbreviationDST = abbreviationDST;
  }

  Timezone.fromJson(dynamic json) {
    _name = json['name'];
    _offsetSTD = json['offset_STD'];
    _offsetSTDSeconds = json['offset_STD_seconds'];
    _offsetDST = json['offset_DST'];
    _offsetDSTSeconds = json['offset_DST_seconds'];
    _abbreviationSTD = json['abbreviation_STD'];
    _abbreviationDST = json['abbreviation_DST'];
  }
  String? _name;
  String? _offsetSTD;
  num? _offsetSTDSeconds;
  String? _offsetDST;
  num? _offsetDSTSeconds;
  String? _abbreviationSTD;
  String? _abbreviationDST;
  Timezone copyWith({
    String? name,
    String? offsetSTD,
    num? offsetSTDSeconds,
    String? offsetDST,
    num? offsetDSTSeconds,
    String? abbreviationSTD,
    String? abbreviationDST,
  }) =>
      Timezone(
        name: name ?? _name,
        offsetSTD: offsetSTD ?? _offsetSTD,
        offsetSTDSeconds: offsetSTDSeconds ?? _offsetSTDSeconds,
        offsetDST: offsetDST ?? _offsetDST,
        offsetDSTSeconds: offsetDSTSeconds ?? _offsetDSTSeconds,
        abbreviationSTD: abbreviationSTD ?? _abbreviationSTD,
        abbreviationDST: abbreviationDST ?? _abbreviationDST,
      );
  String? get name => _name;
  String? get offsetSTD => _offsetSTD;
  num? get offsetSTDSeconds => _offsetSTDSeconds;
  String? get offsetDST => _offsetDST;
  num? get offsetDSTSeconds => _offsetDSTSeconds;
  String? get abbreviationSTD => _abbreviationSTD;
  String? get abbreviationDST => _abbreviationDST;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['offset_STD'] = _offsetSTD;
    map['offset_STD_seconds'] = _offsetSTDSeconds;
    map['offset_DST'] = _offsetDST;
    map['offset_DST_seconds'] = _offsetDSTSeconds;
    map['abbreviation_STD'] = _abbreviationSTD;
    map['abbreviation_DST'] = _abbreviationDST;
    return map;
  }
}

/// sourcename : "openstreetmap"
/// attribution : "© OpenStreetMap contributors"
/// license : "Open Database License"
/// url : "https://www.openstreetmap.org/copyright"

Datasource datasourceFromJson(String str) => Datasource.fromJson(json.decode(str));
String datasourceToJson(Datasource data) => json.encode(data.toJson());

class Datasource {
  Datasource({
    String? sourcename,
    String? attribution,
    String? license,
    String? url,
  }) {
    _sourcename = sourcename;
    _attribution = attribution;
    _license = license;
    _url = url;
  }

  Datasource.fromJson(dynamic json) {
    _sourcename = json['sourcename'];
    _attribution = json['attribution'];
    _license = json['license'];
    _url = json['url'];
  }
  String? _sourcename;
  String? _attribution;
  String? _license;
  String? _url;
  Datasource copyWith({
    String? sourcename,
    String? attribution,
    String? license,
    String? url,
  }) =>
      Datasource(
        sourcename: sourcename ?? _sourcename,
        attribution: attribution ?? _attribution,
        license: license ?? _license,
        url: url ?? _url,
      );
  String? get sourcename => _sourcename;
  String? get attribution => _attribution;
  String? get license => _license;
  String? get url => _url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sourcename'] = _sourcename;
    map['attribution'] = _attribution;
    map['license'] = _license;
    map['url'] = _url;
    return map;
  }
}
