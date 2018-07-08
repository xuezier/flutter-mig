import 'package:flutter/material.dart';

class NotificationTemple {
  String body;
  String sound = 'default';
  String title;
  NotificationTemple({this.body, this.title});
}

class NotificationData {
  String click_action = 'FLUTTER_NOTIFICATION_CLICK';
  int id;
  String status = 'done';

  NotificationData({this.id});
}

class Notify {
  NotificationTemple notification;
  String priority = 'high';
  NotificationData data;

  Notify({@required this.notification, this.data});

  Map<String, dynamic> toJson() {
    return {
      "notification": {
        "sound": this.notification.sound,
        "body": this.notification.body,
        "title": this.notification.title,
      },
      "priority": this.priority,
      "data": {
        "click_action": this.data.click_action,
        "id": this.data.id,
        "status": this.data.status
      }
    };
  }
}
