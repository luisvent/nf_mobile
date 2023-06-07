import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:nf_mobile/providers/settings_provider.dart';
import 'package:nf_mobile/providers/tab_navigation_provider.dart';
import 'package:nf_mobile/screens/all_installments_screen.dart';
import 'package:nf_mobile/screens/home_dashboard_screen.dart';
import 'package:nf_mobile/screens/loans_screen.dart';
import 'package:nf_mobile/screens/todays_route_screen.dart';
import 'package:nf_mobile/utilities/providers.dart';
import 'package:provider/provider.dart';

class TabbedLayoutComponent extends StatefulWidget {
  const TabbedLayoutComponent({Key? key}) : super(key: key);
  @override
  _TabbedLayoutComponentState createState() => new _TabbedLayoutComponentState();
}

class _TabbedLayoutComponentState extends State<TabbedLayoutComponent> {
  int _currentTab = 0;
  int totalTransactionRequests = 0;

  final LabeledGlobalKey<HomeDashboardScreenState> dashboardScreenKey = LabeledGlobalKey("Dashboard Screen");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setTab(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    List<Widget> screens = [
      HomeDashboardScreen(
        setTab: setTab,
        key: dashboardScreenKey,
      ),
      LoansScreen(setTab: setTab),
      if (settingsProvider.settings!.showAllInstallmentsScreen) AllInstallmentsScreen(setTab: setTab),
      TodaysRouteScreen()
      // AllContactsScreen(
      //   userAuthKey: userAuthKey,
      //   setTab: setTab,
      // ),
      // AllTransactionActivities(
      //   user: widget.userData,
      //   userAuthKey: userAuthKey,
      //   setTab: setTab,
      //   key: transactionActivitiesScreenKey,
      // ),
      // WalletScreen(
      //   setTab: setTab,
      //   user: widget.userData,
      // ),
    ];

    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        // backgroundColor: Colors.white,
        backgroundColor: Color(0xfffefefe),

        extendBodyBehindAppBar: true,

        bottomNavigationBar: googleNavBar(),

        body: screens.isEmpty ? Text("Loading...") : screens[_currentTab],
      ),
    );
  }

  Widget googleNavBar() {
    final settingsProvider = context.watch<SettingsProvider>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(0)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0xff1546a0).withOpacity(0.1), blurRadius: 20, offset: Offset(2, -2), spreadRadius: 0),
        ],
        color: Colors.white,
      ),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.18, vertical: 1),
          child: GNav(
            haptic: true,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            gap: 6,
            activeColor: Color(0xFF0070BA),
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            duration: Duration(milliseconds: 300),
            color: Color(0xFF243656),
            tabs: [
              GButton(
                icon: FluentIcons.home_person_24_regular,
                text: 'Hoy',
                iconSize: 34,
              ),
              GButton(
                icon: FluentIcons.people_money_24_regular,
                iconSize: 36,
                text: 'Préstamos',
              ),
              if (settingsProvider.settings!.showAllInstallmentsScreen)
                GButton(
                  icon: FluentIcons.money_calculator_24_regular,
                  iconSize: 36,
                  text: 'Cobros',
                ),
              GButton(
                icon: FluentIcons.arrow_routing_24_regular,
                iconSize: 36,
                text: 'Ruta',
              ),
              // GButton(
              //   icon: FluentIcons.alert_32_regular,
              //   iconActiveColor: Color(0xFF0070BA),
              //   text: 'Activities',
              //   leading: Stack(
              //     children: [
              //       Icon(
              //         FluentIcons.alert_32_regular,
              //         color: _currentTab == 2
              //             ? Color(0xFF0070BA)
              //             : Color(0xFF243656),
              //         size: 36,
              //       ),
              //       if (unreadTransactions > 0)
              //         Positioned(
              //           top: 0,
              //           right: 0,
              //           child: ClipOval(
              //             child: Container(
              //                 color: Color(0xffffb3c1),
              //                 width: 17,
              //                 height: 17,
              //                 child: Center(
              //                   child: Text(unreadTransactions.toString(),
              //                       textAlign: TextAlign.center,
              //                       style: TextStyle(
              //                           fontSize: 9.6,
              //                           fontWeight: FontWeight.bold,
              //                           color: Color(0xffc9184a),
              //                           backgroundColor: Color(0xffffb3c1))),
              //                 )),
              //           ),
              //         )
              //     ],
              //   ),
              // ),
            ],
            selectedIndex: _currentTab,
            onTabChange: _onTabChange,
          )),
    );
  }

  void _onTabChange(index) {
    if (Providers.Sync(context).syncing) {
      return;
    }

    if (_currentTab == 1 || _currentTab == 2) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    Provider.of<TabNavigationProvider>(context, listen: false).updateTabs(_currentTab);
    setState(() {
      _currentTab = index;
    });
  }

  Future<bool> _onBackPress() {
    if (_currentTab == 0) {
      return Future.value(true);
    } else {
      int lastTab = Provider.of<TabNavigationProvider>(context, listen: false).lastTab;
      Provider.of<TabNavigationProvider>(context, listen: false).removeLastTab();
      setTab(lastTab);
    }
    return Future.value(false);
  }
}
