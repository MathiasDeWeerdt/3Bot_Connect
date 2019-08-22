import 'dart:core';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/cryptoService.dart';

import '3botService.dart';

Future savePin(pin) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('pin');
  prefs.setString('pin', pin);
}

Future<String> getPin() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin');
}

Future savePublicKey(key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('publickey');
  prefs.setString('publickey', key);
}

Future<String> getPublicKey() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('publickey');
}

Future savePrivateKey(key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('privatekey');
  prefs.setString('privatekey', key);
}

Future<String> getPrivateKey() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('privatekey');
}

Future savePhrase(phrase) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('phrase');
  prefs.setString('phrase', phrase);
}

Future<String> getPhrase() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('phrase');
}

Future saveDoubleName(doubleName) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('doubleName');
  prefs.setString('doubleName', doubleName);
}

Future<String> getDoubleName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('doubleName');
}

Future saveEmail(String email, bool verified) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('email');
  prefs.setString('email', email);

  prefs.remove('emailVerified');
  prefs.setBool('emailVerified', verified);
}

Future saveEmailVerified(bool verified) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('emailVerified');
  prefs.setBool('emailVerified', verified);
}

Future<Map<String, Object>> getEmail() async {
  final prefs = await SharedPreferences.getInstance();

  return {
    'email': prefs.getString('email'),
    'verified': prefs.getBool('emailVerified')
  };
}

Future<Map<String, Object>> getKeys(String appId, String doubleName) async {
  print("##################### Getkeys #############################");
  return await generateDerivedKeypair(appId, doubleName);
}

Future saveFingerprint(fingerprint) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('fingerprint');
  prefs.setBool('fingerprint', fingerprint);
}

Future getFingerprint() async {
  final prefs = await SharedPreferences.getInstance();
  print(prefs);
  return prefs.getBool('fingerprint');
}

Future saveLoginToken(loginToken) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('loginToken');
  prefs.setString('loginToken', loginToken);
}

Future<String> getLoginToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('loginToken');
}

Future<void> clearData() async {
  final prefs = await SharedPreferences.getInstance();
  
  Response response = await removeDeviceId(prefs.getString('doubleName'));

  if(response.statusCode == 200) {
      print("Removing account");
      prefs.clear();
    } else {
      // Handle this error?
      print("Something went wrong while removing your account");
    }
}
