import 'package:myapp/models/user.dart';
import 'package:flutter_flux/flutter_flux.dart';

class UserStore extends Store {
  User _me;
  User get me => _me;

  UserStore() {
    triggerOnAction(setUserInfoAction, (Map user) {
      this._me = new User(name: user['name'], mobile: user['mobile']);
    });
  }
}

final StoreToken UserStoreToken = new StoreToken(UserStore());

final Action<Map> setUserInfoAction = new Action<Map>();
