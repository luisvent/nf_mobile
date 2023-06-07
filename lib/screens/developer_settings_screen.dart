import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nf_mobile/resources/constants.dart';

class DeveloperSettingsScreen extends StatefulWidget {
  const DeveloperSettingsScreen({Key? key}) : super(key: key);

  @override
  DeveloperSettingsScreenState createState() => DeveloperSettingsScreenState();
}

class DeveloperSettingsScreenState extends State<DeveloperSettingsScreen> {
  Widget appBarTitle = Text("Developer Settings", style: TextStyle(color: Color(0xff243656)));
  List<dynamic> servers = Constants.servers;
  String apiSelected = Constants.baseUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: Icon(Icons.arrow_back, color: Color(0xff243656))),
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
            child: AnimationLimiter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.api,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Servidor',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blueGrey),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(children: [
                        for (var server in servers)
                          RadioListTile<dynamic>(
                            title: Row(
                              children: [
                                Text(server['name']),
                                Text(
                                  server['api'],
                                  style: TextStyle(fontSize: 12, color: Colors.blueGrey[300]),
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                            value: server['api'],
                            groupValue: apiSelected,
                            onChanged: (dynamic value) {
                              setState(() {
                                apiSelected = value;
                                Constants.baseUrl = value;
                              });
                            },
                          )
                      ]
                          // [
                          //   Container(
                          //     padding: EdgeInsets.symmetric(horizontal: 10),
                          //     height: 40,
                          //     width: double.infinity,
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Icon(
                          //           Icons.cloud_queue,
                          //           color: Color(0xff929BAB),
                          //         ),
                          //         Text(backup['date'], style: TextStyle(color: Color(0xff929BAB)))
                          //       ],
                          //     ),
                          //     decoration: BoxDecoration(color: Colors.blueGrey[50]!.withOpacity(0.5)),
                          //   ),
                          //   Container(
                          //     height: 2,
                          //     decoration: BoxDecoration(color: Colors.white),
                          //   )
                          // ],
                          ),
                      SizedBox(
                        height: 10,
                      ),
                    ]),
              ),
            ),
          )),
        ]));
  }
}
