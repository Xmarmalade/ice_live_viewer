import 'package:flutter/material.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {}

  late final bool use_m3u8_for_bilibili = false;
  late final bool use_custome_resolution_for_huya = false;
}
