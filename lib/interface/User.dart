import 'Roles.dart';

class User {
  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fullname,
    required this.token,
    required this.tokenExpiration,
    required this.changePasswordOnLogin,
    required this.roles,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    username = json['username'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    fullname = json['fullname'];
    token = json['token'];
    tokenExpiration = json['tokenExpiration'];
    changePasswordOnLogin = json['changePasswordOnLogin'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles.add(Roles.fromJson(v));
      });
    }
  }
  late int id;
  late String username;
  late String firstName;
  late String lastName;
  late String email;
  late String fullname;
  late String token;
  late double tokenExpiration;
  late bool changePasswordOnLogin;
  late List<Roles> roles;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['email'] = email;
    map['fullname'] = fullname;
    map['token'] = token;
    map['tokenExpiration'] = tokenExpiration;
    map['changePasswordOnLogin'] = changePasswordOnLogin;
    if (roles != null) {
      map['roles'] = roles.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
