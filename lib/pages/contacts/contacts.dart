import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'dart:io';

import 'package:myapp/flux/user.dart';
import 'package:myapp/flux/contacts.dart';

import 'package:myapp/myIcon/icons.dart';

import 'package:myapp/models/user.dart';

import 'package:myapp/pages/contacts/user-card.dart';

import 'package:myapp/request/chat-request.dart';

class ContactsWidget extends StatefulWidget {
  @override
  createState() => new ContactsWidgetState();
}

class ContactsWidgetState extends State<ContactsWidget>
    with StoreWatcherMixin<ContactsWidget> {
  Request request;

  UserStore userStore;
  ContactsStore contactsStore;

  @override
  void initState() {
    this.request = new Request();

    this.userStore = listenToStore(UserStoreToken);
    this.contactsStore = listenToStore(ContactsStoreToken);

    this._loadContactList();
  }

  void _loadContactList() async {
    dynamic contacts = await this.request.get('/api/user/friends/info/any');
    if (contacts != null) {
      setContactsListAction(contacts);
    }
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

  void _navigateCard(BuildContext context, User u) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserCardWidget(
              user: u,
            ),
      ),
    );
  }

  Widget _renderContactItem(BuildContext context, User user) {
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
          this._navigateCard(context, user);
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: <Widget>[
              this._renderAvatar(user.avatar),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: user.sex == 'F' ? Colors.pink : Colors.blue,
                    ),
                  ),
                  user.sex == 'F'
                      ? Icon(
                          girlIcon,
                          size: 15.0,
                          color: Colors.pink,
                        )
                      : Icon(
                          boyIcon,
                          size: 15.0,
                          color: Colors.blue,
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderContactsList() {
    List<User> contacts = this.contactsStore.contacts;
    if (contacts.length == 0) {
      return Center(
        child: Text(
          'No Contacts',
          style: TextStyle(fontSize: 20.0),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: contacts.length,
        // itemExtent: 20.0,
        itemBuilder: (BuildContext context, int index) {
          return this._renderContactItem(context, contacts[index]);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _renderContactsList(),
    );
  }
}
