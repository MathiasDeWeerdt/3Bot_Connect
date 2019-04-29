import 'package:meta/meta.dart';

class Config {
  Config({
    @required this.threeBotApiUrl,
    @required this.openKycApiUrl
  });
  final String threeBotApiUrl;
  final String openKycApiUrl;
}