import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'dart:io';
import 'package:ice_live_viewer/main.dart';
import 'package:ice_live_viewer/provider/themeprovider.dart';
import 'package:provider/provider.dart';

void init() {
  if (Platform.isWindows) {
    DartVLC.initialize(useFlutterNativeView: false);
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AppThemeProvider()),
    ], child: const MyApp()));
  } else {
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AppThemeProvider()),
    ], child: const MyApp()));
  }
}
