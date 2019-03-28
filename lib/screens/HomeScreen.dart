import 'package:flutter/material.dart';
import 'package:threebotlogin_app/main.dart';
import 'package:threebotlogin_app/screens/ScanScreen.dart';
import 'package:threebotlogin_app/services/connectionService.dart';
import 'package:threebotlogin_app/services/cryptoService.dart';
class HomeScreen extends StatelessWidget {
  final Widget homescreen;

  HomeScreen({Key key, this.homescreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('3Bot'),
        ),
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ScanScreen()));
              },
              child: Text("Go to scanscreen"),
            ),
            RaisedButton(
              onPressed: () {
                signHash("hoi");
                sendScannedFlag('hoi');
              },
              child: Text("ddd"),
            ),
            Text(config.apiUrl)
          ],
        )));
  }
}
