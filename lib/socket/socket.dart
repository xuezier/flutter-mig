import 'package:web_socket_channel/io.dart';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import './io.parser.dart';

class Socket {
  String nsp = '/';

  IOWebSocketChannel channel;

  int ids = 0;

  int _heartbeat_time_out = 20000;

  bool connected = false;

  bool disconnected = true;

  int EIO = Random().nextInt(1 << 10);

  int eventid = 0;
  Map<String, List<Map<String, dynamic>>> _events = {};

  Map<String, List<Map<String, dynamic>>> _once_events = {};

  Timer timer;

  Socket(String url) {
    if (url.indexOf(WS_PROTOCOL) == 0 || url.indexOf(WSS_PROTOCOL) == 0) {
      url += '/socket.io/?EIO=' + EIO.toString() + '&transport=websocket';
    }

    this.channel = IOWebSocketChannel.connect(url,
        pingInterval: Duration(milliseconds: 25000));

    channel.stream.listen((event) {
      this.parseListen(event);
    });

    this._did_heat_beat();
  }

  void diconnect([int closeCode, String closeReason]) {
    if (closeReason != null) {
      this.channel.sink.close(closeCode, closeReason);
    } else if (closeCode != null) {
      this.channel.sink.close(closeCode);
    } else {
      this.channel.sink.close();
    }
    this.emit('disconnect', closeReason);
  }

  void _did_heat_beat() {
    timer = new Timer(new Duration(milliseconds: _heartbeat_time_out), () {
      this.channel.sink.add(CONNECT);
      this._did_heat_beat();
    });
  }

  void _stop_heat_beat() {
    timer.cancel();
  }

  void emit(String name, [dynamic data]) {
    List<Map<String, dynamic>> eventContainer = this._events[name];
    List<Map<String, dynamic>> onceEventContainer = this._once_events[name];

    List<Map<String, dynamic>> list = new List();
    if (eventContainer != null) {
      list.addAll(eventContainer);
    }
    if (onceEventContainer != null) {
      list.addAll(onceEventContainer);
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

    this._off_once(name);
  }

  void _off_once(String name, [Function fun]) {
    if (fun == null) {
      this._once_events.remove(name);
      return;
    }

    List<Map<String, dynamic>> onceEventContainer = this._once_events[name];
    onceEventContainer.removeWhere((Map m) => m['event'] == fun);
  }

  void off(String name, [Function fun]) {
    if (fun == null) {
      this._events.remove(name);
      this._off_once(name);
      return;
    }

    List<Map<String, dynamic>> eventContainer = this._events[name];
    eventContainer.removeWhere((Map m) => m['event'] == fun);

    this._off_once(name, fun);
  }

  void once(String name, Function fun) {
    int id = eventid++;
    List<Map<String, dynamic>> eventContainer = this._once_events[name];

    if (eventContainer == null) {
      eventContainer = new List<Map<String, dynamic>>();
    }

    eventContainer.add({'id': id, 'event': fun});
    this._once_events[name] = eventContainer;
  }

  void on(String name, Function fun) {
    int id = eventid++;
    List<Map<String, dynamic>> eventContainer = this._events[name];

    if (eventContainer == null) {
      eventContainer = new List<Map<String, dynamic>>();
    }

    eventContainer.add({'id': id, 'event': fun});
    this._events[name] = eventContainer;
  }

  void parseListen(String event) {
    print(event);
    Match match = parser(event);
    List<String> events = match.group(1).split('');
    if (events.length == 1) {
      print(events);
      if (events[0] == CONNECT) {
        print('connected');
        this.emit('connect');
      } else if (events[0] == DISCONNECT) {
        this.emit('disconnect');
      }
    } else if (events.length == 2) {
      if (events[0] == '4') {
        String socket_event = events[1];
        if (socket_event == EVENT) {
          List<dynamic> data = JSON.decode(match.group(2));
          String _event = data[0];
          dynamic _data = data[1];
          if (_event == MESSAGE_EVENT) {
            this.processMessage(_data);
          }
        } else if (socket_event == ERROR) {
          List<dynamic> data = JSON.decode(match.group(2));
          this.emit('error', data);
        } else if (socket_event == DISCONNECT) {
          this.emit('disconnect');
        }
      }
    }
  }

  void processMessage(dynamic data) {
    print(data);
    this.emit("message", data);
  }

  void send(String data) {
    print(data);
    // data = '"' + data + '"';
    String sender = packetMessage(data);
    // sender = '42["message",12121212]';
    // sender = '42["message","gate.gateHandler.queryEntry{\\"token\\":\\"ddd\\",\\"timestamp\\":1530795742232}"]';
    print('sender:' + sender);
    this.channel.sink.add(sender);
  }
}
