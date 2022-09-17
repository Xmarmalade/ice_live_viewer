import 'package:shared_preferences/shared_preferences.dart';

///This is the new util class for the shared preferences.
///
///And the old `storage.dart` will be deprecated.
class PrefsHelper {
  static late SharedPreferences prefs;

  static int getThemeModePrefIndex() {
    return prefs.getInt("themeMode") ?? 0;
  }

  static void setThemeModePrefIndex(int value) {
    prefs.setInt("themeMode", 0);
  }

  static int getThemeColorPrefIndex() {
    return prefs.getInt('theme_color') ?? 6;
  }

  static void setThemeColorPrefIndex(int pref) async {
    prefs.setInt('theme_color', pref);
  }
}
