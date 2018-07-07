import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'package:flutter_flux/flutter_flux.dart';

import 'package:myapp/app_config.dart';

import './storage.dart';

class Token {
  static String _access_token;

  static String _refresh_token;

  static get access_token => Token._access_token;

  static get refresh_token => Token._refresh_token;

  static setAccessToken(String access_token) async {
    Token._access_token = access_token;
    await storage('access_token', access_token);
  }

  static setRefreshToken(String refresh_token) async {
    Token._refresh_token = refresh_token;

    await storage('refresh_token', refresh_token);
  }

  static loadFromStorage() async {
    Token._access_token = await getStorage('access_token');

    Token._refresh_token = await getStorage('refresh_token');
  }
}

class ResponseData {
  int status;

  dynamic data;

  String message;
}

class Request {
  final httpClient = new Client();

  final String scheme = AppConfig.scheme;
  final String host = AppConfig.host;
  final int port = AppConfig.port;

  final String url_root = AppConfig.url_root;

  Request() {
    Token.loadFromStorage();
  }

  dynamic refresh_token() async {
    String url = url_root + '/oauth/token';

    String _refresh_token = Token.refresh_token;

    print(_refresh_token);
    if (_refresh_token == null) {
      return null;
    }

    Response response = await this.httpClient.post(url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body:
            'grant_type=refresh_token&client_id=com_tlifang_web&client_secret=Y%3DtREBruba%24%2BuXeZaya%3DeThaD3hukuwu&refresh_token=$_refresh_token');

    Map data = JSON.decode(response.body);

    if (response.statusCode != 200) {
      print(data);
      throw ('token failed');
    }

    if (data['code'] == 400) {
      print(data);
      throw ('refresh_token failed');
    }
    print(data);

    String access_token = data['access_token'];
    String refresh_token = data['refresh_token'];

    await Token.setAccessToken(access_token);
    await Token.setRefreshToken(refresh_token);
    return data;
  }

  dynamic token(String username, String password) async {
    String url = url_root + '/oauth/token';

    Response response = await this.httpClient.post(url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body:
            'grant_type=password&client_id=com_tlifang_web&client_secret=Y%3DtREBruba%24%2BuXeZaya%3DeThaD3hukuwu&username=$username&password=$password');
    if (response.statusCode != 200) {
      throw ('token failed');
    }

    Map data = JSON.decode(response.body);

    String access_token = data['access_token'];
    String refresh_token = data['refresh_token'];

    await Token.setAccessToken(access_token);
    await Token.setRefreshToken(refresh_token);

    return data;
  }

  dynamic get(String url, Map<String, dynamic> body) async {
    url = Uri(
            scheme: scheme,
            host: host,
            port: port,
            path: url,
            queryParameters: body)
        .toString();

    print(url);
    print("TOKEN:" + Token.access_token);

    Response response = await this.httpClient.get(url, headers: {
      "Authorization": "Bearer " + Token.access_token,
    });

    return this._resolveResponse(response);
  }

  dynamic _resolveResponse(Response response) {
    if (response.statusCode == 200) {
      Map data = JSON.decode(response.body);

      if (data['code'] == 200 || data['status'] == 200) {
        return data['data'];
      }
      throw (data['message']);
    }
  }

  dynamic post(String url, dynamic body) async {
    url = url_root + url;
    Response response = await this.httpClient.post(url,
        headers: {
          "Authorization": "Bearer " + Token.access_token,
          "Content-Type": "application/json"
        },
        body: body);

    return this._resolveResponse(response);
  }
}
