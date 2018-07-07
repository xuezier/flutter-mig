import 'package:meta/meta.dart';

class AppConfig   {
  AppConfig({
    @required this.appName,
    @required this.flavorName,
    @required this.apiBaseUrl
  });

  final String appName;
  final String flavorName;
  final String apiBaseUrl;

  static final String scheme = 'http';
  static final String host = '127.0.0.1';
  static final int port = 3333;
  static final String url_root = 'http://127.0.0.1:3333';
}