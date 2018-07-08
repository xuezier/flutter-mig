import 'package:meta/meta.dart';

class AppConfig {
  AppConfig(
      {@required this.appName,
      @required this.flavorName,
      @required this.apiBaseUrl});

  final String appName;
  final String flavorName;
  final String apiBaseUrl;

  static final String scheme = 'http';
  static final String host = '192.168.0.110';
  static final int port = 3333;
  static final String url_root = 'http://192.168.0.110:3333';

  static final Map<String, dynamic> chat = {
    "schema": "http",
    "host": '192.168.0.110',
    "port": 9999,
    "url_root": "http://192.168.0.110:9999"
  };

  static final String push_url =
      'http://192.168.0.110:5555/api/push-notification';

  static final Map<String, dynamic> pomelo = {
    'scheme': 'ws',
    'host': '192.168.0.110',
    'port': 3014
  };
}
