import 'dart:convert';
import 'package:flutter_sodium/flutter_sodium.dart';

Future<String> signHash(String stateHash, String pk) async {
  var signedHash = await CryptoSign.sign(stateHash, base64.decode(pk));
  var base64EncryptedSignedHash = base64.encode(signedHash);

  return base64EncryptedSignedHash;
}
