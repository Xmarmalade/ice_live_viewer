import 'package:shared_preferences/shared_preferences.dart';

///This is the new util class for the shared preferences.
///
///And the old `storage.dart` will be deprecated.
class PrefsHelper {
  static late SharedPreferences prefs;

  static bool getUseCustomResolutionPref() {
    return prefs.getBool('use_custom_resolution_for_huya') ?? false;
  }

  static void setUseCustomResolutionPref(bool value) {
    prefs.setBool('use_custom_resolution_for_huya', value);
  }

  static bool getUseM3U8ForBilibili() {
    return prefs.getBool('use_m3u8') ?? true;
  }

  static void setUseM3U8ForBilibili(bool value) {
    prefs.setBool('use_m3u8', value);
  }

  static int getThemeModePrefIndex() {
    return prefs.getInt("theme_mode") ?? 0;
  }

  static void setThemeModePrefIndex(int value) {
    prefs.setInt("theme_mode", value);
  }

  static int getThemeColorPrefIndex() {
    return prefs.getInt('theme_color') ?? 6;
  }

  static void setThemeColorPrefIndex(int pref) async {
    prefs.setInt('theme_color', pref);
  }

  static List<String> getLinksOfRoomsPrefList() {
    List<String>? linksList = prefs.getStringList('links');
    return linksList ?? [];
  }

  static void setLinksOfRoomsPrefList(List<String> links) {
    prefs.setStringList('links', links);
  }

  static dynamic getAnyPref(String key) {
    return prefs.get(key);
  }

  static void setAnyPref(String key, dynamic value) {
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    }
  }
}
