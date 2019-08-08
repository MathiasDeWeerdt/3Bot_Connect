import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:password_hash/password_hash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:bip39/bip39.dart' as bip39;


Future<Map<String, String>> generateKeyPair () async {
  // var keys = await Sodium.crypto_sign_seed_keypair();
  var keys = await Sodium.cryptoBoxKeypair();
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

// Future<String> dddddd(String ciphertext, String nonce, String publicKey, String sk) async {
//   var n = base64.decode(nonce);
//   var private = Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(sk));
//   var public = Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(publicKey));
//   var message = base64.decode(ciphertext);
//   try {
//     var decryptedData = await Sodium.cryptoBoxOpenEasy(message, n, await public, await private);
//     var ken = String.fromCharCodes(decryptedData);
//     return ken;
//   } catch (e) {
//     logger.log(e);
//   }

// }

Future<Map<String, String>> getFromSeedPhrase(String seedPhrase) async {
  String entropy = bip39.mnemonicToEntropy(seedPhrase);
  var keys = await Sodium.cryptoSignSeedKeypair(toHex(entropy));

  return {
    'privateKey': base64.encode(keys['sk']),
    'publicKey': base64.encode(keys['pk'])
  };
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

Future<Map<String, String>> encrypt(String data, String publicKey, String sk) async {
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
