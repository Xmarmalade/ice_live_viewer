import 'package:flutter/material.dart';
import 'package:ice_live_viewer/pages/home.dart';
import 'package:ice_live_viewer/pages/newhome.dart';
import 'package:ice_live_viewer/utils/theme.dart';
import 'package:ice_live_viewer/provider/themeprovider.dart';
import 'package:ice_live_viewer/utils/init/ioinit.dart'
    if (dart.library.html) 'package:ice_live_viewer/utils/init/htmlinit.dart';
import 'package:provider/provider.dart';

void main() {
  init();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  final bool enableNewHome = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IceLiveViewer',
      themeMode: Provider.of<AppThemeProvider>(context).themeMode,
      theme: MyTheme(Provider.of<AppThemeProvider>(context).themeColor)
          .lightThemeData,
      darkTheme: MyTheme(Provider.of<AppThemeProvider>(context).themeColor)
          .darkThemeData,
      home: enableNewHome ? const NewHome() : const Home(),
    );
  }
}
