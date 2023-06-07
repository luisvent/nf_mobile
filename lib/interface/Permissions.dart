class Permissions {
  Permissions({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  Permissions.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    description = json['description'];
  }
  late int id;
  late String name;
  late String code;
  late String description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['code'] = code;
    map['description'] = description;
    return map;
  }
}
