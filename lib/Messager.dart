import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:myapp/pomelo/pomelo.dart';

class Messager extends StatefulWidget {
  @override
  createState() => new MessagerState();
}

class MessagerState extends State<Messager> {
  final PomeloClient client = new PomeloClient();

  String sid = '';

  @override
  initState() {
    client.init(host: '127.0.0.1', port: 3014, callback: () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        RaisedButton(
            child: Text('data'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
              client.request('gate.gateHandler.queryEntry', msg: {
                "token": "4052b2a514314cb8dfb2bcd3e2a9eb4a9032dc87",
                "uid": "5af2f2521a8c960351f3cce4",
              }, callback: (Map data) {
                print('data is here');
                print(data);
              });
              // Fluttertoast.showToast(
              //     msg: socket.toString(),
              //     toastLength: Toast.LENGTH_SHORT,
              //     gravity: ToastGravity.BOTTOM,
              //     timeInSecForIos: 1);
              // socket.send('42["message",{"name":121212}]');
            }),
      ],
    ));
  }
}
