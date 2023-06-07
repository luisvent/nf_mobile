class Settings {
  Settings({required this.printerName});

  Settings.Empty() {
    printerName = '';
    showAllInstallmentsScreen = false;
    showReceiptAfterPayment = true;
    receiptFontSize = ReceiptFontSize.Normal;
    receiptLogoType = ReceiptLogoType.Image;
    operationMode = OperationMode.Offline;
    alwaysLocation = true;
  }

  Settings.fromJson(dynamic json) {
    printerName = json['printerName'];
    showAllInstallmentsScreen = json['showAllInstallmentsScreen'] == null ? false : json['showAllInstallmentsScreen'];
    showReceiptAfterPayment = json['showReceiptAfterPayment'] == null ? false : json['showReceiptAfterPayment'];
    receiptFontSize = json['receiptFontSize'] == null ? ReceiptFontSize.Normal : json['receiptFontSize'];
    receiptLogoType = json['receiptLogoType'] == null ? ReceiptLogoType.Image : json['receiptLogoType'];
    operationMode = json['operationMode'] == null ? OperationMode.Offline : json['operationMode'];
    alwaysLocation = json['alwaysLocation'] == null ? true : json['alwaysLocation'];
  }

  late String printerName = '';
  late bool showAllInstallmentsScreen = false;
  late bool showReceiptAfterPayment = true;
  late String receiptFontSize = ReceiptFontSize.Normal;
  late String receiptLogoType = ReceiptLogoType.Image;
  late String operationMode = OperationMode.Offline;
  late bool alwaysLocation = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['printerName'] = printerName;
    map['showAllInstallmentsScreen'] = showAllInstallmentsScreen;
    map['showReceiptAfterPayment'] = showReceiptAfterPayment;
    map['receiptFontSize'] = receiptFontSize;
    map['receiptLogoType'] = receiptLogoType;
    map['operationMode'] = operationMode;
    map['alwaysLocation'] = alwaysLocation;
    return map;
  }
}

class ReceiptFontSize {
  static const String Small = 'small';
  static const String Normal = 'normal';
  static const String Large = 'large';
}

class ReceiptLogoType {
  static const String Image = 'image';
  static const String Text = 'text';
}

class OperationMode {
  static const String Online = 'online';
  static const String Offline = 'offline';
}
