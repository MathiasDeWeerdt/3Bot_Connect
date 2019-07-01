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
import 'package:threebotlogin/services/cryptoService.dart';

class RecoverScreen extends StatefulWidget {
  final Widget recoverScreen;
  RecoverScreen({Key key, this.recoverScreen}) : super(key: key);
  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  String openKycApiUrl = "https://openkyc.staging.jimber.org";
  String publicKeyUser = "https://login.staging.jimber.org";
  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  // TODO Compare email HASHES.
  // TODO validation notices (username non existing, wrong keyphrase, wrong email)
  // TODO Validate users public key and private key
  // TODO Authenticate
  // TODO Save user's account with new device.
  // TODO Redirect user to appSelector

  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final keyPhraseController = TextEditingController();
  String doubleName = "";
  String emailUser = "";
  String keyPhrase = "";
  String entropy;

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
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
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
                Text(userNotFound),
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
  Future<int> recoveringAccount() async {
    doubleName = doubleNameController.text;
    emailUser = emailController.text;
    keyPhrase = keyPhraseController.text;

    logger.log("entering recoveringAccount");

    String publicKeyData = await grabPublicKey(doubleName);

    String emailGrabData = await grabEmail(doubleName);
    entropy = await getPrivatekey(emailGrabData);

    Map<String, Uint8List> key =
        await Sodium.cryptoSignSeedKeypair(toHex(entropy));

    logger.log("=============|Keypairs|===============");
    logger.log("publickey: " + base64.encode(key['pk']).toString());
    logger.log("secretkey: " + base64.encode(key['sk']).toString());
    logger.log("======================================");

    // hash email from user
    String data = generateMd5(emailUser);

    // var signedHash = signTimestamp(timeStamp.toString(), entropy);

    logger.log("=============|Recovery|============== ");
    logger.log("publicKeyData: " + publicKeyData);
    logger.log("emailGrabData: " + emailGrabData);
    logger.log("email Hash: " + data);
    logger.log("entropy: " + entropy);
    // logger.log("signedHash: " + signedHash.toString());
    logger.log("======================================");

    return 1;
  }

  Future<String> grabPublicKey(String doubleName) async {
    try {
      if (doubleName != null || doubleName != '') {
        var publicKey = await checkPublicKey(doubleName);
        var body = jsonDecode(publicKey.body);

        // grabs publicKey value and insert into publicKeyData
        return body['publicKey'];
      }

      return null;
    } on FormatException catch (e) {
      logger.log(e);
      userNotFound = "User does not exist";
      return userNotFound;
    }
  }

  Future<String> grabEmail(String doubleName) async {
    try {
      if (doubleName != null || doubleName != '') {
        var emailHash = await checkEmailHash(doubleName);
        var body = jsonDecode(emailHash.body);

        // grabs email hash value and insert into emailGrabData
        return body['email'];
      }

      return null;
    } catch (e) {
      logger.log(e);
      userNotFound = "Email not corresponding with Double name";
      return userNotFound;
    }
  }

  // Will get privateKey out of user key phrase
  Future<String> getPrivatekey(emailGrabData) async {
    try {
      if (emailGrabData != null) {
        userNotFound = "User has been found.";

        return bip39.mnemonicToEntropy(keyPhrase);
      } else {
        userNotFound = "User not found.";
      }
    } catch (e) {
      logger.log(e);
    }

    return null;
  }
}
