import 'Permissions.dart';

class Roles {
  Roles({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.permissions,
  });

  Roles.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    description = json['description'];
    if (json['permissions'] != null) {
      permissions = [];
      json['permissions'].forEach((v) {
        permissions.add(Permissions.fromJson(v));
      });
    }
  }
  late int id;
  late String name;
  late String code;
  late String description;
  late List<Permissions> permissions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['code'] = code;
    map['description'] = description;
    if (permissions != null) {
      map['permissions'] = permissions.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
