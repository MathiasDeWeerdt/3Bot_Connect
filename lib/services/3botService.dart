import 'package:http/http.dart' as http;
import 'package:threebotlogin/main.dart';
import 'dart:convert';

String threeBotApiUrl = config.threeBotApiUrl;
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

sendScannedFlag(String hash, String deviceId) async {
  print('$threeBotApiUrl/flag');
  http
      .post('$threeBotApiUrl/flag',
          body: json.encode({'hash': hash, 'deviceId': deviceId}),
          headers: requestHeaders)
      .catchError((onError) => print(onError));
}

Future sendData(String hash, String signedHash, data) {
  print('$threeBotApiUrl/sign');
  return http
      .post('$threeBotApiUrl/sign',
          body: json.encode({'hash': hash, 'signedHash': signedHash, 'data': data}),
          headers: requestHeaders)
      .catchError((onError) => print(onError));
}

Future checkLoginAttempts(String doubleName) {
  return http.get('$threeBotApiUrl/attempts/$doubleName', headers: requestHeaders);
}
