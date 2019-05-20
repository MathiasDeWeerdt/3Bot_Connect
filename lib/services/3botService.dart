import 'package:http/http.dart' as http;
import 'package:threebotlogin/main.dart';
import 'dart:convert';

String threeBotApiUrl = config.threeBotApiUrl;
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

sendScannedFlag(String hash, String deviceId) async {
  http
      .post('$threeBotApiUrl/flag',
          body: json.encode({'hash': hash, 'deviceId': deviceId}),
          headers: requestHeaders)
      .catchError((onError) => print(onError));
}

Future sendData(String hash, String signedHash, data, selectedImageId) {
  return http
      .post('$threeBotApiUrl/sign',
          body: json.encode({'hash': hash, 'signedHash': signedHash, 'data': data, 'selectedImageId': selectedImageId}),
          headers: requestHeaders)
      .catchError((onError) => print(onError));
}

Future checkLoginAttempts(String doubleName) {
  return http.get('$threeBotApiUrl/attempts/$doubleName', headers: requestHeaders);
}

Future<bool> checkVersionNumber(String version) async {
  var minVersion = (await http.get('$threeBotApiUrl/minversion', headers: requestHeaders)).body;

  try {
    var min = int.parse(minVersion);
    var current = int.parse(version);
    print((min <= current).toString());
    return min <= current;

  } on Exception catch (e)  {
    print(e);
    return false;
  }
}
