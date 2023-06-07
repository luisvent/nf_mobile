import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nf_mobile/components/main_app_screen/local_splash_screen_component.dart';
import 'package:nf_mobile/components/main_app_screen/tabbed_layout_component.dart';
import 'package:nf_mobile/database/hadwin_user_device_info_storage.dart';
import 'package:nf_mobile/database/user_data_storage.dart';
import 'package:nf_mobile/providers/app_controller_provider.dart';
import 'package:nf_mobile/providers/payments_provider.dart';
import 'package:nf_mobile/providers/settings_provider.dart';
import 'package:nf_mobile/providers/share_provider.dart';
import 'package:nf_mobile/providers/sync_provider.dart';
import 'package:nf_mobile/providers/tab_navigation_provider.dart';
import 'package:nf_mobile/providers/user_state_provider.dart';
import 'package:nf_mobile/resources/constants.dart';
import 'package:nf_mobile/screens/login_screen.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

final AppNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      print("Error From INSIDE FRAME_WORK");
      print("----------------------");
      print("Error :  ${details.exception}");
      print("StackTrace :  ${details.stack}");

      if (Constants.production) {
        Tools.FormatErrorAndSend(details.exception.toString(), details.stack);
      }
    };

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabNavigationProvider()),
        ChangeNotifierProvider(create: (_) => UserStateProvider()),
        ChangeNotifierProvider(create: (_) => PaymentsProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => ShareProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AppControllerProvider()),
      ],
      child: MyApp(),
    )); // starting point of app
  }, (error, stackTrace) {
    print("Error FROM OUT_SIDE FRAMEWORK ");
    print("--------------------------------");
    print("Error :  $error");
    print("StackTrace :  $stackTrace");

    if (Constants.production) {
      Tools.FormatErrorAndSend(error.toString(), stackTrace);
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserDeviceInfoStorage userDeviceInfoStorage = UserDeviceInfoStorage();
  UserDataStorage userDataStorage = UserDataStorage();
  bool? _previousllyInstalled = null;
  bool? _isLoggedIn = null;

  void _checkForPreviousInstallations() async {
    final previousllyInstalledStatus = await userDeviceInfoStorage.wasUsedBefore;
    setState(() {
      _previousllyInstalled = previousllyInstalledStatus;
    });
  }

  void _getLoggedInUserData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    Constants.version = version;
    final loggedIn = await Providers.UserState(context).isUserLoggedIn();
    final expired = await Providers.UserState(context).isTokenExpired();

    Providers.UserState(context).userData = await userDataStorage.GetUserData();

    setState(() {
      _isLoggedIn = loggedIn && !expired;
    });

    return;
  }

  Future<void> loadSettings() async {
    // load settings
    Providers.Settings(context).GetSettings();
  }

  @override
  void initState() {
    _cleanUpTemporaryDirectory();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _getLoggedInUserData();
    loadSettings();
    initEasyLoading();
  }

  _cleanUpTemporaryDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    documentsDirectory.parent.list().forEach((child) async {
      if (child is Directory && child.path.endsWith('/tmp')) {
        print('Deleting temp folder at ${child.path}...');
        try {
          await child.delete(recursive: true);
          print('Temp folder was deleted with success');
        } catch (error) {
          print('Temp folder could not be deleted: $error');
        }
      }
    });
  }

  void initEasyLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.light
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: AppNavigatorKey,
        title: 'NF Mobile',
        theme: ThemeData(primarySwatch: Colors.blue, textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme)),
        home: Builder(
          builder: (context) {
            if (_previousllyInstalled == false) {
              FlutterNativeSplash.remove();
              return LoginScreen();
            } else if (_isLoggedIn == true) {
              FlutterNativeSplash.remove();
              return TabbedLayoutComponent();
            } else if (_isLoggedIn == false) {
              FlutterNativeSplash.remove();
              return LoginScreen();
            } else {
              return Material(
                type: MaterialType.transparency,
                child: LocalSplashScreenComponent(),
              );
            }
          },
        ),
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false);
  }
}
