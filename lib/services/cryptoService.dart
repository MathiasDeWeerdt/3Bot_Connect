import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/userService.dart';

Future<String> signHash(String stateHash, String pk) async {
  logger.log('stateHash' + stateHash);
  var private = base64.decode(pk);
  var signedHash = await Sodium.cryptoSign(Uint8List.fromList(stateHash.codeUnits), private);
  var base64EncryptedSignedHash = base64.encode(signedHash);

  return base64EncryptedSignedHash;
}

Future<String> signTimestamp(String timestamp, String pk) async {
  logger.log('timestamp' + timestamp);
  var private = base64.decode(pk);
  var signedTimestamp = await Sodium.cryptoSign(Uint8List.fromList(timestamp.codeUnits), private);

  return base64.encode(signedTimestamp);
}

Future<String> sign(String other, String pk) async {
  var private = base64.decode(pk);
  var signed = await Sodium.cryptoSign(Uint8List.fromList(other.codeUnits), private);

  return base64.encode(signed);
}

Future<Map<String, String>> encrypt(String data, String publicKey, String pk) async {
  var nonce = CryptoBox.generateNonce();
  var private = Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(pk));
  var public = base64.decode(publicKey);
  var message = Uint8List.fromList(data.codeUnits);
  var encryptedData = Sodium.cryptoBoxEasy(message, await nonce, public, await private);

  return {
    'nonce': base64.encode(await nonce),
    'ciphertext': base64.encode(await encryptedData)
  };
}

Future<Map<String, Object>> generateKeypair(String appId, String doubleName) async {
  final prefs = await SharedPreferences.getInstance();

  String appPublicKey = prefs.getString("${appId.toString()}.pk");
  String appPrivateKey = prefs.getString("${appId.toString()}.sk");

  Map<String, Uint8List> key = await Sodium.cryptoBoxKeypair();

  appPublicKey = null;
  appPrivateKey = null;

  if(appPublicKey == null || appPublicKey == "") {
    appPublicKey = base64.encode(key['pk']);
    prefs.setString("${appId.toString()}.pk", appPublicKey);

    String privateKey = await getPrivateKey();

    var data = {
      'doubleName': doubleName,
      'signedAppPublicKey': await sign(appPublicKey, privateKey), 
      'signedAppId': await sign(appId, privateKey)
    };

    sendPublicKey(data);
  }

  if(appPrivateKey == null || appPrivateKey == "") {
    appPrivateKey = base64.encode(key['sk']);
    prefs.setString("${appId.toString()}.sk", appPrivateKey);
  }

  return {
    'appId': appId,
    'publicKey': appPublicKey,
    'privateKey': appPrivateKey
  };
}
