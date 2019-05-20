import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppScreen extends StatefulWidget {
  final Map app;
  AppScreen(this.app, {Key key}) : super(key: key);

  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.app['name']),
          elevation: 0.0,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Container(
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    child: Container(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          child: WebView(
                            initialUrl: widget.app['url'],
                            javascriptMode: JavascriptMode.unrestricted,
                          ),
                        ))))));
  }
}
