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
  String sourceid;
  int duration;
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
    this.sourceid = data['sourceid'];
    this.duration = data['duration'];
    this.__route__ = data['__route__'];

    Map<String, dynamic> getJson() {
      return {
        "_id": this._id,
        "content": this.content,
        "from": this.from,
        "target": this.target,
        "roomid": this.roomid,
        "route": this.route,
        "timestamp": this.timestamp,
        "type": this.type,
        "sourceid": this.sourceid,
        "duration": this.duration,
        "__route__": this.__route__,
      };
    }
  }
}
