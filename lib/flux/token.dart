import 'package:flutter_flux/flutter_flux.dart';

import 'package:myapp/models/token.dart';

class TokenStore extends Store {
  String _access_token;
  String _refresh_token;

  String get access_token => _access_token;
  String get refresh_token => _refresh_token;

  TokenStore() {
    triggerOnAction(setTokenAction, (Map<String, String> map) {
      this._access_token = map['access_token'];
      this._refresh_token = map['refresh_token'];
    });
  }
}

final StoreToken TokenStoreToken = new StoreToken(TokenStore());

final Action<Map<String, String>> setTokenAction = new Action<Map<String,String>>();