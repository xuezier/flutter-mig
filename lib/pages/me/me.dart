import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:myapp/request/request.dart';
import 'package:myapp/flux/user.dart';

import 'package:myapp/models/user.dart';

class MeWidget extends StatefulWidget {
  @override
  createState() => new MeWidgetState();
}

class MeWidgetState extends State<MeWidget> with StoreWatcherMixin<MeWidget> {
  UserStore userStore;

  @override
  void initState() {
    userStore = listenToStore(UserStoreToken);
  }

  Widget _buildText(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      margin: EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black38,
          decorationStyle: TextDecorationStyle.solid,
          fontSize: 18.0,
        ),
      ),
    );
  }

  void _logout() {}

  @override
  Widget build(BuildContext context) {
    User user = userStore.me;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Image.network(user.avatar),
          Container(
            margin: EdgeInsets.all(12.0),
            decoration: ShapeDecoration(
              color: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                side: BorderSide(color: Colors.blue[100]),
              ),
            ),
            padding: new EdgeInsets.all(10.0),
            child: Table(
              defaultColumnWidth: FlexColumnWidth(20.0),
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    _buildText('Name'),
                    _buildText(user.name),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildText('Mobile'),
                    _buildText(user.mobile),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildText('Sex'),
                    _buildText(user.sex == 'M' ? 'Male' : 'Female'),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildText('Birthday'),
                    _buildText(user.birthdate != null
                        ? user.birthdate
                        : 'Not fill date yet'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 25.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              onPressed: _logout,
              color: Colors.blue,
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
