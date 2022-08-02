import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:ice_live_viewer/pages/home.dart';
import 'package:ice_live_viewer/utils/storage.dart';
import 'package:ice_live_viewer/utils/theme.dart';

void main() {
  initStorage();
  DartVLC.initialize(useFlutterNativeView: false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IceLiveViewer',
      theme: MyTheme().lightThemeData,
      darkTheme: MyTheme().darkThemeData,
      home: const Home(),
    );
  }
}
