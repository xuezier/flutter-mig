import 'package:shared_preferences/shared_preferences.dart';


dynamic storage(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString(key, value);

  return value;
}

dynamic storageInt(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setInt(key, value);

  return value;
}

dynamic getStorage(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String value = prefs.getString(key);

  return value;
}

dynamic getIntStorage(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  int value = prefs.getInt(key);

  return value;
}