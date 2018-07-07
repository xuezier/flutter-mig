import 'package:flutter_flux/flutter_flux.dart';

import 'package:myapp/models/message.dart';

class MessageStore extends Store {
  Map<String, List<Message>> _container = {};
  Map<String, List<Message>> get container => this._container;

  Map<String, int> _last_container = {};
  Map<String, int> get last_container => this._last_container;

  MessageStore() {
    triggerOnAction(setUserMessageAction, (Map<String, dynamic> data) {
      String user = data['user'];
      List<Message> _store = this.container[user];
      int _last = this.last_container[user];

      if (_store == null) {
        _store = [];
      }

      int start = _store.indexWhere((Message log) {
        return log.timestamp == _last;
      });

      if (start > -1) {
        return;
      }

      List<dynamic> logs = data['list'];
      List<Message> _logs = [];
      for (int index = 0; index < logs.length; index++) {
        Message msg = new Message(logs[index]);
        _logs.add(msg);
      }

      _store.addAll(_logs);
      this.container[user] = _store;
    });
  }

  List<Message> getUserMessage({String user, int last}) {
    List<Message> logs = this.container[user];
    if (logs == null) {
      return [];
    }

    if (last == null || last == 0) {
      if (logs.length < 20) {
        return logs;
      } else {
        return logs.sublist(0, 20);
      }
    } else {
      int start = logs.indexWhere((Message log) {
        return log.timestamp == last;
      });
      if (start == null || start == 0) {
        return [];
      } else {
        if (logs.length < start + 20) {
          return logs.sublist(start);
        } else {
          return logs.sublist(start, 20);
        }
      }
    }
  }
}

final StoreToken MessageStoreToken = new StoreToken(MessageStore());

final Action<Map<String, dynamic>> setUserMessageAction = new Action();
