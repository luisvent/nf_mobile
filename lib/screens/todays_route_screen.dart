import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nf_mobile/database/activity_storage.dart';
import 'package:nf_mobile/interface/Activity.dart';
import 'package:nf_mobile/resources/printer.dart';
import 'package:nf_mobile/utilities/widget_factory.dart';

class TodaysRouteScreen extends StatefulWidget {
  TodaysRouteScreen({Key? key}) : super(key: key);

  @override
  TodaysRouteScreenState createState() => TodaysRouteScreenState();
}

class TodaysRouteScreenState extends State<TodaysRouteScreen> {
  late TextEditingController activitySearch;
  ActivityStorage activityStorage = ActivityStorage();

  Printer printerController = Printer();
  List<Activity> activities = [];

  Widget appBarTitle = Text("Ruta", style: TextStyle(color: Color(0xff243656)));
  List<dynamic> markers = [];

  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );

  String ticket = '';

  @override
  void initState() {
    super.initState();
    loadMarkers();
    activitySearch = TextEditingController();
  }

  Future<void> loadMarkers() async {
    final toMarkers = [];
    List<Activity> allActivities = await activityStorage.GetAllActivities();

    allActivities.forEach((activity) {
      toMarkers.add(activity.ToMarker());
    });

    setState(() {
      activities = allActivities;
      markers = toMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          title: appBarTitle,
          centerTitle: true,
          actions: [],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Column(children: <Widget>[
          SizedBox(
            height: 85,
          ),
          Expanded(
              child: Container(
                  height: 300,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (markers.length > 0)
                        Container(
                            height: height - 350,
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            decoration: BoxDecoration(
                              // color: Color(0xFF0070BA),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
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
                                    spreadRadius: -10),
                              ],
                            ),
                            child: FutureBuilder(
                                future: WidgetFactory.GMaps(markers),
                                builder: (BuildContext context, AsyncSnapshot<Widget> map) {
                                  return map.data == null ? Container() : map.data as Widget;
                                })),
                      if (markers.length == 0)
                        Center(
                          child: Text(
                            'Sin datos de ruta',
                            style: TextStyle(color: Colors.blueGrey[300]),
                          ),
                        )
                    ],
                  ))),
          Container(
            height: height - 650,
            child: WidgetFactory.BuildActivitiesList(context, activities, true),
          )
        ]));
  }
}
