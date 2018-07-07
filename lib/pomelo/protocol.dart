import 'dart:convert';
import 'dart:typed_data';

int PROTOCOL_HEADER_LENTH = 5;

class Message {
  int id;
  String route;
  String body;
  Message({this.id, this.route, this.body});
}

String bt2Str({Uint16List byteArray, int start, int end}) {
  String result = '';
  for (int i = start; i < byteArray.length && i < end; i++) {
    result += String.fromCharCode(byteArray[i]);
  }

  // return result.substring(5);
  return result;
}

String packet16String(List<int> list) {
  print(list);
  String result = '';
  for (int i = 0; i < list.length; i++) {
    int byte = list[i];
    String node;
    if (byte < 16) {
      node = '0' + byte.toRadixString(16);
    } else {
      node = byte.toRadixString(16);
    }
    result += node;
  }
  return result;
}

class Protocol {
  String encoded({int id, String route, dynamic msg}) {
    String msgStr;
    if (msg is String) {
      msgStr = msg;
    } else {
      msgStr = JSON.encode(msg);
    }
    // msgStr = msgStr.replaceAll('"', '\\"');
    // msgStr ='"{\\"token\\":\\"ddd\\",\\"timestamp\\":1530790409420}"';
    if (route.length > 255) {
      throw 'route maxlength is overflow';
    }
    int byteLen = PROTOCOL_HEADER_LENTH + route.length + msgStr.length;
    Uint16List byteArray = new Uint16List(byteLen);

    int index = 0;
    byteArray[index++] = (id >> 24) & 0xFF;
    byteArray[index++] = (id >> 16) & 0xFF;
    byteArray[index++] = (id >> 8) & 0xFF;
    byteArray[index++] = id & 0xFF;
    byteArray[index++] = route.length & 0xFF;
    for (int i = 0; i < route.length; i++) {
      byteArray[index++] = route.codeUnitAt(i);
    }

    for (int i = 0; i < msgStr.length; i++) {
      byteArray[index++] = msgStr.codeUnitAt(i);
    }
    return bt2Str(
      byteArray: byteArray,
      start: 0,
      end: byteLen,
    );
  }

  Message decode(String msg) {
    int idx = 0;
    int len = msg.length;

    Uint16List arr = new Uint16List(len);

    for (idx = 0; idx < len; ++idx) {
      arr[idx] = msg.codeUnitAt(idx);
    }

    int index = 0;
    int id = ((arr[index++] << 24) |
            (arr[index++] << 16) |
            (arr[index++] << 8) |
            arr[index++]) >>
        0;

    int routeLen = arr[PROTOCOL_HEADER_LENTH - 1];
    String route = bt2Str(
      byteArray: arr,
      start: PROTOCOL_HEADER_LENTH,
      end: routeLen + PROTOCOL_HEADER_LENTH,
    );
    String body = bt2Str(
      byteArray: arr,
      start: routeLen + PROTOCOL_HEADER_LENTH,
      end: arr.length,
    );

    return new Message(id: id, route: route, body: body);
  }
}
