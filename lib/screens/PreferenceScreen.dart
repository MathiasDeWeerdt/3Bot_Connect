import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/PinField.dart';

class PreferenceScreen extends StatefulWidget {
  PreferenceScreen({Key key}) : super(key: key);
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  Map email;
  String doubleName = '';
  String phrase = '';
  bool emailunVerified = false;
  bool showAdvancedOptions = false;
  Icon showAdvancedOptionsIcon = Icon(Icons.keyboard_arrow_down);
  String emailAdress = '';
  final _prefScaffold = GlobalKey<ScaffoldState>();

  bool _act = true;

  var thiscolor = Colors.green;

  @override
  void initState() {
    super.initState();
    getUserValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _prefScaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showAdvancedOptions = false;
            Navigator.pop(context);
          },
        ),
        title: Text('Preferences'),
        elevation: 0.0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Container(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.only(top: 24.0, bottom: 38.0),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            title: Text("Profile"),
                          ),
                          Material(
                            child: ListTile(
                              leading: Icon(Icons.person),
                              title: Text(doubleName),
                            ),
                          ),
                          Material(
                            child: ListTile(
                              trailing:
                                  emailunVerified ? Icon(Icons.refresh) : null,
                              leading: Icon(Icons.mail),
                              title: Text(emailAdress),
                              subtitle: emailunVerified
                                  ? Text(
                                      "Unverified",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  : Container(),
                              onTap: emailunVerified
                                  ? sendVerificationEmail
                                  : null,
                            ),
                          ),
                          Material(
                            child: ListTile(
                              trailing: Icon(Icons.visibility),
                              leading: Icon(Icons.vpn_key),
                              title: Text("Seed Phrase"),
                              onTap: _showPinDialog,
                            ),
                          ),
                          ExpansionTile(
                            title: Text("Advanced settings"),
                            children: <Widget>[
                              Material(
                                child: ListTile(
                                  leading: Icon(Icons.remove_circle),
                                  title: Text(
                                    "Remove Account From Device",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: _showDialog,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: "Are you sure?",
            description: new Text(
                "If you continue, you won't be able to login with the current account again (for now). However, this acccount still exists."),
            actions: <Widget>[
              FlatButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: new Text("Continue"),
                onPressed: () async {
                  await clearData();
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/'),
                  );
                  // setState(() {});
                },
              ),
            ],
          ),
    );
  }

  void sendVerificationEmail() async {
    _prefScaffold.currentState.showSnackBar(SnackBar(
      content: Text('Resending verification email...'),
    ));
    await resendVerificationEmail();
    _showResendEmailDialog();
  }

  void _showResendEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            image: Icons.check,
            title: "Email has been resend.",
            description: new Text("A new verification email has been send."),
            actions: <Widget>[
              FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            image: Icons.dialpad,
            title: "Please enter your pincode",
            description: Container(
              padding: EdgeInsets.only(bottom: 32.0),
              child: PinField(
                callback: checkPin,
              ),
            ),
          ),
    );
  }

  Future copySeedPhrase() async {
    Clipboard.setData(new ClipboardData(text: await getPhrase()));
    _prefScaffold.currentState.showSnackBar(SnackBar(
        content: Text('Seedphrase copied to clipboard'),
      ));
  }

  Future checkPin(pin) async {
    if (pin == await getPin()) {
      Navigator.pop(context);
      _showPhrase();
    } else {
      Navigator.pop(context);
      _prefScaffold.currentState.showSnackBar(SnackBar(
        content: Text('Pin invalid'),
      ));
    }
  }

  void _showPhrase() async {
    final phrase = await getPhrase();

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            hiddenaction: copySeedPhrase,
            image: Icons.create,
            title: "Please write this down on a piece of paper",
            description: new Text(
              phrase.toString(),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void getUserValues() {
    getDoubleName().then((dn) {
      setState(() {
        doubleName = dn;
      });
    });
    getEmail().then((emailMap) {
      setState(() {
        email = emailMap;
        if (email['email'] != null || email['verified']) {
          emailAdress = email['email'];
          emailunVerified = email['verified'];
        }
      });
    });
    getPhrase().then((seedPhrase) {
      setState(() {
        phrase = seedPhrase;
      });
    });
  }
}
