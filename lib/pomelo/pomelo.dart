import 'dart:convert';

import 'package:myapp/pomelo/protocol.dart';

import 'package:myapp/socket/socket.dart';

Protocol protocol = new Protocol();

class PomeloClient {
  Socket socket;
  Map<int, Function> callbacks = {};
  Map params;
  int id = 1;

  int _id = 1;
  Map<String, List<Map<String, dynamic>>> _events = {};

  String state = 'disconnect';

  init(
      {String protocol,
      String host,
      int port,
      String hostname,
      Function callback}) async {
    String url;

    if (protocol == null || protocol == '') {
      protocol = 'ws';
    }
    if (hostname != null && hostname != '') {
      url = hostname;
    } else {
      url = '$host:$port';
    }
    // print(url);
    if (url.indexOf(protocol) < 0) {
      url = '$protocol://$url';
    }

    this.socket = Socket(url);

    socket.on('connect', () {
      print('[pomeloclient.init] websocket connected!');
      if (callback != null) callback();
      this.state = 'connected';
    });

    socket.on('message', (dynamic data) {
      if (data is String) {
        data = JSON.decode(data);
      }
      if (data is List) {
        this.processMessageBatch(data);
      } else {
        this.processMessage(id: data['id'], body: data['body']);
      }
    });

    socket.on('error', (dynamic error) {
      this.emit('error', error);
    });

    socket.on('disconnect', ([String reason]) {
      if (reason != null) {
        print(reason);
      }
      this.emit('disconnect', reason);
    });
  }

  void disconnect() {
    this.state = 'disconnect';
    if (this.socket != null) {
      this.socket.diconnect();
    }
    this.socket = null;
  }

  void close() {
    return this.disconnect();
  }

  void request(String route, {Map msg, Function callback}) {
    msg = filter(msg, route);
    id++;
    callbacks[id] = callback;

    String body = protocol.encoded(id: id, route: route, msg: msg);
    body = packet16String(body.codeUnits);
    socket.send(body);
  }

  void notify(String route, {Map msg}) {
    this.request(route, msg: msg);
  }

  void processMessage({int id, Map body, String route}) {
    if (id != null) {
      Function fun = this.callbacks[id];
      this.callbacks.remove(id);

      if (fun is Function) {
        fun(body);
      } else {
        return;
      }
    }

    this.processCall(id: id, body: body, route: route);
  }

  processCall({int id, Map body, String route}) {
    if (route != null) {
      if (body != null) {
        dynamic data = body['body'];
        if (data == null) {
          data = body;
        }
        this.emit(route, data);
      } else {
        Map data = new Map();
        data['id'] = id;
        data['body'] = body;
        data['route'] = route;

        this.emit(route, data);
      }
    } else {
      this.emit(body['route'], body);
    }
  }

  processMessageBatch(List data) {}

  void emit(String name, [dynamic data]) {
    List<Map<String, dynamic>> eventContainer = this._events[name];

    List<Map<String, dynamic>> list = new List();
    if (eventContainer != null) {
      list.addAll(eventContainer);
    }

    if (list.length == 0) {
      return;
    }

    list.sort((map1, map2) {
      return map1['id'] - map2['id'];
    });
    list.forEach((Map<String, dynamic> map) {
      if (data != null) {
        map['event'](data);
      } else {
        map['event']();
      }
    });
  }

  void on(String name, Function fun) {
    int id = _id++;
    List<Map<String, dynamic>> eventContainer = this._events[name];

    if (eventContainer == null) {
      eventContainer = new List<Map<String, dynamic>>();
    }

    eventContainer.add({'id': id, 'event': fun});
    this._events[name] = eventContainer;
  }

  filter(Map msg, String route) {
    msg['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    return msg;
  }
}
