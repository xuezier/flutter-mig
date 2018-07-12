import 'package:flutter_flux/flutter_flux.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:myapp/app_config.dart';

import 'package:myapp/pomelo/pomelo.dart';
import 'package:myapp/request/request.dart';

// models
import 'package:myapp/models/message.dart';
import 'package:myapp/models/user.dart';

// stores
import 'package:myapp/flux/user.dart';

final String gateEntry = 'gate.gateHandler.queryEntry';
final String connectEntry = 'connector.entryHandler.enter';
final String accountInitInfo = 'account.accountHandler.initInfo';

class ChatStore extends Store {
  UserStore _userStore;
  UserStore get userStore => this._userStore;

  PomeloClient _client;
  PomeloClient get client => this._client;

  String _host;
  int _port;
  String _hostname;
  String _init_token;

  String _os = Platform.operatingSystem;
  String get os => this._os;

  String get host => this._host;
  int get port => this._port;
  String get hostname => this._hostname;
  String get init_token => this._init_token;

  int _channel_id;
  int get channel_id => this._channel_id;

  List<Map<String, dynamic>> rooms = [];

  ChatStore() {
    this._client = new PomeloClient();

    triggerOnAction(setUserStoreAction, (UserStore store) {
      this._userStore = store;
    });

// init connect server , get
    triggerOnAction(initConnectAction, ([any]) {
      Completer completer = new Completer();

      client.init(
        host: AppConfig.pomelo['host'],
        port: AppConfig.pomelo['port'],
        callback: () {
          client.request(
            gateEntry,
            msg: {
              "token": Token.access_token,
              "uid": userStore.me.id,
            },
            callback: (Map data) {
              // print('data is here');
              // print(data);
              if (data['code'] == 200) {
                client.disconnect();
                this._host = data['host'];
                this._port = data['port'];
                this._hostname = data['hostname'];
                this._init_token = data['init_token'];
              }
              completer.complete(data);
            },
          );
        },
      );
      return completer.future;
    });

    triggerOnAction(entryAction, ([any]) {
      Completer completer = new Completer();
      client.init(
        host: AppConfig.pomelo['host'],
        // host: this.host,
        port: this.port,
        callback: () {
          client.request(
            connectEntry,
            msg: {
              'init_token': this.init_token,
              'client': this.os,
            },
            callback: (Map data) {
              // print(this.os);
              // print(data);
              this._channel_id = data['channel_id'];
              completer.complete(data);
            },
          );
        },
      );
      return completer.future;
    });

    triggerOnAction(initContactsInfoAction, (Map map) {
      Completer completer = new Completer();
      client.request(accountInitInfo, callback: (Map data) {
        completer.complete(data);
        if (data['code'] == 200) {
          List list = data['data'];

          String me = map['me'];
          List<User> contacts = map['contacts'];

          List<Map<String, dynamic>> _rooms = [];
          for (int index = 0; index < list.length; index++) {
            Map item = list[index];
            Map room = item['room'];
            List members = room['members'];
            String target = members.firstWhere(
              (id) {
                return id != me;
              },
            );
            User contact = contacts.firstWhere((User c) {
              return c.id == target;
            });
            _rooms.add({
              "roomid": room['roomid'],
              "message": Message(item['message']),
              'last_active:': room['last_active:'],
              'target': target,
              'user': contact
            });
          }
          this.rooms = _rooms;
        }
      });
      return completer.future;
    });
  }
}

final StoreToken ChatStoreToken = new StoreToken(ChatStore());

final Action<UserStore> setUserStoreAction = new Action();

final Action<Null> initConnectAction = new Action();
final Action<Null> entryAction = new Action();
final Action<Null> disconnectAction = new Action();
final Action<Null> reconnectAction = new Action();

final Action<Map> initContactsInfoAction = new Action();

final Action<Message> sendMessageAction = new Action();
