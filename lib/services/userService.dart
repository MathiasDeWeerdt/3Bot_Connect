import 'package:shared_preferences/shared_preferences.dart';

Future savePin(pin) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('pin');
  prefs.setString('pin', pin);
}
Future<String> getPin () async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin');
}
Future savePrivateKey(key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('privatekey');
  prefs.setString('privatekey', key);
}
Future<String> getPrivateKey () async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('privatekey');
}
Future saveDoubleName(doubleName) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('doubleName');
  prefs.setString('doubleName', doubleName);
}
Future<String> getDoubleName () async {
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

Future<Map<String, Object>> getEmail () async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'email': prefs.getString('email'),
    'verified': prefs.getBool('emailVerified')
  };
}

Future saveLoginToken(loginToken) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('loginToken');
  prefs.setString('loginToken', loginToken);
}
Future<String> getLoginToken () async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('loginToken');
}

void clearData() async{
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('pin');
  prefs.remove('privatekey');
  prefs.remove('email');
  prefs.remove('emailVerified');
  prefs.remove('doubleName');
}