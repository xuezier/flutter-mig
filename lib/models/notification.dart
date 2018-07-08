import 'package:flutter/material.dart';

class NotificationTemple {
  String body;
  String title;
  NotificationTemple({this.body, this.title});
}

class NotificationData {
  String click_action = 'FLUTTER_NOTIFICATION_CLICK';
  int id;
  String status = 'done';

  NotificationData({this.click_action, this.id, this.status});
}

class Notify {
  NotificationTemple notification;
  String priority = 'high';
  NotificationData data;

  Notify({@required this.notification, this.priority, this.data});

  Map<String, dynamic> toJson() {
    return {
      "notification": {
        "body": this.notification.body,
        "title": this.notification.title,
      },
      "priority": this.priority,
      "dta": {
        "click_action": this.data.click_action,
        "id": this.data.id,
        "status": this.data.status
      }
    };
  }
}
