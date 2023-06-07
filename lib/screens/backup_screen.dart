import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nf_mobile/api/api.email.dart';
import 'package:nf_mobile/database/backup_storage.dart';
import 'package:nf_mobile/utilities/display_error_alert.dart';
import 'package:nf_mobile/utilities/tools.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  BackupScreenState createState() => BackupScreenState();
}

class BackupScreenState extends State<BackupScreen> {
  BackupStorage backupStorage = BackupStorage();
  Widget appBarTitle = Text("Backup", style: TextStyle(color: Color(0xff243656)));
  dynamic backups = [];

  @override
  void initState() {
    super.initState();
    loadBackups();
  }

  Future<void> loadBackups() async {
    final savedBackups = await backupStorage.GetBackupData();
    setState(() {
      backups = savedBackups;
    });
  }

  Future<void> sendBackup() async {
    final internetConnection = await Tools.HasInternetConnectivity();
    if (!internetConnection) {
      showErrorAlert(context, {'internetConnectionError': 'No hay conexión a Internet'});
      return;
    }

    Tools.ShowSnackbar(context, 'Enviando Backup', Colors.blue, 2);
    Tools.ShowLoading(loadingMessage: 'Enviando Backup');
    final backup = await backupStorage.GetBackupData();
    final emailSent = await APIEmail.SendBackupEmail(backup);

    if (emailSent.error) {
      Tools.ShowSnackbar(context, 'Error Enviando Backup', Colors.red);
    } else {
      Tools.ShowSnackbar(context, 'Backup Enviado', Colors.green);
      deleteBackup();
    }
    Tools.HideLoading();
  }

  void deleteBackup() {
    backupStorage.DeleteFile();
    Tools.ShowSnackbar(context, 'Backup Eliminado');
    setState(() {
      backups = [];
    });
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
            height: 300,
            width: double.infinity,
            child: AnimationLimiter(
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_queue,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Backups en memoria',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blueGrey),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (backups.length == 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            Text(
                              'No hay backups salvados',
                              style: TextStyle(color: Colors.blueGrey[200]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      for (var backup in backups)
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 40,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.cloud_queue,
                                    color: Color(0xff929BAB),
                                  ),
                                  Text(backup['date'], style: TextStyle(color: Color(0xff929BAB)))
                                ],
                              ),
                              decoration: BoxDecoration(color: Colors.blueGrey[50]!.withOpacity(0.5)),
                            ),
                            Container(
                              height: 2,
                              decoration: BoxDecoration(color: Colors.white),
                            )
                          ],
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (backups.length > 0)
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(2),
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50]!.withOpacity(0.5),
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: Container(
                                child: OutlinedButton.icon(
                                  label: Text(
                                    "Enviar Backups",
                                    style: TextStyle(color: Color(0xff929BAB)),
                                  ),
                                  icon: Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 24.0,
                                    color: Color(0xff929BAB),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey[50],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    primary: Colors.blue,
                                    side: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  onPressed: () {
                                    sendBackup();
                                  },
                                ),
                                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                              )),
                            ],
                          ),
                        ),
                      if (backups.length > 0)
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(2),
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50]!.withOpacity(0.5),
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: Container(
                                child: OutlinedButton.icon(
                                  label: Text(
                                    "Borrar Backups",
                                    style: TextStyle(color: Color(0xff929BAB)),
                                  ),
                                  icon: Icon(
                                    Icons.cloud_off,
                                    size: 24.0,
                                    color: Color(0xff929BAB),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey[50],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    primary: Colors.blue,
                                    side: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  onPressed: () {
                                    deleteBackup();
                                  },
                                ),
                                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                              )),
                            ],
                          ),
                        ),
                    ]),
              ),
            ),
          )),
        ]));
  }
}
