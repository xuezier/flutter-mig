import 'package:meta/meta.dart';

// String initHost = '127.0.0.1';
String initHost = '192.168.100.42';

class AppConfig {
  AppConfig(
      {@required this.appName,
      @required this.flavorName,
      @required this.apiBaseUrl});

  final String appName;
  final String flavorName;
  final String apiBaseUrl;

  static final String scheme = 'http';
  static final String host = initHost;
  static final int port = 3333;
  static final String url_root = 'http://$initHost:3333';

  static final Map<String, dynamic> chat = {
    "schema": "http",
    "host": initHost,
    "port": 9999,
    "url_root": "http://$initHost:9999"
  };

  static final String push_url = 'http://$initHost:5555/api/push-notification';

  static final Map<String, dynamic> pomelo = {
    'scheme': 'ws',
    'host': initHost,
    'port': 3014
  };
}
