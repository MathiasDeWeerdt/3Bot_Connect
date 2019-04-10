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
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Container(
                        padding: EdgeInsets.only(top: 24, bottom: 38),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('You are logged in, go back to PC')
                            ],
                          ),
                        ))))));
  }
}
