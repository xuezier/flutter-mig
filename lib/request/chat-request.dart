import 'package:http/http.dart';
import 'dart:convert';

import 'package:myapp/request/request.dart';

import 'package:myapp/app_config.dart';

class Request {
  final httpClient = new Client();

  final String scheme = AppConfig.chat['schema'];
  final String host = AppConfig.chat['host'];
  final int port = AppConfig.chat['port'];

  final String url_root = AppConfig.chat['url_root'];

  final RegExp Url_Reg = new RegExp('^[http|https]');

  Request() {
    Token.loadFromStorage();
  }

  dynamic get(String url, [Map<String, dynamic> body]) async {
    url = Uri(
            scheme: scheme,
            host: host,
            port: port,
            path: url,
            queryParameters: body)
        .toString();

    // print(url);
    // print("TOKEN:" + Token.access_token);

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
    if (!Url_Reg.hasMatch(url)) {
      url = url_root + url;
    }
    Response response = await this.httpClient.post(url,
        headers: {
          "Authorization": "Bearer " + Token.access_token,
          "Content-Type": "application/json"
        },
        body: body);

    return this._resolveResponse(response);
  }
}
