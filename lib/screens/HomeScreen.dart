import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/RegistrationScreen.dart';
import 'package:threebotlogin/services/userService.dart';

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
            Text('You are already registered.'),
            Text('If you need to login you\'ll get a notification'),
            SizedBox(height: 20,),
            RaisedButton(
              child: Text("Register an other user"),
              onPressed: () {
                _showDialog();
              },
            )
          ],
        )));
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Are you sure?"),
          content: new Text("If you continue, you won't be abel to login with the current account again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Continue"),
              onPressed: () {
                clearData();
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));
              },
            ),
          ],
        );
      },
    );
  }
}
