import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';

class SuccessfulScreen extends StatefulWidget {
  final Widget successfulscreen;

  SuccessfulScreen({Key key, this.successfulscreen}) : super(key: key);

  _SuccessfulScreenState createState() => _SuccessfulScreenState();
}

Future<bool> _onWillPop() {
  var index = 0;

  for (var flutterWebViewPlugin in flutterWebViewPlugins) {
    if (flutterWebViewPlugin != null) {
      if (index == lastAppUsed) {
        flutterWebViewPlugin.show();
        showButton = true;
      }
      index++;
    }
  }
  return Future.value(true);
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Logged in'),
          elevation: 0.0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Container(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0))),
              child: Container(
                padding: EdgeInsets.only(top: 24.0, bottom: 38.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle,
                        size: 42.0,
                        color: Theme.of(context).accentColor,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text('You are logged in, go back to the browser now.'),
                      SizedBox(
                        height: 60.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
