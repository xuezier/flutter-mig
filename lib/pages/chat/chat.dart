import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'package:myapp/models/user.dart';

import 'package:myapp/request/chat-request.dart';

import 'package:myapp/models/message.dart';
import 'package:myapp/flux/message.dart';

class ChatWidget extends StatefulWidget {
  User user;

  ChatWidget({Key key, @required this.user}) : super(key: key);

  @override
  createState() => new ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget>
    with StoreWatcherMixin<ChatWidget> {
  Request request;

  User user;
  String roomid = '18f4c2e336e243696fefa4d5faf1a76061ea5816';
  int last;

  List<Message> messages = [];

  MessageStore messageStore;

  @override
  void initState() {
    this.user = widget.user;
    this.request = new Request();
    this.messageStore = listenToStore(MessageStoreToken);

    this._loadLogs();
  }

  List<Message> _loadLogsFromStore() {
    return this.messageStore.getUserMessage(
          user: user.id,
          last: last,
        );
  }

  void _loadLogs() async {
    List<Message> logs = this._loadLogsFromStore();
    print(logs);
    if (logs == null || logs.length == 0) {
      Map<String, dynamic> data =
          await request.get('/api/message/$roomid', {'last': last});

      if (data != null) {
        int _last = data['last'];

        print(last);
        this.last = _last;
        data['user'] = user.id;
        setUserMessageAction(data).then((List list) {
          print(list);
          logs = _loadLogsFromStore();
          this._setMessages(logs);
        });
      }
    } else {
      this._setMessages(logs);
    }
  }

  void _setMessages(List<Message> logs) {
    setState(() {
      this.messages.addAll(logs);
    });
  }

  Widget _renderLogs() {
    if (this.messages.length == 0) {
      return Center(
        child: Text('No Messages'),
      );
    } else {
      return ListView.builder(
        itemCount: this.messages.length * 10,
        itemBuilder: (BuildContext context, int index) {
          Message msg = this.messages[index % messages.length];
          return Text(msg.content.toString());
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Scaffold(
              body: this._renderLogs(),
            ),
          ),
          Text('GGG')
        ],
      ),
    );
  }
}
