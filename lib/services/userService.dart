import 'package:shared_preferences/shared_preferences.dart';

Future savePin(pin) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('pin', pin);
}
Future<String> getPin () async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin');
}
Future savePrivateKey(key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('privatekey', key);
}
Future<String> getPrivateKey () async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('privatekey');
}