import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/main.dart';
import 'package:http/http.dart' as http;

import 'package:bip39/bip39.dart' as bip39;

import 'package:intl/intl.dart';
import 'dart:async';

import 'dart:convert';
import 'package:crypto/crypto.dart';

class RecoverScreen extends StatefulWidget {
  final Widget recoverScreen;
  RecoverScreen({Key key, this.recoverScreen}) : super(key: key);
  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  String openKycApiUrl = "https://openkyc.staging.jimber.org";
  String publicKeyUser = "https://login.staging.jimber.org";
  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final keyPhraseController = TextEditingController();
  String doubleName = "";
  String emailUser = "";
  String keyPhrase = "";
  String entropy;

  int timeStamp = new DateTime.now().millisecondsSinceEpoch;

  String userNotFound = '';

  bool sameEmail = false;

  String data;
  String emailGrabData;
  String publicKeyData;

  Timer timer;

  void initState() {
    super.initState();
    doubleNameController.text = "laika15";
    emailController.text = "anthony.debock@jimber.org";
    keyPhraseController.text =
        "mammal elephant opera mutual silk unit ensure better lottery donkey coach access swear require memory physical flip general smile glue tribe mesh tumble kangaroo";
    // recoveringAccount(doubleName);
  }

  @override
  void dispose() {
    doubleNameController.dispose();
    keyPhraseController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recover Account')),
      body: Center(
          child: Container(
              height: 400,
              width: 300,
              child: Column(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.5),
                    child: Text('Please insert your passphrase',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextField(
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'doublename',
                  ),
                  controller: doubleNameController,
                  onSubmitted: (value) {
                    doubleName = value;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.5),
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'email',
                    ),
                    controller: emailController,
                    onSubmitted: (value) {
                      emailUser = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.5),
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Key',
                    ),
                    controller: keyPhraseController,
                    onSubmitted: (value) {
                      keyPhrase = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.5),
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

                      await recoveringAccount();
                      setState(() {});
                    },
                  ),
                ),
                Text(entropy.toString() +
                    " " +
                    getDateTime()), // Debugging purposes
                Text(publicKeyData.toString() +
                    " " +
                    getDateTime()), // Debugging purposes
                Text(data.toString() +
                    " " +
                    getDateTime()), // Debugging purposes
                Text(emailGrabData.toString() +
                    " " +
                    getDateTime()), // Debugging purposes
                Text(userNotFound + " " + getDateTime())
              ]))),
    );
  }

  // create md5 hash from user email input
  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  //request for json data about emailHash
  Future<http.Response> checkEmailHash(String doubleName) {
    requestHeaders['signature'] = 'application/json';
    return http.get('$openKycApiUrl/users/$doubleName' + '.3bot',
        headers: requestHeaders);
  }

  //request for json data about emailHash
  Future<http.Response> checkPublicKey(String doubleName) {
    return http.get('$publicKeyUser/api/users/$doubleName' + '.3bot',
        headers: requestHeaders);
  }

  // Recovering account
  Future<int> recoveringAccount() async {
    doubleName = doubleNameController.text;
    emailUser = emailController.text;
    keyPhrase = keyPhraseController.text;

    logger.log("entering recoveringAccount");

    publicKeyData = await grabPublicKey(doubleName);

    emailGrabData = await grabEmail(doubleName);
    entropy = await getPrivatekey();

    // hash email from user
    data = generateMd5(emailUser);

    return 1;
  }

  Future<String> grabPublicKey(String doubleName) async {
    logger.log("entering grabpublickey");
    if (doubleName != null || doubleName != '') {
      var publicKey = await checkPublicKey(doubleName);
      logger.log(publicKey.body);
      var body = jsonDecode(publicKey.body);

      // grabs publicKey value and insert into publicKeyData
      return body['publicKey'];
    }

    return null;
  }

  Future<String> grabEmail(String doubleName) async {
    logger.log("entering grabemail");
    if (doubleName != null || doubleName != '') {
      var emailHash = await checkEmailHash(doubleName);
      logger.log(emailHash.body);
      var body = jsonDecode(emailHash.body);

      // grabs email hash value and insert into emailGrabData
      return body['email'];
    }

    return null;
  }

  // Will get privateKey out of user key phrase
  Future<String> getPrivatekey() async {
    try {
      if (emailGrabData != null) {
        userNotFound = "User has been found.";
        entropy = bip39.mnemonicToEntropy(keyPhrase);
        logger.log(entropy);

        return entropy;
      } else {
        userNotFound = "User not found.";
      }

      return null;
    } catch (e) {
      return null;
      // entropy = "Invalid mnenomic";
    }
  }

  String getDateTime() {
    var now = new DateTime.now();
    var formatter = new DateFormat('hh:mm:ss');
    String formatted = formatter.format(now);

    return formatted;
  }
}
