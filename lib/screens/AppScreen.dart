import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppScreen extends StatefulWidget {
  final Map app;
  AppScreen(this.app, {Key key}) : super(key: key);

  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  WebViewController controller;
  @override
  void dispose() {
    print("SAVE STATE");
    widget.app['callback'](widget.app);
    super.dispose();
  }

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.app['name']), elevation: 0.0),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Column(
              children: <Widget>[
                Container(
                    child: new RaisedButton(
                  child: const Text('Connect with Twitter'),
                  color: Theme.of(context).accentColor,
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  onPressed: () {
                    print("Lets hide the browser webview");
                    // isVisible = !isVisible;
                    setState(() {
                      isVisible = !isVisible;
                      print("Setting le state: " + isVisible.toString());
                    });
                  },
                )),
                Container(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: Visibility(
                    child: Container(
                        height: 650,
                        width: double.infinity,
                        child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            child: widget.app['webview'])),
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: isVisible,
                  ),
                ))
              ],
            )));
  }
}
