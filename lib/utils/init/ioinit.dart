import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'dart:io';
import 'package:ice_live_viewer/main.dart';
import 'package:ice_live_viewer/provider/themeprovider.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void init() async {
  if (Platform.isWindows) {
    DartVLC.initialize(useFlutterNativeView: false);
  }
  PrefsHelper.prefs = await SharedPreferences.getInstance();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => AppThemeProvider(),
      lazy: false,
    ),
  ], child: const MyApp()));
}
