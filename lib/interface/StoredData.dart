class StoredData {
  StoredData({
    this.title,
    this.error = false,
    this.message = '',
    this.data,
  });

  StoredData.fromJson(dynamic json) {
    title = json['title'];
    error = json['error'];
    message = json['message'];
    data = json['data'];
  }
  String? title;
  bool error = false;
  String message = '';
  dynamic data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['error'] = error;
    map['message'] = message;
    map['data'] = data;
    return map;
  }
}
