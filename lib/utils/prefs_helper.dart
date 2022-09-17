import 'package:shared_preferences/shared_preferences.dart';

///This is the new class for the shared preferences.
///And the old storage.dart will be deprecated.
class PrefsHelper {
  static late SharedPreferences prefs;

  static int getThemeColorPrefIndex() {
    return prefs.getInt('theme_color') ?? 0;
  }

  static void setThemeColorPrefIndex(int pref) async {
    prefs.setInt('theme_color', pref);
  }
}
