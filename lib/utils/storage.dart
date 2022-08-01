import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:convert';

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

///create a function to clear all the data
Future<bool> clearData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.clear();
}

/// 获取所有链接 返回Map{index: link}
///
/// 如果是首次使用则会初始化
Future<Map<String, String>> getAllLinks() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? linksList = prefs.getStringList('links');
  Map<String, String> linksMap = {};
  if (linksList == null) {
    initStorage();
  }
  for (int i = 1; i <= (linksList!.length); i++) {
    linksMap[i.toString()] = linksList[i - 1];
  }
  return linksMap;
}

/// This function accepts a link as a string and stores the specified link
Future<bool> saveSingleLink(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? linksList = prefs.getStringList('links');
  linksList!.add(key);
  return prefs.setStringList('links', linksList);
}

/// This function accepts a link as a string and deletes the specified link
Future<bool> deleteSingleLink(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? linksList = prefs.getStringList('links');
  linksList!.remove(key);
  return prefs.setStringList('links', linksList);
}

Future<bool> initStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? linksList = prefs.getStringList('links');
  if (linksList == null) {
    prefs.setStringList('links', []);
    prefs.setString('settings', '');
    return true;
  }
  return false;
}

/* //create a function to read all the key number
Future<int> getKeyNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getKeys().length;
} */

/* //create a function to save the data
Future<bool> saveData(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(key, value);
} */

/* //create a function to get the data
Future<String?> getData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
} */

/* ///create a function to delete the data
Future<bool> deleteData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(key);
} */
