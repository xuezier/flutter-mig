import 'package:flutter_flux/flutter_flux.dart';
import 'dart:async';

import 'package:myapp/models/user.dart';

class ContactsStore extends Store {
  List<User> _contacts = [];

  List<User> get contacts => this._contacts;

  ContactsStore() {
    triggerOnAction(setContactsListAction, (List list) {
      Completer completer = new Completer();
      List<User> _list = [];
      for (int index = 0; index < list.length; index++) {
        Map u = list[index];
        User user = new User(
          id: u['_id'],
          mobile: u['mobile'],
          name: u['showname'],
          avatar: u['avatar'],
          sex: u['sex'],
          birthdate: u['birthdate'],
        );
        _list.add(user);
      }
      this._contacts = _list;
      completer.complete(_list);
      return completer.future;
    });
  }
}

final StoreToken ContactsStoreToken = new StoreToken(ContactsStore());

final Action<List<dynamic>> setContactsListAction = new Action<List>();
