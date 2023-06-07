import 'package:flutter/material.dart';
import 'package:nf_mobile/components/settings_screen/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  final AppBar appBar = AppBar(
    title: Text(''),
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xff243656),
    elevation: 0,
  );

  @override
  Widget build(BuildContext context) {
    Column appSettings = Column(
      children: [
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 180,
            child: AppSettingsComponent(),
          ),
        )
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: appSettings,
    );
  }
}
