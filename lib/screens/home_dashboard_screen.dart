import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nf_mobile/database/loan_interaction_storage.dart';
import 'package:nf_mobile/database/loan_note_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/interface/Payment.dart';
import 'package:nf_mobile/interface/Settings.dart';
import 'package:nf_mobile/screens/settings_screen.dart';
import 'package:nf_mobile/utilities/display_error_alert.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/slide_right_route.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:nf_mobile/utilities/widget_factory.dart';

import '../interface/Activity.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function setTab;
  PaymentStorage paymentStorage = PaymentStorage();
  LoanInteractionStorage loanInteractionStorage = LoanInteractionStorage();
  LoanNoteStorage loanNoteStorage = LoanNoteStorage();

  HomeDashboardScreen({Key? key, required this.setTab}) : super(key: key);

  @override
  HomeDashboardScreenState createState() => HomeDashboardScreenState();
}

class HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late List<Map<String, dynamic>> response;
  Map<String, dynamic>? error = null;
  bool syncing = false;
  bool allSynced = false;
  String lastSyncedDate = '';
  List<Activity> activities = [];
  List<Payment> payments = [];
  num todayPaymentsAmount = 0;
  String userName = '';
  String userRole = '';
  String operationMode = OperationMode.Online;

  @override
  void initState() {
    final userData = Providers.UserState(context).userData;
    userName = userData!.fullname;
    userRole = userData!.roles[0].name;
    super.initState();
    getHomeScreenData();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final heightAdded = (statusBarHeight > 0 ? statusBarHeight / 2 : 0) as double;
    List<Widget> dashboardActions = [
      AbsorbPointer(
        absorbing: syncing,
        child: GestureDetector(
          onTap: () => {
            Navigator.push(context, SlideRightRoute(page: SettingsScreen())).then((value) => setState(() {
                  getHomeScreenData();
                }))
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 20,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: ClipOval(
                  child: Icon(
                    color: Colors.white,
                    FluentIcons.panel_right_expand_20_regular,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      )
    ];
    List<Widget> dashboardContents = [
      Container(
          height: 240 + heightAdded,
          width: double.infinity,
          decoration: BoxDecoration(
            // color: Color(0xFF0070BA),
            color: Color(0xff1546A0),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(36),
            ),
          )),
      Positioned(
          child: Opacity(
            opacity: 0.16,
            child: Image.asset(
              "assets/images/hadwin_system/magicpattern-blob-1652765120695.png",
              color: Colors.white,
              height: 480,
            ),
          ),
          left: -156,
          top: -96),
      Positioned(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 85,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/company_logo.png')),
              // Image.asset(
              //   'assets/images/hadwin_system/hadwin-logo-lite.png',
              //   height: 48,
              //   width: 48,
              // ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Hola, ${userName}',
                style: TextStyle(color: Colors.grey.shade300, fontSize: 17),
              ),
              Text(
                '${userRole}',
                style: TextStyle(color: Colors.blueGrey[100], fontSize: 10),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "\$ ${Tools.FormatCurrency(todayPaymentsAmount)}",
                style: TextStyle(color: Colors.white.withOpacity(0.96), fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 6.18,
              ),
              Text(
                "Cobrado Hoy",
                style: TextStyle(color: Colors.white, fontSize: 15),
              )
            ],
          ),
        ),
        bottom: 20,
        left: 10,
      ),
      if (operationMode == OperationMode.Offline)
        Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                Icon(
                  color: Colors.white,
                  allSynced ? Icons.check_circle_outline_outlined : Icons.sync_problem_rounded,
                  size: 34,
                ),
                Text(
                  allSynced ? "Datos Actualizados" : 'Datos Sin Registrar',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Text(
                  'Actualización: ' + lastSyncedDate,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 10),
                )
              ],
            ))
    ];
    List<Widget> transactionButtons = <Widget>[
      Padding(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
            onPressed: () => syncData(),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: syncing ? Alignment.center : Alignment.topLeft,
                  child: syncing
                      ? Container(
                          height: 40,
                          child: LoadingIndicator(
                              indicatorType: Indicator.circleStrokeSpin,

                              /// Required, The loading type of the widget
                              colors: const [Colors.white],

                              /// Optional, The color collections
                              strokeWidth: 4,

                              /// Optional, The stroke of the line, only applicable to widget which contains line
                              backgroundColor: Colors.transparent,

                              /// Optional, Background of the widget
                              pathBackgroundColor: Colors.blueAccent

                              /// Optional, the stroke backgroundColor
                              ),
                        )
                      : Icon(
                          Icons.sync,
                          size: 24,
                        ),
                ),
                Spacer(),
                Text(
                  syncing ? 'Actualizando...' : "Actualizar Data",
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
            style: ElevatedButton.styleFrom(
              // primary: Color(0xFF0070BA),
              primary: Color(0xff1546A0),
              // fixedSize: Size(90, 100),
              fixedSize: Size(96, 108),
              shadowColor: Color(0xFF0070BA).withOpacity(0.618),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )),
      ),
      // Padding(
      //   padding: EdgeInsets.all(10),
      //   child: ElevatedButton(
      //       onPressed: () => _makeATransaction('credit'),
      //       child: Column(children: [
      //         SizedBox(
      //           height: 10,
      //         ),
      //         Align(
      //             alignment: Alignment.topLeft,
      //             child: Icon(
      //               Icons.file_download_outlined,
      //               size: 24,
      //               color: Color(0xFF0070BA),
      //             )),
      //         Spacer(),
      //         Text(
      //           "Request Payment",
      //           style: TextStyle(color: Color(0xFF0070BA), fontSize: 13),
      //         ),
      //         SizedBox(
      //           height: 10,
      //         )
      //       ]),
      //       style: ElevatedButton.styleFrom(
      //         // fixedSize: Size(90, 100),
      //         fixedSize: Size(96, 108),
      //         primary: Colors.white,
      //         shadowColor: Color(0xffF5F7FA).withOpacity(0.618),
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(12)),
      //       )),
      // ),
      // PopupMenuButton<_ScanOptions>(
      //   icon: Icon(
      //     FluentIcons.more_vertical_28_regular,
      //     color: Colors.grey,
      //   ),
      //   offset: Offset(119, -27),
      //   onSelected: (value) {
      //     if (value == _ScanOptions.ScanQRCode) {
      //       // Navigator.push(
      //       //         context, SlideRightRoute(page: QRCodeScannerScreen()))
      //       //     .whenComplete(() => setState(() {}));
      //     } else {
      //       // Navigator.push(context, SlideRightRoute(page: MyQRCodeScreen()))
      //       //     .whenComplete(() => setState(() {}));
      //     }
      //   },
      //   itemBuilder: (context) => [
      //     PopupMenuItem(
      //       child: Text("Scan QR Code"),
      //       value: _ScanOptions.ScanQRCode,
      //     ),
      //     PopupMenuItem(
      //       child: Text("My QR Code"),
      //       value: _ScanOptions.MyQRCode,
      //     )
      //   ],
      // )
    ];
    List<Widget> homeScreenContents = <Widget>[
      Stack(
        children: dashboardContents,
      ),
      if (operationMode == OperationMode.Offline)
        Container(
          padding: EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: transactionButtons,
            ),
          ),
        ),
      Expanded(
          flex: 1,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 150,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          "Actividad de Hoy",
                          style: TextStyle(fontSize: 21, color: Color(0xff243656)),
                        ),
                        Spacer(),
                        // InkWell(
                        //   child: Text("View all",
                        //       style:
                        //           TextStyle(fontSize: 16, color: Colors.grey)),
                        //   onTap: _viewAllActivities,
                        // )
                      ],
                    ),
                    width: double.infinity,
                  ),
                  Expanded(
                    child: Container(
                      height: 145,
                      child: Builder(builder: (context) => WidgetFactory.BuildActivitiesList(context, activities)),
                    ),
                  )
                ],
              )))
    ];

    return Scaffold(
        // backgroundColor: Color.fromARGB(255, 253, 253, 253),
        backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          actions: dashboardActions,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: AbsorbPointer(
                absorbing: syncing,
                child: Column(
                  children: homeScreenContents,
                ),
              ))
        ]));
  }

  Future<void> syncData() async {
    // throw "Test exception";

    final internetConnection = await Tools.HasInternetConnectivity();
    if (!internetConnection) {
      showErrorAlert(context, {'internetConnectionError': 'No hay conexión a Internet'});
      return;
    }

    setState(() {
      syncing = true;
    });

    final message = ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(duration: Duration(seconds: 4), content: Text("Actualizando Datos"), backgroundColor: Colors.blue))
        .closed
        .then((value) => {});

    final syncResult = await Providers.Sync(context).SyncData();

    setState(() {
      syncing = false;
    });

    if (syncResult) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(duration: Duration(seconds: 1), content: Text("Actualización Completa"), backgroundColor: Colors.green));
      getHomeScreenData();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(duration: Duration(seconds: 4), content: Text("Error Actualizando Datos"), backgroundColor: Colors.red));
    }
  }

  Future<void> getHomeScreenData() async {
    final settings = await Providers.Settings(context).GetSettings();
    setState(() {
      operationMode = settings.operationMode;
    });

    final List<Activity> todayActivities = [];
    final allPayments = await widget.paymentStorage.GetPaymentsData();
    final allNotes = await widget.loanNoteStorage.GetNotesData();
    final allInteractions = await widget.loanInteractionStorage.GetInteractionsData();
    final syncedDate = await Providers.Sync(context).lastSyncDate;

    todayActivities.addAll(allPayments.map<Activity>((p) => p.ToActivity()).toList());
    todayActivities.addAll(allNotes.map<Activity>((p) => p.ToActivity()).toList());
    todayActivities.addAll(allInteractions.map<Activity>((p) => p.ToActivity()).toList());

    setState(() {
      payments = allPayments;
      todayPaymentsAmount = allPayments.length > 0 ? payments.map((p) => p.amount).reduce((a, b) => a + b) : 0;

      allSynced = !(payments.any((payment) => !payment.synced) ||
          allNotes.any((note) => !note.synced) ||
          allInteractions.any((interaction) => !interaction.synced));

      Providers.Sync(context).allSynced = allSynced;
      lastSyncedDate = Tools.LongDate(syncedDate);
      activities = todayActivities;
    });
  }
}

enum _ScanOptions { ScanQRCode, MyQRCode }
