import 'package:http/http.dart' as http;
import 'package:threebotlogin/main.dart';
import 'dart:convert';

String apiurl = config.apiUrl;
Map<String, String> requestHeaders = {
       'Content-type': 'application/json'
     };

sendScannedFlag(String hash, String deviceId) async {
  print('$apiurl/flag');
  http.post('$apiurl/flag', body: json.encode({
    'hash': hash,
    'deviceId': deviceId
  }), headers: requestHeaders).catchError((onError) => print(onError));
}

sendSignedHash( String hash, String signedHash) {
  http.post('$apiurl/sign', body: json.encode({
    'hash': hash,
    'signedHash': signedHash
  }), headers: requestHeaders).catchError((onError) => print(onError));
}