import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:myapp/models/user.dart';

import 'package:myapp/flux/chat.dart';

import 'package:myapp/pages/chat/chat.dart';

class UserCardWidget extends StatefulWidget {
  final User user;

  UserCardWidget({Key key, @required this.user}) : super(key: key);

  @override
  createState() => new UserCardWidgetState();
}

class UserCardWidgetState extends State<UserCardWidget>
    with StoreWatcherMixin<UserCardWidget> {
  User user;

  ChatStore chatStore;

  @override
  initState() {
    this.user = widget.user;

    this.chatStore = listenToStore(ChatStoreToken);
  }

  ImageProvider _renderAvatar(String avatar) {
    if (avatar != null && avatar != "") {
      return NetworkImage(avatar);
    } else {
      return AssetImage('sources/default_avatar.jpg');
    }
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

  void _goChat() {
    Map room = chatStore.rooms.firstWhere((Map r) {
      User u = r['user'];
      return u.id == user.id;
    });

    String roomid = room['roomid'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatWidget(
              user: user,
              roomid: roomid,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 150.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: this._renderAvatar(user.avatar),
                ),
              ),
            ),
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
                padding: EdgeInsets.symmetric(horizontal: 80.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                onPressed: _goChat,
                color: Colors.blue,
                child: Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
