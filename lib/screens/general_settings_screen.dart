import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nf_mobile/database/backup_storage.dart';
import 'package:nf_mobile/interface/Settings.dart';
import 'package:nf_mobile/providers/settings_provider.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({Key? key}) : super(key: key);

  @override
  GeneralSettingsScreenState createState() => GeneralSettingsScreenState();
}

class GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  BackupStorage backupStorage = BackupStorage();
  Widget appBarTitle = Text("General", style: TextStyle(color: Color(0xff243656)));
  Settings settings = Settings.Empty();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  loadSettings() async {
    final loadSettings = await settingsProvider.GetSettings();

    setState(() {
      settings = loadSettings;
    });
  }

  saveSetting(String setting, dynamic value) {
    settingsProvider.SaveSetting(setting, value);
  }

  activateOnlineMode() {
    final syncData = Providers.Sync(context).allSynced;

    if (syncData) {
      setState(() {
        settings.operationMode = OperationMode.Online;
      });
      saveSetting('operationMode', OperationMode.Online);
    } else {
      Tools.ShowConfirmDialog(
          context, 'Datos sin registar', 'Para activar el modo Online primero registre todas los datos con el servidor', 'Ok', () {}, '');
    }
  }

  activateOfflineMode() async {
    final connectivity = await Tools.HasInternetConnectivity();
    if (connectivity) {
      Tools.ShowLoading(loadingMessage: 'Cargando datos...');
      final syncResult = await Providers.Sync(context).SyncData();
      Tools.HideLoading();
    }
  }

  SettingsProvider get settingsProvider {
    return Providers.Settings(context);
  }

  Widget sectionHeader(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 30),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blueGrey,
            size: 20,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blueGrey),
          )
        ],
      ),
    );
  }

  Widget sectionOption(String title, List<Widget> children) {
    children.insert(
        0,
        Text(
          title,
          style: TextStyle(color: Colors.blueGrey),
        ));

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(bottom: 2),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(color: Colors.blueGrey[50]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: Icon(Icons.arrow_back, color: Color(0xff243656))),
          title: appBarTitle,
          centerTitle: true,
          actions: [],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Column(children: <Widget>[
          SizedBox(
            height: 100,
          ),
          Expanded(
              child: Container(
            height: 600,
            width: double.infinity,
            child: AnimationLimiter(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: widget,
                            ),
                          ),
                      children: [
                        sectionHeader('Configuración', Icons.settings),
                        sectionOption('Ubicación continua', [
                          Switch.adaptive(
                            value: settings.alwaysLocation,
                            onChanged: (change) {
                              setState(() {
                                settings.alwaysLocation = change;
                              });
                              saveSetting('alwaysLocation', change);
                            },
                          )
                        ]),
                        sectionOption('Modo de operación', []),
                        RadioListTile<dynamic>(
                          title: Row(
                            children: [
                              Text('Online'),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          value: OperationMode.Online,
                          groupValue: settings.operationMode,
                          onChanged: (dynamic value) {
                            activateOnlineMode();
                          },
                        ),
                        RadioListTile<dynamic>(
                          title: Row(
                            children: [
                              Text('Offline'),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          value: OperationMode.Offline,
                          groupValue: settings.operationMode,
                          onChanged: (dynamic value) {
                            setState(() {
                              settings.operationMode = OperationMode.Offline;
                            });
                            saveSetting('operationMode', OperationMode.Offline);
                            activateOfflineMode();
                          },
                        ),
                        sectionHeader('Pantallas', Icons.devices_fold),
                        sectionOption('Todas las cuotas', [
                          Switch.adaptive(
                            value: settings.showAllInstallmentsScreen,
                            onChanged: (change) {
                              setState(() {
                                settings.showAllInstallmentsScreen = change;
                              });
                              saveSetting('showAllInstallmentsScreen', change);
                            },
                          )
                        ]),
                        sectionHeader('Pago', Icons.payments),
                        sectionOption('Mostrar recibo después de pago', [
                          Switch.adaptive(
                            value: settings.showReceiptAfterPayment,
                            onChanged: (change) {
                              setState(() {
                                settings.showReceiptAfterPayment = change;
                              });
                              saveSetting('showReceiptAfterPayment', change);
                            },
                          )
                        ]),
                        sectionHeader('Recibo', Icons.receipt_long_outlined),
                        sectionOption('Tamaño de letras', []),
                        RadioListTile<dynamic>(
                          title: Row(
                            children: [
                              Text('Pequeño'),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          value: ReceiptFontSize.Small,
                          groupValue: settings.receiptFontSize,
                          onChanged: (dynamic value) {
                            setState(() {
                              settings.receiptFontSize = ReceiptFontSize.Small;
                            });
                            saveSetting('receiptFontSize', ReceiptFontSize.Small);
                          },
                        ),
                        RadioListTile<dynamic>(
                          title: Row(
                            children: [
                              Text('Normal'),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          value: ReceiptFontSize.Normal,
                          groupValue: settings.receiptFontSize,
                          onChanged: (dynamic value) {
                            setState(() {
                              settings.receiptFontSize = ReceiptFontSize.Normal;
                            });
                            saveSetting('receiptFontSize', ReceiptFontSize.Normal);
                          },
                        ),
                        RadioListTile<dynamic>(
                          title: Row(
                            children: [
                              Text('Grande'),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          value: ReceiptFontSize.Large,
                          groupValue: settings.receiptFontSize,
                          onChanged: (dynamic value) {
                            setState(() {
                              settings.receiptFontSize = ReceiptFontSize.Large;
                            });
                            saveSetting('receiptFontSize', ReceiptFontSize.Large);
                          },
                        ),
                        sectionOption('Logo', []),
                        RadioListTile<dynamic>(
                          title: Row(
                            children: [
                              Text('Imagen'),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          value: ReceiptLogoType.Image,
                          groupValue: settings.receiptLogoType,
                          onChanged: (dynamic value) {
                            setState(() {
                              settings.receiptLogoType = ReceiptLogoType.Image;
                            });
                            saveSetting('receiptLogoType', ReceiptLogoType.Image);
                          },
                        ),
                        RadioListTile<dynamic>(
                          title: Row(
                            children: [
                              Text('Texto'),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          value: ReceiptLogoType.Text,
                          groupValue: settings.receiptLogoType,
                          onChanged: (dynamic value) {
                            setState(() {
                              settings.receiptLogoType = ReceiptLogoType.Text;
                            });
                            saveSetting('receiptLogoType', ReceiptLogoType.Text);
                          },
                        ),
                      ]),
                ),
              ),
            ),
          )),
        ]));
  }
}
