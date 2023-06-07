class RequestData {
  RequestData({
    this.title,
    this.error = false,
    this.message = '',
    this.data,
  });

  RequestData.fromJson(dynamic json) {
    title = json['title'];
    error = json['error'];
    message = json['message'];
    data = json['data'];
  }
  String? title;
  bool error = false;
  String message = '';
  int? statusCode = 0;
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
