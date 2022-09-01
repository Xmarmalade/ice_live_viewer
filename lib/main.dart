import 'package:flutter/material.dart';
import 'package:ice_live_viewer/pages/home.dart';
import 'package:ice_live_viewer/utils/theme.dart';
import 'package:ice_live_viewer/utils/init/ioinit.dart'
    if (dart.library.html) 'package:ice_live_viewer/utils/init/htmlinit.dart';

void main() {
  init();
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
