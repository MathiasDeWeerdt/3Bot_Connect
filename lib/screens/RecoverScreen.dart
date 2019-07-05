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
import 'package:threebotlogin/widgets/CustomDialog.dart';

class RecoverScreen extends StatefulWidget {
  final Widget recoverScreen;
  RecoverScreen({Key key, this.recoverScreen}) : super(key: key);
  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  String openKycApiUrl = "https://openkyc.staging.jimber.org";
  String publicKeyUser = "https://login.staging.jimber.org";
  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  // TODO validation notices (username non existing, wrong keyphrase, wrong email)

  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final keyPhraseController = TextEditingController();
  String doubleName = "";
  String emailUser = "";
  String keyPhrase = "";
  String entropy;
  Color colorEmail = Color(0xff0f296a);
  bool newEmail = false;

  int timeStamp = new DateTime.now().millisecondsSinceEpoch;

  String userNotFound = '';

  void initState() {
    super.initState();

    // Testing purposes
    doubleNameController.text = "crypto";
    emailController.text = "mathiasdeweerdt@gmail.com";
    keyPhraseController.text =
        "sweet calm example fan attract quote swamp innocent light come eye mushroom emerge pluck future buyer exact initial again share helmet eagle habit chapter";
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
                    labelText: 'Doublename',
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
                                style: BorderStyle.solid)),
                        labelText: 'Email',
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
                      colorEmail = Color(0xffff0000);
                      setState(() {
                        colorEmail.toString();
                      });
                    },
                  ),
                ),
                Text(userNotFound),
              ]))),
    );
  }

  // create md5 hash from user email input
  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  //request for json data about emailHash
  Future<http.Response> checkPublicKey(String doubleName) {
    return http.get('$publicKeyUser/api/users/$doubleName' + '.3bot',
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
    doubleName = doubleNameController.text;
    emailUser = emailController.text;
    keyPhrase = keyPhraseController.text;

    logger.log("entering recoveringAccount");

    String publicKeyData = await getPublicKey(doubleName);

    Map emailData = await getMailFromKyc(doubleName);
    entropy = await getPrivatekey();

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
    logger.log("publicKeyData: " + publicKeyData);
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
      var done = showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
              image: Icons.error,
              title: "Email address is not the same!",
              description:
                  new Text("You'll need to verify the new email addres."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: new Text("Continue?"),
                  onPressed: () {
                    newEmail = true;
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: new Text("No"),
                  onPressed: () {
                    newEmail = false;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
      );
      await done;
    } else {
      bool isVerified = emailData['verified'] == 1;

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('privateKey', base64.encode(key['sk']).toString());
      prefs.setString('publicKey', base64.encode(key['pk']).toString());
      prefs.setString('email', emailUser);
      prefs.setString('doubleName', doubleName);
      prefs.setBool('firstvalidation', false);
      prefs.setBool('emailVerified', isVerified);
      Navigator.popAndPushNamed(context, '/profile');
    }

    if (newEmail) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('privateKey', base64.encode(key['sk']).toString());
      prefs.setString('publicKey', base64.encode(key['pk']).toString());
      prefs.setString('email', emailUser);
      prefs.setString('doubleName', doubleName);
      prefs.setBool('firstvalidation', true); //true if email not validated
      // send verify & say to user to verify
      /*  http.post('$openKycApiUrl/users/$doubleName/verify',
          body: json.encode({
            'userid': '$doubleName.3bot',
            'verification_code': ,
          }),
          headers: requestHeaders); */

      Navigator.popAndPushNamed(context, '/profile');
    } else {
      // email box red & focus

    }
  }

  Future<String> getPublicKey(String doubleName) async {
    try {
      if (doubleName != null || doubleName != '') {
        var publicKey = await checkPublicKey(doubleName);
        var body = jsonDecode(publicKey.body);

        return body['publicKey'];
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

        var getEmailInfo = http.get(
            '$openKycApiUrl/users/$doubleName' + '.3bot',
            headers: requestHeaders);

        var emailHash = await getEmailInfo;
        var body = jsonDecode(emailHash.body);

        return {'emailmd5': body['email'], 'verified': body['verified']};
      }

      return null;
    } catch (e) {
      logger.log(e);
      userNotFound = "Email not corresponding with Double name";
      return null;
    }
  }

  // Will get privateKey out of user key phrase
  Future<String> getPrivatekey() async {
    try {
      return bip39.mnemonicToEntropy(keyPhrase);
    } catch (e) {
      logger.log(e);
    }
    return null;
  }
}
