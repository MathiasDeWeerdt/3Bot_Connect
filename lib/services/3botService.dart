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

sendSignedHash(String hash, String signedHash) {
  print('$threeBotApiUrl/sign');
  http
      .post('$threeBotApiUrl/sign',
          body: json.encode({'hash': hash, 'signedHash': signedHash}),
          headers: requestHeaders)
      .catchError((onError) => print(onError));
}

Future checkLoginAttempts(String deviceId) {
  print('$threeBotApiUrl/attemts/$deviceId');
  return http.get('$threeBotApiUrl/attemts/$deviceId', headers: requestHeaders);
}
