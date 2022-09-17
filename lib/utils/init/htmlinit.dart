import 'package:ice_live_viewer/main.dart';
import 'package:flutter/material.dart';
import 'package:ice_live_viewer/provider/themeprovider.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void init() async {
  WidgetsFlutterBinding.ensureInitialized();
  PrefsHelper.prefs = await SharedPreferences.getInstance();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => AppThemeProvider(),
      lazy: false,
    ),
  ], child: const MyApp()));
}
