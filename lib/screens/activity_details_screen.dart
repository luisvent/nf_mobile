import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nf_mobile/api/api.geolocation.dart';
import 'package:nf_mobile/interface/Activity.dart';
import 'package:nf_mobile/interface/Geolocation.dart';
import 'package:nf_mobile/resources/printer.dart';
import 'package:nf_mobile/utilities/tools.dart';
import 'package:nf_mobile/utilities/widget_factory.dart';
import 'package:share_plus/share_plus.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Activity activity;
  ActivityDetailsScreen({Key? key, required this.activity}) : super(key: key);

  @override
  ActivityDetailsScreenState createState() => ActivityDetailsScreenState();
}

class ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  late TextEditingController activitySearch;
  Printer printerController = Printer();
  Widget appBarTitle = Text("Detalles de Actividad", style: TextStyle(color: Color(0xff243656)));
  List<dynamic> markers = [];
  String address = '';

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
    APIGeolocation.TranslateCoordinatesToAddress(widget.activity.latitude, widget.activity.longitude).then((result) {
      if (!result.error) {
        final results = result.data['results'] as List;
        if (results.length > 0) {
          final geolocation = Geolocation.fromJson(results[0]);

          setState(() {
            address = geolocation.formatted as String;
          });
        }
      }
    });

    final toMarkers = [];
    toMarkers.add(widget.activity.ToMarker());

    setState(() {
      markers = toMarkers;
    });
  }

  printActivity() {
    Tools.NormalPrint('Actividad:', getActivityText(), true);
  }

  shareActivity() {
    Share.share(getActivityText());
  }

  String getActivityText() {
    String activityText = '';
    activityText += widget.activity.title + '\n\n';
    activityText += widget.activity.message + '\n\n';
    activityText += widget.activity.date + '\n';
    return activityText;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close, color: Color(0xff243656))),
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
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                /*
                    color: Color(0xffF5F7FA),
                    blurRadius: 4,
                    offset: Offset(0.0, 3),
                    spreadRadius: 0
                    */
                                color: Color(0xff1546a0).withOpacity(0.1),
                                blurRadius: 48,
                                offset: Offset(2, 8),
                                spreadRadius: -16),
                          ],
                          color: Colors.white,
                        ),
                        child: ListTile(
                            contentPadding: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 6.18),
                            leading: CircleAvatar(
                              radius: 38,
                              backgroundColor: Color(0xffF5F7FA),
                              child: Icon(
                                widget.activity.icon,
                                size: 30,
                              ),
                            ),
                            title: Text(
                              widget.activity.title,
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              widget.activity.message + '\n' + widget.activity.date,
                              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        address,
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                      ),
                      if (markers.length > 0)
                        Container(
                            height: height - 320,
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                      Container(
                        margin: EdgeInsets.all(15),
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
                                  "Imprimir",
                                  style: TextStyle(color: Color(0xff929BAB)),
                                ),
                                icon: Icon(
                                  Icons.local_print_shop_outlined,
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
                                  printActivity();
                                },
                              ),
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                            )),
                            Expanded(
                                child: Container(
                              child: OutlinedButton.icon(
                                label: Text(
                                  "Enviar",
                                  style: TextStyle(color: Color(0xff929BAB)),
                                ),
                                icon: Icon(
                                  Icons.send_outlined,
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
                                  shareActivity();
                                },
                              ),
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ))),
        ]));
  }
}
