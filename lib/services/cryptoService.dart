import 'dart:convert';

import 'userService.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

Future<String> signHash(String stateHash) async {
  String pk = await getPrivateKey();
  var signedHash = await CryptoSign.sign(stateHash, base64.decode(pk));
  var base64EncryptedSignedHash = base64.encode(signedHash.toList());

  return base64EncryptedSignedHash;
}