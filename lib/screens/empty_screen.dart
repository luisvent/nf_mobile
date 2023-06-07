import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nf_mobile/providers/tab_navigation_provider.dart';
import 'package:provider/provider.dart';

class EmptyScreen extends StatefulWidget {
  final Function setTab;
  const EmptyScreen({Key? key, required this.setTab}) : super(key: key);

  @override
  EmptyScreenState createState() => EmptyScreenState();
}

class EmptyScreenState extends State<EmptyScreen> {
  late TextEditingController activitySearch;
  Widget appBarTitle = Text("Empty", style: TextStyle(color: Color(0xff243656)));
  Icon actionIcon = Icon(
    FluentIcons.search_24_regular,
    color: Color(0xff243656),
  );
  @override
  void initState() {
    super.initState();
    activitySearch = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffdfdfd),
        //  backgroundColor: Color(0xfffcfcfc),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                int lastTab = Provider.of<TabNavigationProvider>(context, listen: false).lastTab;
                Provider.of<TabNavigationProvider>(context, listen: false).removeLastTab();
                widget.setTab(lastTab);
              },
              icon: Icon(Icons.arrow_back, color: Color(0xff243656))),
          title: appBarTitle,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  if (actionIcon.icon == FluentIcons.search_24_regular) {
                    setState(() {
                      appBarTitle = Container(
                        height: 48,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(color: Color(0xffF5F7FA), borderRadius: BorderRadius.all(Radius.circular(16.18))),
                        child: TextField(
                          controller: activitySearch,
                          autofocus: true,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (value) {
                            setState(() {});
                          },
                          style: TextStyle(color: Color(0xff929BAB)),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(6.18),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xffF5F7FA), width: 1.618),
                                  borderRadius: BorderRadius.all(Radius.circular(16))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xffF5F7FA), width: 1.618),
                                  borderRadius: BorderRadius.all(Radius.circular(16))),
                              hintText: 'Buscar...',
                              hintStyle: TextStyle(
                                color: Color(0xff929BAB),
                              )),
                        ),
                      );

                      actionIcon = Icon(
                        Icons.close,
                        color: Color(0xff243656),
                      );
                    });
                  } else {
                    activitySearch.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      appBarTitle = Text("Préstamos", style: TextStyle(color: Color(0xff243656)));
                      actionIcon = Icon(
                        FluentIcons.search_24_regular,
                        color: Color(0xff243656),
                      );
                    });
                  }
                },
                icon: actionIcon),
          ],
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
            child: null,
          )),
        ]));
  }
}
