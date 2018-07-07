import 'package:flutter/material.dart';

class Message {
  String _id;
  dynamic content;
  String from;
  String target;
  String roomid;
  String route;
  int timestamp;
  String type;
  String __route__;

  Message(Map<String, dynamic> data) {
    this._id = data['_id'];
    this.content = data['content'];
    this.from = data['from'];
    this.target = data['target'];
    this.roomid = data['roomid'];
    this.route = data['route'];
    this.timestamp = data['timestamp'];
    this.type = data['type'];
    this.__route__ = data['__route__'];
  }
}
