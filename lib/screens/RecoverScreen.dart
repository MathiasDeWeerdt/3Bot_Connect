import 'dart:typed_data';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:crypto/crypto.dart';
import 'package:threebotlogin/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'RegistrationWithoutScanScreen.dart';

class RecoverScreen extends StatefulWidget {
  final Widget recoverScreen;
  RecoverScreen({Key key, this.recoverScreen}) : super(key: key);
  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final seedPhrasecontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;
  bool _isSameEmail = false;
  bool _isVerified = false;
  bool _emailCheck = false;

  String doubleName = '';
  String emailFromForm = '';
  String seedPhrase = '';

  String userError = '';
  String emailError = '';
  String seedPhraseError = '';

  bool _emailVerified = false;
  bool _isSigned = false;

  Map<String, Uint8List> key;
  Map emailData;

  Future<bool> isDoubleNameExisting(doubleName) async {
    requestHeaders['signature'] = 'application/json';

    http.Response response = await http.get(
        '${config.threeBotApiUrl}/users/$doubleName',
        headers: requestHeaders);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map> getEmailFromKyc(String doubleName) async {
    requestHeaders['signature'] = 'application/json';

    var getEmailInfo = http.get(
        '${config.openKycApiUrl}/users/$doubleName',
        headers: requestHeaders);

    var emailHash = await getEmailInfo;
    var body = jsonDecode(emailHash.body);

    return {'emailmd5': body['email'], 'verified': body['verified']};
  }

  Future<String> getPrivateKeyFromSeed(seedPhrase) async {
    return bip39.mnemonicToEntropy(seedPhrase);
  }

  Future<bool> isEmaiExisting(doubleName) async {
    requestHeaders['signature'] = 'application/json';

    http.Response response = await http.get(
        '${config.openKycApiUrl}/users/$doubleName',
        headers: requestHeaders);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  Uint8List toHex(String input) {
    double length = input.length / 2;
    Uint8List bytes = new Uint8List(length.ceil());

    for (var i = 0; i < bytes.length; i++) {
      var x = input.substring(i * 2, i * 2 + 2);
      bytes[i] = int.parse(x, radix: 16);
    }

    return bytes;
  }

  void openPincodeScreen() {
    openPage(RegistrationWithoutScanScreen(null, resetPin: true));
  }

  openPage(page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  checkDoubleNameExistence(doubleName) {
    isDoubleNameExisting(doubleName).then((value) {
      if (!value) {
        userError = 'Doublename does not exist';
      } else {
        userError = '';
      }
      setState(() {});
    });
  }

  checkEmailIsSame(doubleName, emailFromForm) {
    isEmaiExisting(doubleName).then((value) {
      if (!value) {
        emailError = 'Email does not exist';
      } else {
        getEmailFromKyc(doubleName).then((value) {
          String emailFormHashed = generateMd5(emailFromForm);
          String emailHashKyc = value['emailmd5'];
          int emailVerified = value['verified'];

          if (emailVerified == 1) {
            _emailVerified = true;
          } else {
            _emailVerified = false;
          }

          _isSameEmail = emailFormHashed == emailHashKyc;

          if (!_isSameEmail) {
            emailError = 'Email does not correspond with Doublename';
            _emailCheck = false;
          } else {
            emailError = '';
            _emailCheck = true;
            checkRecoverAccount();
          }
          setState(() {});
        });
      }
    });
  }

  checkSeedPhrase(seedPhrase) async {
    checkSeedLength(seedPhrase);

    if (seedPhraseError == null || seedPhraseError == '') {
      int timeStamp = new DateTime.now().millisecondsSinceEpoch;
      var sig;
      var valid;

      try {
        String entropy = await getPrivateKeyFromSeed(seedPhrase);
        key = await Sodium.cryptoSignSeedKeypair(toHex(entropy));
      } catch (e) {
        seedPhraseError = "Seed phrase is wrong";
      }

      if (seedPhraseError == null || seedPhraseError == '') {
        sig = await CryptoSign.sign(timeStamp.toString(), key['sk']);
        valid = await CryptoSign.verify(sig, timeStamp.toString(), key['pk']);

        if (valid) {
          _isSigned = true;

          if (_isSigned) {
            _isVerified = _emailVerified == true;
          } else {
          }
        } else {
          _isSigned = false;
          seedPhraseError = "Seed phrase is wrong";
        }
      }
    }
    setState(() {});
  }

  checkRecoverAccount() async {
    if (_isSigned && _isVerified && _emailCheck) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('privatekey', base64.encode(key['sk']).toString());
      prefs.setString('publickey', base64.encode(key['pk']).toString());
      prefs.setString('email', emailFromForm);
      prefs.setString('doubleName', doubleName);
      prefs.setString('phrase', seedPhrase);
      prefs.setBool('firstvalidation', false);
      prefs.setBool('emailVerified', _isVerified);

      String deviceId = await messaging.getToken();
      updateDeviceId(deviceId, doubleName);
      openPincodeScreen();
    }
  }

  checkSeedLength(seedPhrase) {
    int seedLength = seedPhrase.split(" ").length;
    if (seedLength <= 23) {
      seedPhraseError = 'Seed phrase is too short';
    } else if (seedLength == 24) {
      seedPhraseError = '';
    } else {
      seedPhraseError = 'Seed phrase is too long';
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter Valid Email';
    } else {
      return null;
    }
  }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    doubleNameController.dispose();
    emailController.dispose();
    seedPhrasecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recover Account')),
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
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: recoverForm()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget recoverForm() {
    return new Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Please insert your info',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 8.5),
                  child: TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Doublename',
                          suffixText: '.3bot',
                          suffixStyle: TextStyle(fontWeight: FontWeight.bold)),
                      controller: doubleNameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter your Doublename';
                        }
                        return null;
                      })),
              Padding(
                  padding: const EdgeInsets.only(top: 8.5),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Email'),
                    validator: validateEmail,
                    controller: emailController,
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 8.5),
                  child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Phrase'),
                      controller: seedPhrasecontroller,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter your Seedphrase';
                        }
                        return null;
                      })),
              SizedBox(
                height: 10,
              ),
              Text(
                userError,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Text(emailError,
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              Text(seedPhraseError,
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10)),
                padding: EdgeInsets.all(10),
                child: Text(
                  'Recover Account',
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _autoValidate = true;
                  doubleName = doubleNameController.text;
                  emailFromForm = emailController.text;
                  seedPhrase = seedPhrasecontroller.text;
                  doubleName += '.3bot';
                  checkDoubleNameExistence(doubleName);
                  checkEmailIsSame(doubleName, (emailFromForm.toLowerCase()));
                  checkSeedPhrase(seedPhrase);
                },
              ),
            ],
          ),
        ));
  }
}
