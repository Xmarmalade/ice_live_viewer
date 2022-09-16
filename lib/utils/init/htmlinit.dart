import 'package:ice_live_viewer/main.dart';
import 'package:flutter/material.dart';
import 'package:ice_live_viewer/provider/themeprovider.dart';
import 'package:provider/provider.dart';

void init() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AppThemeProvider()),
  ], child: const MyApp()));
}
