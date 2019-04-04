import 'package:flutter/material.dart';

class SuccessfulScreen extends StatefulWidget {
  final Widget successfulscreen;

  SuccessfulScreen({Key key, this.successfulscreen}) : super(key: key);

  _SuccessfulScreenState createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {
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
            Text('You are logged in, go back to PC'),
          ],
        )));
  }
}