import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nf_mobile/components/installment/installments_list.dart';
import 'package:nf_mobile/database/loans_storage.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/Installments.dart';

class AllInstallmentsScreen extends StatefulWidget {
  final Function setTab;
  AllInstallmentsScreen({Key? key, required this.setTab}) : super(key: key);

  @override
  AllInstallmentsScreenState createState() => AllInstallmentsScreenState();
}

class AllInstallmentsScreenState extends State<AllInstallmentsScreen> {
  List<bool> _activeToggleMenu = [true, false, false];
  Map<String, dynamic>? error = null;
  UserDataStorage userDataStorage = UserDataStorage();
  LoansStorage loansStorage = LoansStorage();
  List<Installments> installments = [];

  Widget appBarTitle = Text("Todas Las Cuotas", style: TextStyle(color: Color(0xff243656)));

  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );

  @override
  void initState() {
    super.initState();
    getInstallments();
  }

  void getInstallments() async {
    final inst = await loansStorage.GetInstallments();
    setState(() {
      installments = inst;
    });
  }

  void goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          leading: null,
          title: appBarTitle,
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
                      "Todos",
                      style: TextStyle(fontSize: 16),
                    )),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Pendiente",
                      style: TextStyle(fontSize: 16),
                    )),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Pagos",
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
          FutureBuilder<List<Installments>>(
              initialData: [],
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Installments>> snapshot,
              ) {
                return InstallmentsList(
                  installmentsQuantity: installments.length,
                  installments: installments,
                  activeToggleMenu: _activeToggleMenu,
                  reloadData: () => {setState(() {})},
                );
              })
        ]));
  }
}
