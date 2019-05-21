import 'package:http/http.dart' as http;
import 'package:threebotlogin/main.dart';
import 'cryptoService.dart';
import 'userService.dart';

String openKycApiUrl = config.openKycApiUrl;
Map<String, String> requestHeaders = {'Content-type': 'application/json'};
Future checkVerificationStatus(String doubleName) async {
  requestHeaders['signature'] = await signHash(doubleName, await getPrivateKey());
  return http.get('$openKycApiUrl/users/$doubleName', headers: requestHeaders);
}