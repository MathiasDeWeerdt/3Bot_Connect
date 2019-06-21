import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/main.dart';

Future<String> signHash(String stateHash, String pk) async {
  logger.log('stateHash' + stateHash);
  var private = base64.decode(pk);
  var signedHash = await Sodium.cryptoSign(Uint8List.fromList(stateHash.codeUnits), private);
  var base64EncryptedSignedHash = base64.encode(signedHash);

  return base64EncryptedSignedHash;
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

Future<Map<String, String>> generateKeypair(String appId) async {
  Map<String, Uint8List> key = await Sodium.cryptoBoxKeypair();

  return {
    'appId': appId,
    'publicKey': base64.encode(key['pk']),
    'privateKey': base64.encode(key['sk']),
    'seed': ''
  };
}
