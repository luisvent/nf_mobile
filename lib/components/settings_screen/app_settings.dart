import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nf_mobile/resources/constants.dart';
import 'package:nf_mobile/screens/backup_screen.dart';
import 'package:nf_mobile/screens/developer_settings_screen.dart';
import 'package:nf_mobile/screens/general_settings_screen.dart';
import 'package:nf_mobile/screens/login_screen.dart';
import 'package:nf_mobile/screens/permissions_config_screen.dart';
import 'package:nf_mobile/screens/printer_config_screen.dart';
import 'package:nf_mobile/utilities/hadwin_markdown_viewer.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/slide_right_route.dart';
import 'package:nf_mobile/utilities/tools.dart';

class AppSettingsComponent extends StatefulWidget {
  const AppSettingsComponent({Key? key}) : super(key: key);

  @override
  State<AppSettingsComponent> createState() => _AppSettingsComponentState();
}

class _AppSettingsComponentState extends State<AppSettingsComponent> {
  bool isDeveloper = false;
  int logoTaps = 0;

  void toggleDeveloperSettings() {
    setState(() {
      isDeveloper = !isDeveloper;
    });

    Tools.ShowSnackbar(context, 'Developer Settings ' + (isDeveloper ? 'Activated' : 'Deactivated'), Colors.blue, 3);
  }

  @override
  Widget build(BuildContext context) {
    final data = _settingsMenu(context);

    return ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (_, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ListTile(
              textColor: Color(0xff243656),
              contentPadding: EdgeInsets.all(5),
              title: data[index]['title'],
              trailing: data[index]['trailing'],
              onTap: data[index]['onTap'],
            ),
          );
        },
        separatorBuilder: (_, b) => Divider(
              height: 6,
              color: Colors.grey.shade300,
            ),
        itemCount: data.length);
  }

  List<dynamic> _settingsMenu(BuildContext context) {
    List<dynamic> settingsMenuItems = [
      // {
      //   'title': Text('Credits'),
      //   'trailing': Icon(FluentIcons.star_emphasis_24_regular),
      //   'onTap': () {
      //     Navigator.push(context, SlideRightRoute(page: CreditsScreen()));
      //   },
      //   'settingsCategory': 'About the app',
      // },
      // {
      //   'title': Text('Privacy Policy'),
      //   'trailing': Icon(FluentIcons.info_24_regular),
      //   'onTap': () =>
      //       openDocsViewer('PRIVACY_POLICY', 'Privacy Policy', context),
      //   'settingsCategory': 'About the app',
      // },
      // {
      //   'title': Text('Terms of use'),
      //   'trailing': Icon(FluentIcons.info_24_regular),
      //   'onTap': () => openDocsViewer(
      //       'TERMS_AND_CONDITIONS', 'Terms & Conditions', context),
      //   'settingsCategory': 'About the app',
      // },
      // {
      //   'title': Text('End User License Agreement'),
      //   'trailing': Icon(FluentIcons.info_24_regular),
      //   'onTap': () => openDocsViewer('END_USER_LICENSE_AGREEMENT',
      //       'End User License Agreement', context),
      //   'settingsCategory': 'About the app',
      // },
      // {
      //   'title': Text('Share feedback'),
      //   'trailing': Icon(FluentIcons.person_feedback_24_regular),
      //   'onTap': () {
      //     Navigator.push(
      //         context, SlideRightRoute(page: AppCreatorInfoScreen()));
      //   },
      //   'settingsCategory': 'About the app',
      // },
      {
        'title': Text('Ajustes'),
        'trailing': Icon(FluentIcons.edit_settings_24_regular),
        'onTap': () {
          Navigator.push(context, SlideRightRoute(page: GeneralSettingsScreen()));
        },
        'settingsCategory': 'General',
      },
      {
        'title': Text('Impresora'),
        'trailing': Icon(FluentIcons.print_24_regular),
        'onTap': () => {Navigator.push(context, SlideRightRoute(page: PrinterConfigScreen()))},
        'settingsCategory': 'General',
      },
      {
        'title': Text('Permisos'),
        'trailing': Icon(FluentIcons.box_toolbox_24_regular),
        'onTap': () => {Navigator.push(context, SlideRightRoute(page: PermissionConfigScreen()))},
        'settingsCategory': 'General',
      },
      {
        'title': Text('Borrar Datos'),
        'trailing': Icon(FluentIcons.delete_dismiss_20_regular),
        'onTap': () {
          Tools.ShowConfirmDialog(context, 'Borrar Datos', 'Esta seguro que desea borrar todos los datos?', 'Ok', () async {
            final clear = await Providers.UserState(context).clearData();

            if (clear) {
              Tools.ShowSnackbar(context, 'Datos Eliminados', Colors.blue, 4);
            } else {
              Tools.ShowSnackbar(context, 'Error Eliminando Datos', Colors.red, 4);
            }
          }, 'Cancelar');
        },
        'settingsCategory': 'About the app',
      },
      {
        'title': Text('Backup'),
        'trailing': Icon(FluentIcons.cloud_arrow_up_24_regular),
        'onTap': () => {Navigator.push(context, SlideRightRoute(page: BackupScreen()))},
        'settingsCategory': 'General',
      },
      {
        'title': Text(
          'Salir',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        'trailing': Icon(FluentIcons.sign_out_24_regular, color: Colors.black),
        'onTap': () async {
          final allSynced = await Providers.Sync(context).allSynced;

          if (!allSynced) {
            Tools.ShowConfirmDialog(
                context, 'Datos Sin Enviar', 'Existen datos sin registrar, por favor registre los datos antes de salir', '', () => {}, 'Ok');
          } else {
            bool logOutStatus = await Providers.UserState(context).logOutUser();
            if (logOutStatus) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
            }
          }
        },
        'settingsCategory': 'General',
      },
      if (isDeveloper)
        {
          'title': Text(
            'Developer',
            style: TextStyle(color: Colors.blue),
          ),
          'trailing': Icon(FluentIcons.window_dev_tools_24_regular, color: Colors.blue),
          'onTap': () {
            Navigator.push(context, SlideRightRoute(page: DeveloperSettingsScreen()));
          },
          'settingsCategory': 'General',
        },
      {
        'title': Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          padding: EdgeInsets.all(7),
          alignment: Alignment.center,
          child: GestureDetector(
              onTap: () {
                if (logoTaps >= 10) {
                  toggleDeveloperSettings();
                  logoTaps = 0;
                } else {
                  logoTaps++;
                }
              },
              child: Image.asset('assets/images/tq_logo.png')),
        ),
        'trailing': null,
        'onTap': null,
        'settingsCategory': 'About the app',
      },
      {
        'title': Container(
          height: 60,
          alignment: Alignment.center,
          child: Column(
            children: [Text(Constants.version)],
          ),
        ),
        'trailing': null,
        'onTap': null,
        'settingsCategory': 'About the app',
      },

      // {
      //   'title': Padding(
      //       padding: EdgeInsets.symmetric(horizontal: 48, vertical: 0),
      //       child: Image.asset(
      //         'assets/images/hadwin_system/hadwin-logo-with-name.png',
      //       )),
      //   'trailing': null,
      //   'onTap': null,
      //   'settingsCategory': 'About the app',
      // },
    ];

    return settingsMenuItems;
  }

  void openDocsViewer(String docName, String screenName, BuildContext context) {
    Navigator.push(
        context,
        SlideRightRoute(
            page: HadWinMarkdownViewer(
          screenName: screenName,
          urlRequested: 'https://raw.githubusercontent.com/brownboycodes/nf_mobile/master/docs/$docName.md',
        )));
  }
}
