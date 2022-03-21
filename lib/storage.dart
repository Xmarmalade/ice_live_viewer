import 'package:shared_preferences/shared_preferences.dart';

//create a function to save the data
Future<bool> saveData(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(key, value);
}

//create a function to get the data
Future<String?> getData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

//create a function to get all the data and store every value into a map
Future<Map<String, dynamic>> getAllData() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final prefsMap = <String, dynamic>{};
  for (String key in keys) {
    prefsMap[key] = prefs.get(key);
  }
  return prefsMap;
}

//create a function to delete the data
Future<bool> deleteData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(key);
}

//create a function to clear all the data
Future<bool> clearData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.clear();
}

//create a function to read all the key number
Future<int> getKeyNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getKeys().length;
}
