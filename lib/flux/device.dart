import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:flutter_flux/flutter_flux.dart';

class DeviceStore extends Store {
  DeviceStore() {
    triggerOnAction(initDeviceInfoAction, ([any]) async {
      Completer completer = Completer();

      DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      print(iosInfo.utsname.machine);
      print(iosInfo.utsname.nodename);
      print(iosInfo.utsname.release);
      print(iosInfo.utsname.sysname);
      print(iosInfo.utsname.version);
      completer.complete(iosInfo.utsname.machine);
      return completer.future;
    });
  }
}

final StoreToken DeviceStoreToken = new StoreToken(DeviceStore());

final Action<Null> initDeviceInfoAction = new Action();
