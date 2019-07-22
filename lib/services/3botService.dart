import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:threebotlogin/main.dart';
import 'dart:convert';

import 'package:threebotlogin/screens/ErrorScreen.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/userService.dart';

String threeBotApiUrl = config.threeBotApiUrl;
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

sendScannedFlag(String hash, String deviceId) async {
  print('$threeBotApiUrl/flag');
  print(deviceId);
  http.post(
    '$threeBotApiUrl/flag',
    body: json.encode({'hash': hash, 'deviceId': deviceId, 'isSigned': true}),
    headers: requestHeaders,
  );
}

updateDeviceId(String deviceId, String doubleName) async {
  String privatekey = await getPrivateKey();
  String signedDeviceId = await signTimestamp(deviceId, privatekey);

  http.put('$threeBotApiUrl/users/$doubleName/deviceid',
      body: json.encode({'signedDeviceId': signedDeviceId}),
      headers: requestHeaders);
}

Future sendData(String hash, String signedHash, data, selectedImageId) {
  print(data);
  return http.post('$threeBotApiUrl/sign',
      body: json.encode({
        'hash': hash,
        'signedHash': signedHash,
        'data': data,
        'selectedImageId': selectedImageId
      }),
      headers: requestHeaders);
}

Future sendPublicKey(Map<String, Object> data) {
  logger
      .log('Sending appPublicKey to backend with appId: ' + json.encode(data));
  return http.post('$threeBotApiUrl/savederivedpublickey',
      body: json.encode(data), headers: requestHeaders);
}

Future checkLoginAttempts(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privatekey = await getPrivateKey();
  String signedTimestamp = await signTimestamp(timestamp, privatekey);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedTimestamp
  };

  return http.get('$threeBotApiUrl/attempts/$doubleName',
      headers: loginRequestHeaders);
}

Future<Response> removeDeviceId(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privatekey = await getPrivateKey();
  String signedTimestamp = await signTimestamp(timestamp, privatekey);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedTimestamp
  };
  return http.delete('$threeBotApiUrl/users/$doubleName/deviceid',
      headers: loginRequestHeaders);
}

Future<int> checkVersionNumber(BuildContext context, String version) async {
  var minVersion;

  try {
    minVersion =
        (await http.get('$threeBotApiUrl/minversion', headers: requestHeaders))
            .body;
  } on SocketException catch (error) {
    logger.log("Can't connect to server: " + error.toString());
  }

  if (minVersion == null) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ErrorScreen(errorMessage: "Can't connect to server.")));
    return -1;
  } else {
    try {
      var min = int.parse(minVersion);
      var current = int.parse(version);
      print((min <= current).toString());

      if (min <= current) {
        return 1;
      }
    } on Exception catch (e) {
      print(e);
      return 0;
    }
  }

  return 0;
}

Future cancelLogin(doubleName) {
  print("inside cancelLogin");

  print('$threeBotApiUrl/users/$doubleName/cancel');

  return http.post('$threeBotApiUrl/users/$doubleName/cancel',
      body:null, headers: requestHeaders);
}
