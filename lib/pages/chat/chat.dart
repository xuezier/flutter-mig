import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:myapp/models/user.dart';
import 'package:myapp/models/notification.dart';
import 'package:myapp/models/message.dart';

import 'package:myapp/request/chat-request.dart';
import 'package:myapp/request/push-notification.dart';

import 'package:myapp/flux/message.dart';
import 'package:myapp/flux/user.dart';

class ChatWidget extends StatefulWidget {
  User user;
  String roomid;

  ChatWidget({Key key, @required this.user, this.roomid}) : super(key: key);

  @override
  createState() => new ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget>
    with StoreWatcherMixin<ChatWidget> {
  Request request;

  User user;
  String roomid;
  int last;

  List<dynamic> deviceTokens = [];

  List<Message> messages = [];

  MessageStore messageStore;
  UserStore userStore;

  FocusNode _focusNode;
  ScrollController _scrollController;

  final _key = new GlobalKey<ScaffoldState>();
  bool _isloading = false;

  @override
  void initState() {
    this.user = widget.user;
    this.roomid = widget.roomid;
    this.request = new Request();

    this.messageStore = listenToStore(MessageStoreToken);
    this.userStore = listenToStore(UserStoreToken);

    this._loadLogs();
    this._loadDeviceTokens();

    this._focusNode = new FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        print(_focusNode.hashCode);
      }
    });

    this._scrollController = new ScrollController();
    _scrollController.addListener(() {
      // double offset = _scrollController.offset;
      // bool outOfRange = _scrollController.position.outOfRange;
      // if (offset > 0 && outOfRange == true) {
      //   // print(offset);
      //   this._loadLogs();
      // }
    });
  }

  @override
  void dispose() {
    this._focusNode.dispose();
    this._scrollController.dispose();

    super.dispose();
  }

  List<Message> _loadLogsFromStore() {
    return this.messageStore.getUserMessage(
          user: user.id,
          last: last,
        );
  }

  void _loadDeviceTokens() async {
    List<dynamic> tokens =
        await request.get('/api/badge/device-tokens/${user.id}');

    if (tokens != null) {
      this.deviceTokens = tokens;
      // print(this.deviceTokens);
      // print(tokens);
    }
  }

  void _loadLogs() async {
    if (this._isloading == true) {
      return;
    } else {
      this._isloading = true;

      List<Message> logs = this._loadLogsFromStore();
      // print(logs);
      if (logs == null || logs.length == 0) {
        Map<String, dynamic> data = await request.get('/api/message/$roomid',
            {'last': last == null ? '' : last.toString()});

        if (data != null) {
          int _last = data['last'];
          data['user'] = user.id;
          await setUserMessageAction(data);
          logs = _loadLogsFromStore();

          print(_last);
          if (_last != null && _last != '0' && _last != 0) {
            this.last = _last;
          }
          this._setMessages(logs);

          this._isloading = false;
        }
      } else {
        this._setMessages(logs);

        this._isloading = false;
      }
    }
  }

  void _setMessages(List<Message> logs) {
    setState(() {
      this.messages.addAll(logs);
    });
  }

  Notify _create_notify(Message msg) {
    return new Notify(
      notification: NotificationTemple(
        title: user.name,
        body: msg.content,
      ),
      data: NotificationData(id: 1),
    );
  }

  ImageProvider _renderImage(String src) {
    if (src != null && src != "") {
      return NetworkImage(src);
    } else {
      return AssetImage('sources/default_avatar.jpg');
    }
  }

  Widget _renderAvatar(String src, [bool left]) {
    return Container(
      width: 40.0,
      height: 40.0,
      margin: left == true || left == null
          ? EdgeInsets.only(right: 10.0)
          : EdgeInsets.only(left: 10.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Colors.blue,
        ),
        borderRadius: BorderRadius.all(
          new Radius.circular(20.0),
        ),
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: this._renderImage(src),
        ),
      ),
    );
  }

  Widget _renderLog(Message msg) {
    // if (msg.type != 'text') print(msg.sourceid);
    return Column(
      crossAxisAlignment: msg.from == user.id
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          msg.content.toString(),
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget _renderRightLog(Message msg) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Flex(
              crossAxisAlignment: CrossAxisAlignment.end,
              direction: Axis.vertical,
              children: <Widget>[
                GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(new ClipboardData(text: msg.content));
                    Fluttertoast.showToast(
                      msg: "Content Copied",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 5.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10.0,
                    ),
                    decoration: ShapeDecoration(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: 250.0,
                    ),
                    child: this._renderLog(msg),
                  ),
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(msg.timestamp),
                  ),
                ),
              ],
            ),
          ),
          this._renderAvatar(userStore.me.avatar, false),
        ],
      ),
    );
  }

  Widget _renderLeftLog(Message msg) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          this._renderAvatar(user.avatar),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Flex(
              crossAxisAlignment: CrossAxisAlignment.start,
              direction: Axis.vertical,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10.0,
                  ),
                  decoration: ShapeDecoration(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 250.0,
                  ),
                  child: this._renderLog(msg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderLogs() {
    if (this.messages.length == 0) {
      return Center(
        child: Text('No Messages'),
      );
    } else {
      return ListView.builder(
        reverse: true,
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 15.0,
        ),
        itemCount: this.messages.length,
        itemBuilder: (BuildContext context, int index) {
          Message msg = this.messages[index];
          return Container(
            child: msg.from == user.id
                ? this._renderLeftLog(msg)
                : this._renderRightLog(msg),
          );
        },
      );
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
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
            child: GestureDetector(
              key: Key(
                DateTime.now().millisecondsSinceEpoch.toString(),
              ),
              onTap: _dismissKeyboard,
              child: Scaffold(
                body: this._renderLogs(),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 0.5,
                  color: Colors.black26,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: 34.0,
              left: 10.0,
              right: 10.0,
            ),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: TextField(
                    onSubmitted: (String value) {
                      print(value);
                    },
                    focusNode: this._focusNode,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Text',
                    ),
                  ),
                ),
                IconButton(
                  color: Colors.blue,
                  onPressed: () {
                    print('press');
                    this._dismissKeyboard();
                  },
                  icon: Icon(
                    Icons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
