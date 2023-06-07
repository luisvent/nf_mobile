import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nf_mobile/api/api.auth.dart';
import 'package:nf_mobile/components/main_app_screen/tabbed_layout_component.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/interface/User.dart';
import 'package:nf_mobile/resources/constants.dart';
import 'package:nf_mobile/utilities/display_error_alert.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';

class LoginFormComponent extends StatefulWidget {
  const LoginFormComponent({Key? key}) : super(key: key);

  @override
  LoginFormComponentState createState() {
    return LoginFormComponentState();
  }
}

class LoginFormComponentState extends State<LoginFormComponent> {
  UserDataStorage userDataStorage = UserDataStorage();
  final _formKey = GlobalKey<FormState>();
  String errorMessage1 = "";
  String errorMessage2 = "";
  String userInput = "";
  String password = "";
  bool processing = false;

  void errorMessageSetter(int fieldNumber, String message) {
    setState(() {
      if (fieldNumber == 1) {
        errorMessage1 = message;
      } else {
        errorMessage2 = message;
      }
    });
  }

  void tryLoggingIn() async {
    final internetConnection = await Tools.HasInternetConnectivity();
    if (!internetConnection) {
      showErrorAlert(context, {'internetConnectionError': 'No hay conexión a Internet'});
      return;
    }

    if (processing) {
      return;
    }

    setState(() {
      processing = true;
    });

    userDataStorage.DeleteFile();

    final authenticateResponse = await APIAuth.AuthenticateUser(userInput, password);

    if (!authenticateResponse.error) {
      Providers.UserState(context).userData = User.fromJson(authenticateResponse.data);
      final syncResult = await Providers.Sync(context).SyncData();

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TabbedLayoutComponent()), (route) => false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(duration: Duration(seconds: 1), content: Text("Login Successful"), backgroundColor: Colors.green))
          .closed
          .then((value) => {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error autenticando el usuario'), backgroundColor: Colors.red));
    }

    setState(() {
      processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: TextFormField(
              initialValue: Constants.production ? '' : 'ktejada',
              // initialValue: '',
              enabled: !processing,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  errorMessageSetter(1, 'you must provide a email-id or username');
                } else {
                  errorMessageSetter(1, "");

                  setState(() {
                    userInput = value;
                  });
                }

                return null;
              },
              autocorrect: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "username or email address",
                hintStyle: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
              ),
              style: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
            ),
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1.0, color: Color(0xFFF5F7FA)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 6.18,
                      spreadRadius: 0.618,
                      offset: Offset(-4, -4),
                      // color: Colors.white38
                      color: Color(0xFFF5F7FA)),
                  BoxShadow(blurRadius: 6.18, spreadRadius: 0.618, offset: Offset(4, 4), color: Colors.blueGrey.shade100
                      // color: Color(0xFFF5F7FA)
                      )
                ]),
          ),
          if (errorMessage1 != '')
            Container(
              child: Text(
                "\t\t\t\t$errorMessage1",
                style: TextStyle(fontSize: 10, color: Colors.red),
              ),
              margin: EdgeInsets.all(2),
              padding: EdgeInsets.all(2),
            ),
          Container(
            child: TextFormField(
              initialValue: Constants.production ? '' : 'INVEREMPRESA2024',
              // initialValue: '',
              enabled: !processing,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) => _validateLoginDetails(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  errorMessageSetter(2, 'password cannot be empty');
                } else {
                  errorMessageSetter(2, "");
                  setState(() {
                    password = value;
                  });
                }
                return null;
              },
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "password",
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
          if (errorMessage2 != '')
            Container(
              child: Text(
                "\t\t\t\t$errorMessage2",
                style: TextStyle(fontSize: 10, color: Colors.red),
              ),
              margin: EdgeInsets.all(2),
              padding: EdgeInsets.all(2),
            ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 16.0),
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.blueGrey.shade100, offset: Offset(0, 4), blurRadius: 5.0)],
              gradient: RadialGradient(colors: [Color(0xff0070BA), Color(0xff1546A0)], radius: 8.4, center: Alignment(-0.24, -0.36)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
                onPressed: processing ? null : _validateLoginDetails,
                child: Text(
                  'Log in',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                )),
          ),
          if (processing)
            Container(
              margin: EdgeInsets.all(20),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LoadingIndicator(
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
                      )
                ],
              ),
            )
        ],
      ),
    );
  }

  void _validateLoginDetails() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      if (errorMessage1 != "" || errorMessage2 != "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please provide all required details'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // _formKey.currentState!.reset();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            onVisible: tryLoggingIn, duration: Duration(seconds: 1), content: Text('Autenticando usuario...'), backgroundColor: Colors.blue));
      }
    }
  }
}
