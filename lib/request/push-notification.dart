import 'package:myapp/request/chat-request.dart';
import 'package:myapp/app_config.dart';
import 'dart:convert';

String url = AppConfig.push_url;

Request request = new Request();
void push(Map data) async {
  print(data);
  dynamic result = await request.post(url, JSON.encode(data));
  print(result);
}
