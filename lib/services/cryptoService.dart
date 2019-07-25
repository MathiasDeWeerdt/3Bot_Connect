import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:password_hash/password_hash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/userService.dart';


Future<Map<String, String>> generateKeyPair () async {
  var keys = await Sodium.cryptoSignKeypair();
   return {
    'privateKey': base64.encode(keys['sk']),
    'publicKey': base64.encode(keys['pk'])
  };
}

Future<String> signData(String data, String sk) async {
  var private = base64.decode(sk);
  var signed =
      await Sodium.cryptoSign(Uint8List.fromList(data.codeUnits), private);

  return base64.encode(signed);
}

Future<Map<String, String>> encrypt(
    String data, String publicKey, String sk) async {
  var nonce = CryptoBox.generateNonce();
  var private = Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(sk));
  var public = base64.decode(publicKey);
  var message = Uint8List.fromList(data.codeUnits);
  var encryptedData =
      Sodium.cryptoBoxEasy(message, await nonce, public, await private);

  return {
    'nonce': base64.encode(await nonce),
    'ciphertext': base64.encode(await encryptedData)
  };
}

Future<Map<String, Object>> generateDerivedKeypair(
    String appId, String doubleName) async {
  final prefs = await SharedPreferences.getInstance();

  String derivedPublicKey = prefs.getString("${appId.toString()}.dpk");
  String derivedPrivateKey = prefs.getString("${appId.toString()}.dsk");

  String privateKey = await getPrivateKey();

  PBKDF2 generator = new PBKDF2();
  List<int> hashKey = generator.generateKey(privateKey, appId, 1000, 32);

  Map<String, Uint8List> key =
      await Sodium.cryptoBoxSeedKeypair(new Uint8List.fromList(hashKey));

  // derivedPublicKey = null;
  // derivedPrivateKey = null;

  if (derivedPublicKey == null || derivedPublicKey == "") {
    derivedPublicKey = base64.encode(key['pk']);
    prefs.setString("${appId.toString()}.dpk", derivedPublicKey);

    // String privateKey = await getPrivateKey();

    var data = {
      'doubleName': doubleName,
      'signedDerivedPublicKey': await signData(derivedPublicKey, privateKey),
      'signedAppId': await signData(appId, privateKey)
    };

    sendPublicKey(data);
  }

  if (derivedPrivateKey == null || derivedPrivateKey == "") {
    derivedPrivateKey = base64.encode(key['sk']);
    prefs.setString("${appId.toString()}.dsk", derivedPrivateKey);
  }

  return {
    'appId': appId,
    'derivedPublicKey': derivedPublicKey,
    'derivedPrivateKey': derivedPrivateKey
  };
}
