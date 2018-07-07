import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:myapp/logon.dart';
import 'package:myapp/screen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    print('init state');

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((String token) {
      print('get token');
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'welcome to my app',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      // initialRoute: '/logon',
      home: new LogonWidget(),
      routes: <String, WidgetBuilder>{
        '/logon': (BuildContext context) => new LogonWidget(),
        '/main': (BuildContext context) => new MainWidget(),
      },
    );
  }
}
