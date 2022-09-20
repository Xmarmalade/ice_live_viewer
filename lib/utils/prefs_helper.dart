import 'package:shared_preferences/shared_preferences.dart';

///This is the new util class for the shared preferences.
///
///And the old `storage.dart` will be deprecated.
class PrefsHelper {
  static late SharedPreferences prefs;

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

  static List<String> getLinksOfRooms() {
    List<String>? linksList = prefs.getStringList('links');
    print(linksList);
    return linksList ?? [];
  }

  static void setLinksOfRooms(List<String> links) {
    prefs.setStringList('links', links);
  }
}
