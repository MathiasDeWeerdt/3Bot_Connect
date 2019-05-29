import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class CustomWebview extends StatefulWidget {
  CustomWebview({Key key}) : super(key: key);

  _CustomWebviewState createState() => _CustomWebviewState();
}

class _CustomWebviewState extends State<CustomWebview> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: "https://google.be/",
      withZoom: true,
      withLocalStorage: true,
      hidden: true
    );
  }
}
