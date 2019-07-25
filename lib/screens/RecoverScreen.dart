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
import 'package:password_hash/pbkdf2.dart';
import 'package:threebotlogin/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

import 'RegistrationWithoutScanScreen.dart';

class RecoverScreen extends StatefulWidget {
  final Widget recoverScreen;
  RecoverScreen({Key key, this.recoverScreen}) : super(key: key);
  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final seedPhraseController = TextEditingController();
  String doubleName = "";
  String emailUser = "";
  String seedPhrase = "";
  String entropy;
  Color colorEmail = Color(0xff0f296a);
  bool newEmail = false;

  int timeStamp = new DateTime.now().millisecondsSinceEpoch;

  String userNotFound = '';
  String emailNotFound = '';

  bool _validateUser = false;
  bool _validateEmail = false;
  bool _validateSeedPhrase = false;

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    doubleNameController.dispose();
    seedPhraseController.dispose();
    emailController.dispose();
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
                  child: Center(
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
                        TextField(
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Doublename',
                            errorText: _validateUser ? 'Doublename Can\'t Be Empty' : null,
                            suffixText: '.3bot',
                            suffixStyle: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          controller: doubleNameController,
                          onSubmitted: (value) {
                            doubleName = value;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.5),
                          child: new Theme(
                            data: new ThemeData(
                              primaryColor: Colors.blueAccent,
                              primaryColorDark: Colors.blue,
                            ),
                            child: TextField(
                              textInputAction: TextInputAction.send,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red[300],
                                      style: BorderStyle.solid),
                                ),
                                labelText: 'Email',
                                errorText: _validateEmail ? 'Email Can\'t Be Empty' : null,
                              ),
                              controller: emailController,
                              onSubmitted: (value) {
                                emailUser = value;
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.5),
                          child: TextField(
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Key',
                              errorText: _validateSeedPhrase ? 'Key Can\'t Be Empty' : null,
                            ),
                            controller: seedPhraseController,
                            onSubmitted: (value) {
                              seedPhrase = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 64.0),
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10)),
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "Recover Account",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              logger.log("Onpressed");
                              FocusScope.of(context).requestFocus(new FocusNode());
                              doubleNameController.text.isEmpty ? _validateUser = true : _validateUser = false;
                              emailController.text.isEmpty ? _validateEmail = true : _validateEmail = false;
                              seedPhraseController.text.isEmpty ? _validateSeedPhrase = true : _validateSeedPhrase = false;
                              await recoveringAccount();
                              colorEmail = Color(0xffff0000);
                              setState(() {
                                colorEmail.toString();
                              });
                            },
                          ),
                        ),
                        Text(userNotFound, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        Text(emailNotFound, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
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

  // create md5 hash from user email input
  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  //request for json data about emailHash
  Future<http.Response> checkpublickey(String doubleName) {
    return http.get('${config.threeBotApiUrl}/users/$doubleName',
        headers: requestHeaders);
  }

  Uint8List toHex(String input) {
    double length = input.length / 2;
    Uint8List bytes = new Uint8List(length.ceil());

    for (var i = 0; i < bytes.length; i++) {
      var x = input.substring(i * 2, i * 2 + 2);
      logger.log(x);

      bytes[i] = int.parse(x, radix: 16);
    }

    return bytes;
  }

  // Recovering account
  Future<void> recoveringAccount() async {
    doubleName = doubleNameController.text + ".3bot";
    emailUser = emailController.text;
    seedPhrase = seedPhraseController.text;

    logger.log("entering recoveringAccount");

    String publickeyData = await getpublickey(doubleName);

    Map emailData = await getMailFromKyc(doubleName);
    entropy = await getprivatekey();

    setState(() {
      
    });

    Map<String, Uint8List> key =
        await Sodium.cryptoSignSeedKeypair(toHex(entropy));

    logger.log("=============|Keypairs|===============");
    logger.log("publickey: " + base64.encode(key['pk']).toString());
    logger.log("secretkey: " + base64.encode(key['sk']).toString());
    logger.log("======================================");

    // hash email from user
    String mailmd5U = generateMd5(emailUser);

    var sig = await CryptoSign.sign(timeStamp.toString(), key['sk']);
    var valid = await CryptoSign.verify(sig, timeStamp.toString(), key['pk']);

    logger.log("=============|Recovery|============== ");
    logger.log("publickeyData: " + publickeyData);
    logger.log("emailGrabData: " +
        emailData['emailmd5'] +
        " " +
        emailData['verified'].toString());
    logger.log("email Hash: " + mailmd5U);
    logger.log("entropy: " + entropy);
    logger.log("key Valid: " + valid.toString());
    logger.log("seed phrase: " + bip39.entropyToMnemonic(entropy));
    logger.log("======================================");

    bool isSameEmail = mailmd5U == emailData['emailmd5'];

    if (!isSameEmail) {
      emailNotFound = "Email is not found";
    } else {
      emailNotFound = "";
      bool isVerified = emailData['verified'] == 1;

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('privatekey', base64.encode(key['sk']).toString());
      prefs.setString('publickey', base64.encode(key['pk']).toString());
      prefs.setString('email', emailUser);
      prefs.setString('doubleName', doubleName);
      prefs.setString('phrase', seedPhrase);
      prefs.setBool('firstvalidation', false);
      prefs.setBool('emailVerified', isVerified);

      String deviceId = await messaging.getToken();
      updateDeviceId(deviceId, doubleName);

      openPincodeScreen();
    }

    if (newEmail) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('privatekey', base64.encode(key['sk']).toString());
      prefs.setString('publickey', base64.encode(key['pk']).toString());
      prefs.setString('email', emailUser);
      prefs.setString('doubleName', doubleName);
      prefs.setBool('firstvalidation', true);
      Navigator.popAndPushNamed(context, '/preference');
    } else {}
  }

  void openPincodeScreen() {
    openPage(RegistrationWithoutScanScreen(null, resetPin: true));
  }

  openPage(page) {
    // Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<String> getpublickey(String doubleName) async {
    try {
      if (doubleName != null || doubleName != '') {
        var publickey = await checkpublickey(doubleName);
        var body = jsonDecode(publickey.body);

        if(publickey != null){
          userNotFound = "";
          return body['publicKey'];
        } else {
          return body = null;
        }
      }

      return null;
    } on FormatException catch (e) {
      logger.log(e);
      userNotFound = "User does not exist";
      return null;
    }
  }

  Future<Map> getMailFromKyc(String doubleName) async {
    try {
      if (doubleName != null || doubleName != '') {
        requestHeaders['signature'] = 'application/json';

        var getEmailInfo = http.get('${config.openKycApiUrl}/users/$doubleName',
            headers: requestHeaders);

        var emailHash = await getEmailInfo;
        var body = jsonDecode(emailHash.body);
        if(body != null){
        emailNotFound = "";
        return {'emailmd5': body['email'], 'verified': body['verified']};
        }
      
        emailNotFound = "Email does not exist";
        return null;
        
      }

      return null;
    } catch (e) {
      logger.log(e);
      emailNotFound = "Email not found";
      return null;
    }
  }

  // Will get privatekey out of user key phrase
  Future<String> getprivatekey() async {
    try {
      return bip39.mnemonicToEntropy(seedPhrase);
    } catch (e) {
      logger.log(e);
    }
    return null;
  }
}
