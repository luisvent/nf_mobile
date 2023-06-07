import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nf_mobile/components/installment/installments_list.dart';
import 'package:nf_mobile/components/sheet_options/android_sheet_options.dart';
import 'package:nf_mobile/database/loan_interaction_storage.dart';
import 'package:nf_mobile/database/loan_note_storage.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/payment_storage.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/Activity.dart';
import 'package:nf_mobile/interface/Installments.dart';
import 'package:nf_mobile/interface/Loan.dart';
import 'package:nf_mobile/interface/LoanInteractions.dart';
import 'package:nf_mobile/interface/LoanNotes.dart';
import 'package:nf_mobile/interface/Settings.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:nf_mobile/utilities/widget_factory.dart';

class LoanDetailsScreen extends StatefulWidget {
  final Function setTab;
  late Loan loan;

  LoanDetailsScreen({Key? key, required this.loan, required this.setTab}) : super(key: key);

  @override
  LoanDetailsScreenState createState() => LoanDetailsScreenState();
}

class LoanDetailsScreenState extends State<LoanDetailsScreen> {
  List<bool> _activeToggleMenu = [true, false, false];
  Map<String, dynamic>? error = null;
  late TextEditingController activitySearch;
  UserDataStorage userDataStorage = UserDataStorage();
  LoanInteractionStorage loanInteractionStorage = LoanInteractionStorage();
  PaymentStorage paymentStorage = PaymentStorage();
  LoanNoteStorage loanNoteStorage = LoanNoteStorage();
  LoansStorage loansStorage = LoansStorage();
  List<Installments> installments = [];
  List<Activity> activities = [];
  String titleName = '';
  Settings settings = Settings.Empty();

  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );

  ButtonStyle buttonStyle = ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0);

  @override
  void initState() {
    super.initState();
    getInstallments();
    getTitleName();
    getActivities();
    getSettings();
    activitySearch = TextEditingController();
  }

  getSettings() async {
    settings = await Providers.Settings(context).GetSettings();
  }

  getActivities() async {
    final List<Activity> loanActivities = [];
    final payments = await paymentStorage.GetPaymentsForLoan(widget.loan.id as int);
    final notes = widget.loan.loanNotes!.map<Activity>((e) => e.ToActivity()).toList();
    final interactions = widget.loan.loanInteractions!.map<Activity>((e) => e.ToActivity()).toList();
    final paymentActivities = payments.map<Activity>((p) => p.ToActivity());
    loanActivities.addAll(notes);
    loanActivities.addAll(interactions);
    loanActivities.addAll(paymentActivities);

    print(loanActivities);
    setState(() {
      activities = loanActivities;
    });
  }

  getTitleName() {
    setState(() {
      titleName = "Préstamo No. " + widget.loan.id.toString();
    });
  }

  reloadLoanAndInstallments() async {
    final updatedLoan = await loansStorage.GetLoan(widget.loan.id as int);
    setState(() {
      widget.loan = updatedLoan;
    });
    getInstallments();
    getActivities();
  }

  void getInstallments() async {
    final i;
    if (widget.loan == null) {
      i = await loansStorage.GetInstallments();
    } else {
      i = widget.loan.installments;
    }

    setState(() {
      installments = i;
    });
  }

  void goBack() {
    Navigator.pop(context);
  }

  Future<bool> ableToAddActivity() async {
    if (settings.operationMode == OperationMode.Online) {
      final connectivity = await Tools.HasInternetConnectivity();

      if (!connectivity) {
        Tools.ShowSnackbar(context, 'No hay conexión a Internet', Colors.red, 4);
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  Future<void> openInteractionModal() async {
    final ableToAdd = await ableToAddActivity();
    if (!ableToAdd) {
      return;
    }

    final interactions = [
      {'title': 'Llamada sin comunicación', 'id': 1, 'icon': Icons.phone_disabled},
      {'title': 'Visita, cliente no estaba', 'id': 2, 'icon': Icons.person_off_outlined},
      {'title': 'Visita de cobro/sin pago', 'id': 3, 'icon': Icons.money_off},
      {'title': 'Envío de cartas de cobros', 'id': 4, 'icon': Icons.local_post_office_outlined},
      {'title': 'Negocio cerrado', 'id': 5, 'icon': Icons.highlight_off_rounded},
    ];

    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => AndroidSheetOptions(interactions, (i) {
        print(i);
        addInteraction(i);
      }),
    );
  }

  Future<void> createNote() async {
    final ableToAdd = await ableToAddActivity();
    if (!ableToAdd) {
      return;
    }

    showNoteDialog(context, 'Agregar Nota', '', (String note) {
      if (note != '') {
        addNote(note);
      }
    });
  }

  addInteraction(dynamic interaction) async {
    final userData = await userDataStorage.GetUserData();

    final loanInteraction = LoanInteractions(
        date: Tools.LongDate(),
        loanId: widget.loan.id,
        interactionTypeId: interaction['id'],
        employeeId: userData!.id,
        longitude: 0.0,
        latitude: 0.0);
    await loanInteraction.SetLocation();

    loanInteractionStorage.AddLoanInteraction(loanInteraction);
    widget.loan.loanInteractions!.insert(0, loanInteraction);
    loansStorage.SaveLoan(widget.loan);
    getActivities();
    Tools.ShowSnackbar(context, 'Interacción Agregada', Colors.blue);

    if (settings.operationMode == OperationMode.Online) {
      Providers.Sync(context).SendLoanInteractions();
    }
  }

  addNote(String note) async {
    final userData = await userDataStorage.GetUserData();

    final loanNote =
        LoanNotes(date: Tools.LongDate(), loanId: widget.loan.id, description: note, employeeId: userData!.id, longitude: 0.0, latitude: 0.0);
    await loanNote.SetLocation();

    loanNoteStorage.AddLoanNote(loanNote);
    widget.loan.loanNotes!.insert(0, loanNote);
    loansStorage.SaveLoan(widget.loan);
    getActivities();
    Tools.ShowSnackbar(context, 'Nota Agregada', Colors.blue);
    if (settings.operationMode == OperationMode.Online) {
      Providers.Sync(context).SendLoanNotes();
    }
  }

  void showNoteDialog(BuildContext context, String title, String message, Function callback) {
    Decoration buttonDecoration = BoxDecoration(
      boxShadow: [BoxShadow(color: Colors.blueGrey.shade100, offset: Offset(0, 4), blurRadius: 5.0)],
      gradient: RadialGradient(colors: [Color(0xff0070BA), Color(0xff1546A0)], radius: 8.4, center: Alignment(-0.24, -0.36)),
      borderRadius: BorderRadius.circular(10),
    );
    ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      primary: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    final noteController = TextEditingController();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: Container(
                height: 200,
                child: Column(
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: 150,
                      child: TextFormField(
                        controller: noteController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (value) {
                          Navigator.of(context).pop();
                          callback(value);
                        },
                        validator: (value) {
                          return null;
                        },
                        obscureText: false,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                          hintStyle: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
                        ),
                      ),
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Color(0xFFF5F7FA)),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                // blurRadius: 6.18,
                                spreadRadius: 0.618,
                                blurRadius: 6.18,
                                // spreadRadius: 6.18,
                                offset: Offset(-4, -4),
                                // color: Colors.white38
                                color: Color(0xFFF5F7FA)),
                            BoxShadow(
                                blurRadius: 6.18,
                                // spreadRadius: 6.18,
                                spreadRadius: 0.618,
                                offset: Offset(4, 4),
                                color: Colors.blueGrey.shade100
                                // color: Color(0xFFF5F7FA)
                                )
                          ]),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 48,
                          width: 100,
                          decoration: buttonDecoration,
                          child: ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar'), style: buttonStyle),
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Container(
                          height: 48,
                          width: 100,
                          decoration: buttonDecoration,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                callback(noteController.value.text);
                              },
                              child: Text('Agregar'),
                              style: buttonStyle),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                  ],
                )
              ],
            ));
  }

  Widget infoHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 30, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))],
      ),
    );
  }

  Widget dataHeader(String data, String value, IconData icon, [Color valueColor = Colors.blueGrey]) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Row(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey,
                  size: 18,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  data,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                )
              ],
            ),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor))
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        margin: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          // color: Color(0xFF0070BA),
          boxShadow: <BoxShadow>[
            BoxShadow(
                /*
                                  color: Color(0xffF5F7FA),
                                  blurRadius: 4,
                                  offset: Offset(0.0, 3),
                                  spreadRadius: 0
                                  */
                color: Color(0xff1546a0).withOpacity(0.2),
                blurRadius: 48,
                offset: Offset(2, 8),
                spreadRadius: -10)
          ],
          // color: Colors.blueGrey[50]!.withOpacity(0.5),
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffdfdfd),
      //  backgroundColor: Color(0xfffcfcfc),
      appBar: AppBar(
        leading: widget.loan == null
            ? null
            : IconButton(
                onPressed: () {
                  goBack();
                },
                icon: Icon(Icons.arrow_back, color: Color(0xff243656))),
        title: Text(titleName, style: TextStyle(color: Color(0xff243656))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Column(children: <Widget>[
        SizedBox(
          height: 100,
        ),
        Container(
          height: 30,
          decoration: BoxDecoration(color: Color(0xffF5F7FA), borderRadius: BorderRadius.circular(10)),
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xff929BAB),
            fillColor: Color(0xFF0070BA),
            selectedColor: Colors.white,
            renderBorder: false,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Info",
                    style: TextStyle(fontSize: 16),
                  )),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Actividad",
                    style: TextStyle(fontSize: 16),
                  )),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Cuotas",
                    style: TextStyle(fontSize: 16),
                  )),
            ],
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0; buttonIndex < _activeToggleMenu.length; buttonIndex++) {
                  if (buttonIndex == index) {
                    _activeToggleMenu[buttonIndex] = true;
                  } else {
                    _activeToggleMenu[buttonIndex] = false;
                  }
                }
              });
            },
            isSelected: _activeToggleMenu,
          ),
        ),
        SizedBox(
          height: 25,
        ),
        if (_activeToggleMenu[0])
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        infoHeader('Préstamo'),
                        dataHeader('Préstamo No.', widget.loan.id.toString(), Icons.numbers),
                        dataHeader('Monto', '\$ ' + Tools.FormatCurrency(widget.loan.amount!), Icons.monetization_on_outlined),
                        dataHeader('Deuda', '\$ ' + Tools.FormatCurrency(widget.loan.totalDebt), Icons.money, Colors.red),
                        dataHeader('Inicio', widget.loan.startDate.toString(), Icons.date_range),
                        infoHeader('Cliente'),
                        dataHeader('Nombre', widget.loan.loanApplication!.client!.fullName!, Icons.person_outline_rounded),
                        dataHeader('Telefono', widget.loan.loanApplication!.client!.phoneNumber!, Icons.phone),
                        dataHeader('Negocio', widget.loan.loanApplication!.client!.businessName!, Icons.store_mall_directory_outlined),
                        // dataHeader('Dirección',
                        //     widget.loan.loanApplication!.client!.address!),
                        infoHeader('Cuotas'),
                        dataHeader('Total', widget.loan.totalInstallments.toString(), Icons.add_task_rounded),
                        dataHeader('Pendiente', widget.loan.installments!.where((i) => !i.paid!).length.toString(), Icons.pending_outlined),
                        dataHeader('Vencidas', widget.loan.expiredInstallments.toString(), Icons.edit_calendar_sharp),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_activeToggleMenu[1])
          Expanded(
              child: Container(
            height: 300,
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(5),
                  height: 40,
                  decoration: BoxDecoration(
                    // boxShadow: <BoxShadow>[
                    //   BoxShadow(
                    //       /*
                    //             color: Color(0xffF5F7FA),
                    //             blurRadius: 4,
                    //             offset: Offset(0.0, 3),
                    //             spreadRadius: 0
                    //             */
                    //       color: Color(0xff1546a0).withOpacity(0.1),
                    //       blurRadius: 18,
                    //       offset: Offset(2, 8),
                    //       spreadRadius: 5),
                    // ],
                    // color: Color(0xFF0070BA),
                    color: Colors.blueGrey[50]!.withOpacity(0.5),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        label: Text(
                          "Agregar Nota",
                          style: TextStyle(color: Color(0xff929BAB)),
                        ),
                        icon: Icon(
                          Icons.comment,
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
                        onPressed: () => {createNote()},
                      ),
                      OutlinedButton.icon(
                        label: Text(
                          "Agregar Interacción",
                          style: TextStyle(color: Color(0xff929BAB)),
                        ),
                        icon: Icon(
                          Icons.local_activity,
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
                        onPressed: () => {openInteractionModal()},
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    child: WidgetFactory.BuildActivitiesList(context, activities),
                  ),
                ),
              ],
            ),
          )),
        if (_activeToggleMenu[2])
          InstallmentsList(
              installmentsQuantity: installments.length,
              installments: installments,
              activeToggleMenu: [true, false, false],
              reloadData: reloadLoanAndInstallments)
      ]),
    );
  }
}
