import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

import 'package:myapp/logon.dart';
import 'package:myapp/screen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
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
