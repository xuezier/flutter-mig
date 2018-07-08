import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:myapp/flux/chat.dart';
import 'package:myapp/flux/user.dart';
import 'package:myapp/flux/contacts.dart';

import 'package:myapp/models/user.dart';
import 'package:myapp/models/message.dart';

import 'package:myapp/pages/chat/chat.dart';

class Messager extends StatefulWidget {
  @override
  createState() => new MessagerState();
}

class MessagerState extends State<Messager> with StoreWatcherMixin<Messager> {
  ChatStore chatStore;
  UserStore userStore;
  ContactsStore contactsStore;

  @override
  initState() {
    this.chatStore = listenToStore(ChatStoreToken);
    this.userStore = listenToStore(UserStoreToken);
    this.contactsStore = listenToStore(ContactsStoreToken);

    _init();
  }

  void _init() async {
    await initContactsInfoAction(
      {
        'me': userStore.me.id,
        'contacts': contactsStore.contacts,
      },
    );
  }

  ImageProvider _renderImage(String src) {
    if (src != null && src != "") {
      // return Image.network(
      //   src,
      // );
      return NetworkImage(src);
    } else {
      // return Image(
      //   image: AssetImage('sources/default_avatar.jpg'),
      // );
      return AssetImage('sources/default_avatar.jpg');
    }
  }

  Widget _renderAvatar(String avatar) {
    return Container(
      width: 50.0,
      height: 50.0,
      margin: EdgeInsets.only(right: 10.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Colors.blue,
        ),
        borderRadius: BorderRadius.all(
          new Radius.circular(25.0),
        ),
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: this._renderImage(avatar),
        ),
      ),
    );
  }

  Widget _renderMessage(Message msg) {
    String text;
    if (msg != null) {
      if (msg.type == 'text') {
        text = msg.content.toString();
      } else {
        text = '[${msg.type}]';
      }
    } else {
      text = 'never chat';
    }
    return Container(
      constraints: BoxConstraints(maxWidth: 250.0),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(text),
          ),
          Text(
            DateFormat('yyyy-MM-dd').format(
              DateTime.fromMillisecondsSinceEpoch(msg.timestamp),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateChat(Map room) {
    String roomid = room['roomid'];
    User user = room['user'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatWidget(
              roomid: roomid,
              user: user,
            ),
      ),
    );
  }

  Widget _renderContactItem(Map room) {
    Message msg = room['message'];
    User user = room['user'];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: BorderSide(
            color: Colors.black26,
            width: 0.5,
          ),
        ),
      ),
      child: GestureDetector(
        key: Key(user.id),
        onTap: () {
          this._navigateChat(room);
          // this._navigateCard(context, user);
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: <Widget>[
              this._renderAvatar(user.avatar),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 5.0,
                    ),
                    child: Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: user.sex == 'F' ? Colors.pink : Colors.blue,
                      ),
                    ),
                  ),
                  this._renderMessage(msg),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    List rooms = chatStore.rooms;

    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (BuildContext context, int index) {
        Map room = rooms[index];
        return this._renderContactItem(room);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: this._buildList(),
      ),
    );
  }
}
