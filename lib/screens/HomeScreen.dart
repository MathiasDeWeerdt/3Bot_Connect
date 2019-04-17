import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/firebaseService.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/main.dart';
import 'package:uni_links/uni_links.dart';
import 'RegistrationWithoutScanScreen.dart';

class HomeScreen extends StatefulWidget {
  final Widget homeScreen;

  HomeScreen({Key key, this.homeScreen}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool checkedIfLoginPending = false;
  String version = '0.0.0';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PackageInfo.fromPlatform().then((packageInfo) => {
          setState(() {
            version = packageInfo.version;
          })
        });
    initUniLinks();
    checkIfThereAreLoginAttents(context);
  }

  Future<Null> initUniLinks() async {
    getLinksStream().listen((String incomingLink) {
      Uri link = Uri.parse(incomingLink);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RegistrationWithoutScanScreen(link.queryParameters)));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.resumed) {
      initUniLinks();
      checkIfThereAreLoginAttents(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    initFirebaseMessagingListener(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('3Bot'),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: Center(
                          child: FutureBuilder(
                              initialData: loading(context),
                              future: getPrivateKey(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData)
                                  return alreadyRegistered(context);
                                else
                                  return notRegistered(context);
                              }),
                        )),
                        Text('v ' + version + (isInDebugMode ? '-DEBUG' : '')),
                      ],
                    )))));
  }

  Column loading(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircularProgressIndicator(),
        SizedBox(
          height: 20,
        ),
        Text('Checking if you are already registered....'),
      ],
    );
  }

  Column notRegistered(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('You are not registered yet.'),
        SizedBox(
          height: 20,
        ),
        RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10)),
          padding: EdgeInsets.all(12),
          child: Text(
            "Register now",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pushNamed(context, '/scan');
          },
        )
      ],
    );
  }

  Column alreadyRegistered(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.check_circle,
          size: 42,
          color: Theme.of(context).accentColor,
        ),
        SizedBox(
          height: 20,
        ),
        Text('You are already registered.'),
        Text('If you need to login you\'ll get a notification.'),
        SizedBox(
          height: 20,
        ),
        RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10)),
          padding: EdgeInsets.all(12),
          child: Text(
            "Register an other user",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).accentColor,
          onPressed: () {
            _showDialog();
          },
        )
      ],
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Are you sure?"),
          content: new Text(
              "If you continue, you won't be abel to login with the current account again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("Continue"),
              onPressed: () {
                clearData();
                Navigator.pushReplacementNamed(context, '/scan');
              },
            ),
          ],
        );
      },
    );
  }

  content(BuildContext context) {}
}
