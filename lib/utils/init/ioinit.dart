import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'dart:io';
import 'package:ice_live_viewer/main.dart';

void init() {
  if (Platform.isWindows) {
    DartVLC.initialize(useFlutterNativeView: false);
    runApp(const MyApp());
  } else {
    runApp(const MyApp());
  }
}
