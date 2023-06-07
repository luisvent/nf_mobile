import 'dart:convert';

import 'package:datecs_printer/datecs_printer.dart';
import 'package:flutter/services.dart';

class Printer {
  String _platformVersion = 'Unknown';
  DatecsDevice? _device;
  bool connected = false;
  int retry = 0;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await DatecsPrinter.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    _platformVersion = platformVersion;
  }

  Future<List<DatecsDevice>> GetBluetoothList() async {
    List<dynamic> list = await DatecsPrinter.getListBluetoothDevice;
    List<DatecsDevice> listOfDevice = [];
    for (var element in list) {
      var bluetooth = element as Map<dynamic, dynamic>;
      var name, address;
      bluetooth.forEach((key, value) {
        key == "name" ? name = value : address = value;
      });
      listOfDevice.add(DatecsDevice(name, address));
    }
    return listOfDevice;
  }

  Future<PrinterReport> Connect(DatecsDevice device) async {
    final connected = await DatecsPrinter.connectBluetooth(device!.address);
    return connected
        ? PrinterReport(message: 'Impresora Conectada', code: PrinterReport.Success, error: false)
        : PrinterReport(message: 'No Pudo Conectar Con Impresora', code: PrinterReport.Error, error: true);
  }

  Future<PrinterReport> _printText(List<String> ticket) async {
    print('printing');
    final result = await DatecsPrinter.printText(ticket);
    print('printed: ' + result.toString());

    return result
        ? PrinterReport(message: 'Impresión Completa!', code: PrinterReport.Success, error: false)
        : PrinterReport(message: 'Error Imprimiendo', code: PrinterReport.Error, error: true);
  }

  Future<bool> ConnectAndPrint(DatecsDevice device, List<String> ticket) async {
    // already connected, print
    if (connected) {
      print('connected');
      final result = await _printText(ticket);
      return !result.error;
    } else {
      print('not connected');

      Connect(device).then((result) {
        if (true) {
          // connected
          if (!result.error) {
            print('now connected');
            connected = true;
            _device = device;
            print('to print');
            return _printText(ticket);
          } else {
            print('not connected');
            connected = false;
            _device = null;
            // connection failed
            return Future.value(false);
          }
        } else {
          ConnectAndPrint(device, ticket);
        }
      });

      return Future.value(true);
    }
  }

  Future<PrinterReport> Print(String printerName, String content, [String fontSize = 'normal']) async {
    final bluetoothDevices = await GetBluetoothList();

    // list of blueetooh devices
    if (bluetoothDevices.isNotEmpty) {
      final printerExists = bluetoothDevices.any((device) => device.name == printerName);

      if (printerExists) {
        final printer = bluetoothDevices.firstWhere((device) => device.name == printerName);
        print('printer found');
        final ticket = CreateTicket(content, fontSize);
        print('ticket created');
        final printerConnected = await Connect(printer);

        if (!printerConnected.error) {
          final printResult = await _printText(ticket);

          if (!printResult.error) {
            // print success
            retry = 0;
            print('success');
            return printResult;
          } else {
            retry++;
            print('fail');
            // no print
            if (retry > 2) {
              retry = 0;
              return printResult;
            } else {
              return Print(printerName, content);
            }
          }
        } else {
          // could not conenct
          return printerConnected;
        }
      } else {
        // printer not connected
        return PrinterReport(message: 'Impresora No Conectda', code: PrinterReport.Error, error: true);
      }
    } else {
      // no devices found
      return PrinterReport(message: 'Impresora No Encontrada', code: PrinterReport.Error, error: true);
    }
  }

  Future<String> LoadImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      Uint8List imagebytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes); //convert to bytes
      String base64string = base64.encode(imagebytes); //convert bytes to base64 string
      return base64string;
    } catch (e) {
      return '';
    }
  }

  List<String> CreateTicket(String text, [String fontSize = 'normal']) {
    final splittedText = text.split('\n');
    final generate = DatecsGenerate(DatecsPaper.mm80);
    var size = DatecsSize.normal;

    switch (fontSize) {
      case 'small':
        size = DatecsSize.small;
        break;
      case 'normal':
        size = DatecsSize.normal;
        break;
      case 'large':
        size = DatecsSize.high;
        break;
    }

    splittedText.forEach((line) {
      if (line.contains('#IMG#')) {
        line = line.replaceFirst('#IMG#', '');
        generate.image(line);
      } else if (line == '') {
        // generate.hr();
        generate.feed(1);
      } else {
        generate.textPrint(line,
            style: DatecsStyle(
              bold: false,
              italic: false,
              underline: false,
              align: DatecsAlign.center,
              size: size,
            ));
      }
    });

    generate.feed(5);
    return generate.args;
  }

  Future<List<String>> getTestTicketDatecs({bool withImage = false}) async {
    final generate = DatecsGenerate(DatecsPaper.mm80);

    if (withImage) {
      ByteData bytes = await rootBundle.load('assets/empty-box.png');
      var buffer = bytes.buffer;
      var m = base64Encode(Uint8List.view(buffer));

      generate.image(m);
    }
    generate.feed(2);
    generate.textPrint(
      "Notes Print (Jhordy mmg)",
      style: DatecsStyle(
        bold: false,
        italic: false,
        underline: false,
        align: DatecsAlign.center,
        size: DatecsSize.high,
      ),
    );
    generate.textPrint("First test printing from android",
        style: DatecsStyle(
          align: DatecsAlign.center,
          bold: false,
          italic: false,
          underline: false,
        ));
    generate.textPrint('Tel: blah blah',
        style: DatecsStyle(
          align: DatecsAlign.center,
          bold: false,
          italic: false,
          underline: false,
        ));

    // generate.hr(char: "=");
    //
    // generate.row([
    //   DatecsColumn(text: 'No', width: 1, styles: DatecsStyle(align: DatecsAlign.left, bold: true)),
    //   DatecsColumn(text: 'Item', width: 5, styles: DatecsStyle(align: DatecsAlign.left, bold: true)),
    //   DatecsColumn(text: 'Price', width: 2, styles: DatecsStyle(align: DatecsAlign.center, bold: true)),
    //   DatecsColumn(text: 'Qty', width: 2, styles: DatecsStyle(align: DatecsAlign.center, bold: true)),
    //   DatecsColumn(text: 'Total', width: 2, styles: DatecsStyle(align: DatecsAlign.right, bold: true)),
    // ]);
    // generate.hr();
    // generate.row([
    //   DatecsColumn(text: '1', width: 1, styles: DatecsStyle(align: DatecsAlign.left, bold: true)),
    //   DatecsColumn(text: 'Tea', width: 5, styles: DatecsStyle(align: DatecsAlign.left, bold: true)),
    //   DatecsColumn(text: '10', width: 2, styles: DatecsStyle(align: DatecsAlign.center, bold: true)),
    //   DatecsColumn(text: '1', width: 2, styles: DatecsStyle(align: DatecsAlign.center, bold: true)),
    //   DatecsColumn(text: '10', width: 2, styles: DatecsStyle(align: DatecsAlign.right, bold: true)),
    // ]);
    //
    // generate.row([
    //   DatecsColumn(text: '2', width: 1, styles: DatecsStyle(align: DatecsAlign.left, bold: true)),
    //   DatecsColumn(text: 'Sada Dosa', width: 5, styles: DatecsStyle(align: DatecsAlign.left, bold: true)),
    //   DatecsColumn(text: '30', width: 2, styles: DatecsStyle(align: DatecsAlign.center, bold: true)),
    //   DatecsColumn(text: '1', width: 2, styles: DatecsStyle(align: DatecsAlign.center, bold: true)),
    //   DatecsColumn(text: '30', width: 2, styles: DatecsStyle(align: DatecsAlign.right, bold: true)),
    // ]);
    generate.feed(5);

    return generate.args;
  }
}

class PrinterReport {
  static const Success = 1;
  static const Error = 1;

  late String message;
  late bool error;
  late int code;

  PrinterReport({required this.message, required this.code, required this.error});
}
