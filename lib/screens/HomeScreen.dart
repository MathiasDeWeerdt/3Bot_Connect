import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/RegistrationScreen.dart';

class HomeScreen extends StatefulWidget {
  final Widget homeScreen;

  HomeScreen({Key key, this.homeScreen}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            RaisedButton(child: Text("Try again"), onPressed: () { Navigator.pop(context,MaterialPageRoute(builder: (context) => RegistrationScreen())); },)
          ],
        )));
  }
}
