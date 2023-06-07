import 'package:flutter/material.dart';

class AndroidSheetOptions extends StatelessWidget {
  List<dynamic> options;
  Function callback;
  AndroidSheetOptions(this.options, this.callback);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((i) => new ListTile(
                      title: Text(i['title']),
                      leading: Icon(i['icon']),
                      onTap: () {
                        Navigator.of(context).pop();
                        callback(i);
                      },
                    ))
                .toList()),
      ),
    );
  }
}
