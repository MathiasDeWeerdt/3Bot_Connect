import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:threebotlogin/main.dart';
import 'userService.dart';

String openKycApiUrl = config.openKycApiUrl;
String threeBotApiUrl = config.threeBotApiUrl;
String threeBotFrontEndUrl = config.threeBotFrontEndUrl;
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future checkVerificationStatus(String doubleName) async {
  return http.get('$openKycApiUrl/users/$doubleName', headers: requestHeaders);
}

Future<http.Response> resendVerificationEmail() async {
  // TODO: @MathiasDeWeerdt public_key is now app_publicKey 
  return http.post('$openKycApiUrl/users',
      body: json.encode({
        'user_id': await getDoubleName(),
        'email': (await getEmail())['email'],
        'callback_url': threeBotFrontEndUrl + "verifyemail",
        'public_key': await getPublicKey(),
        'resend': 'true'
      }),
      headers: requestHeaders);
}
