import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/widgets/SingleApp.dart';

class AppSelector extends StatefulWidget {
  AppSelector({Key key}) : super(key: key);

  _AppSelectorState createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  var ken;
  List<Map<String, dynamic>> apps = [
    {
      "name": 'FreeFlowPages',
      "subheading": 'Where privacy and social media co-exist.',
      "url": 'https://freeflowpages.com/dashboard',
      "bg": 'ffp.jpg'
    },
    {
      "name": 'OpenMeetings',
      "subheading": 'Coming soon',
      "url": 'https://cowork-lochristi.threefold.work',
      "bg": 'om.jpg'
    },
    {
      "name": 'OpenBrowser',
      "subheading": 'By Jimber',
      "url": 'https://broker.jimber.org/',
      "bg": 'jimber.png'
    }
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Select your app"),
          Container(
            height: 0.7 * size.height,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: apps.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return SingleApp(
                    apps[index],
                  );
                }),
          ),
        ]);
  }
}
