import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:myapp/request/request.dart';

import 'package:myapp/flux/user.dart';
import 'package:myapp/flux/chat.dart';
import 'package:myapp/flux/contacts.dart';
import 'package:myapp/flux/device.dart';

import 'package:myapp/request/chat-request.dart' as ChatRequest;

class LogonWidget extends StatefulWidget {
  @override
  createState() => new LogonWidgetState();
}

class LogonWidgetState extends State<LogonWidget>
    with StoreWatcherMixin<LogonWidget> {
  String username = '98935954';
  String password = '123456';

  UserStore userStore;
  ChatStore chatStore;
  ContactsStore contactsStore;
  DeviceStore deviceStore;

  Request request = new Request();
  ChatRequest.Request chatRequest = new ChatRequest.Request();

  @override
  void initState() {
    userStore = listenToStore(UserStoreToken);
    chatStore = listenToStore(ChatStoreToken);
    contactsStore = listenToStore(ContactsStoreToken);
    this.deviceStore = listenToStore(DeviceStoreToken);

    this._init_load();
    // _loadInfo();
  }

  void _init_load() async {
    await setUserStoreAction(userStore);

    await Token.loadFromStorage();
    await request.refresh_token();
    _loadInfo();
  }

  void _setUsername(value) {
    setState(() {
      username = value;
    });
  }

  void _setPassword(value) {
    setState(() {
      password = value;
    });
  }

  void _login() async {
    try {
      Map result = await request.token(username, password);

      _loadInfo();
    } catch (e) {
      print(e);
    }
  }

  void _loadInfo() async {
    try {
      Map result = await request.get('/api/user/info', {});
      dynamic contacts = await this.chatRequest.get('/api/user/friends/info/any');
      // print(result);
      if (result != null) {
        await setUserInfoAction(result);

        await initConnectAction();
        await entryAction();
        await setContactsListAction(contacts);
        await initDeviceInfoAction();

        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 250.0, left: 50.0, right: 50.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  border: InputBorder.none,
                  hintText: 'Username',
                  hintStyle: TextStyle(fontSize: 20.0)),
              onChanged: this._setUsername,
              maxLength: 25,
            ),
            TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                border: InputBorder.none,
                hintText: 'Password',
                hintStyle: TextStyle(fontSize: 20.0),
              ),
              maxLength: 25,
              obscureText: true,
              onChanged: this._setPassword,
            ),
            Container(
              margin: EdgeInsets.all(20.0),
              child: RaisedButton(
                padding: EdgeInsets.only(
                    left: 50.0, right: 50.0, top: 10.0, bottom: 10.0),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 25.0),
                ),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: this._login,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
