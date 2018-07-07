import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:myapp/flux/user.dart';

import 'package:myapp/request/request.dart';

import 'package:myapp/Messager.dart';

class MainWidget extends StatefulWidget {
  @override
  createState() => new MainWidgetState();
}

class MainWidgetState extends State<MainWidget>
    with SingleTickerProviderStateMixin, StoreWatcherMixin<MainWidget> {

  int navigateIndex;
  UserStore userStore;

  TabController _controller;

  Request request = new Request();

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this, initialIndex: 2);
    navigateIndex = 0;
    userStore = listenToStore(UserStoreToken);
  }

  void _popPress(int value) {
    print('press pop');
    print(value);
    print(userStore.me.name);
    print(userStore.me.mobile);
  }

  @override
  Widget build(BuildContext context) {
    // request.token('98935954', '123456');
    // request.get('url', {});
    return Scaffold(
      appBar: new AppBar(
        leading: IconButton(
            icon: Icon(
          Icons.search,
          color: Colors.white,
        )),
        centerTitle: true,
        actions: <Widget>[
          // IconButton(icon: Icon(Icons.more_vert, color: Colors.white)),
          PopupMenuButton<int>(
            onSelected: this._popPress,
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        disabledColor: Colors.blue,
                        color: Colors.blue,
                        icon: Icon(
                          Icons.account_circle,
                        ),
                      ),
                      Text('do you know who'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        disabledColor: Colors.blue,
                        color: Colors.blue,
                        icon: Icon(
                          Icons.cached,
                        ),
                      ),
                      Text('2'),
                    ],
                  ),
                ),
              ].toList();
            },
          ),
        ],
        title: new Text('Mig Chat'),
      ),
      body: new TabBarView(
        controller: _controller,
        children: <Widget>[
          new Messager(),
          Text('2'),
          Text('3'),
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: navigateIndex,
        fixedColor: Colors.blue,
        onTap: (int index) {
          // _controller.index = index;
          _controller.animateTo(index);
          setState(() {
            navigateIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: Icon(Icons.message), title: Text('message')),
          new BottomNavigationBarItem(
              icon: Icon(Icons.contacts), title: Text('contacts')),
          new BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text('me'))
        ],
      ),
    );
  }
}
