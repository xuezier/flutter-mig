import 'dart:typed_data';

String CONNECT = '0';
String DISCONNECT = '1';
String EVENT = '2';
String ACK = '3';
String ERROR = '4';
String BINARY_EVENT = '5';
String BINARY_ACK = '6';

String WSS_PROTOCOL = 'wss';

String WS_PROTOCOL = 'ws';

String HTTP_PROTOCOL = 'http';

String HTTPS_PROTOCOL = 'https';

String MESSAGE_EVENT = 'message';

RegExp listenDateReg = new RegExp("^(\\d+)(.+)");

Match parser(String data) {
  Iterable<Match> matches = listenDateReg.allMatches((data));

  return matches.first;
}

String packetMessage(String data) {
  return '4$EVENT["message","' + data + '"]';
}

String packet16String(List<int> list) {
  // print(list);
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
