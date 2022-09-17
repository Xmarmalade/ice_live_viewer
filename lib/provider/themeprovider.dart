import 'package:flutter/material.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';

class AppThemeProvider extends ChangeNotifier {
  AppThemeProvider() {
    changeThemeColor(PrefsHelper.getThemeColorPrefIndex());
  }

  static Map<String, ThemeMode> themeModes = {
    "system": ThemeMode.system,
    "on": ThemeMode.dark,
    "off": ThemeMode.light,
  };

  static Map<String, Color> themeColors = {
    "Crimson": const Color.fromARGB(255, 220, 20, 60),
    "Orange": Colors.orange,
    "Chrome": const Color.fromARGB(255, 230, 184, 0),
    "Grass": Colors.lightGreen,
    "Teal": Colors.teal,
    "Sea Foam": const Color.fromARGB(255, 112, 193, 207),
    "Blue": Colors.blue,
    "Indigo": Colors.indigo,
    "Violet": Colors.deepPurple,
    "Orchid": const Color.fromARGB(255, 218, 112, 214),
  };

  late Color _themeColor;
  late String _themeColorName;
  get themeColor => _themeColor;
  get themeColorName => _themeColorName;
  void changeThemeColor(int index) {
    _themeColor = AppThemeProvider.themeColors.values.toList()[index];
    _themeColorName = AppThemeProvider.themeColors.keys.toList()[index];
    notifyListeners();
    PrefsHelper.setThemeColorPrefIndex(index);
  }

  List<Widget> _createThemeSelectorWidget(BuildContext context) {
    List<Widget> themeSelectorWidgets = [];
    for (var item in AppThemeProvider.themeColors.keys) {
      themeSelectorWidgets.add(RadioListTile(
        groupValue: item,
        value: _themeColorName,
        title: Text(item,
            style: TextStyle(color: AppThemeProvider.themeColors[item])),
        onChanged: (value) {
          changeThemeColor(
              AppThemeProvider.themeColors.keys.toList().indexOf(item));
          //Navigator.of(context).pop();
        },
      ));
    }
    return themeSelectorWidgets;
  }

  void showThemeSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Change Theme',
            style:
                TextStyle(color: AppThemeProvider.themeColors[_themeColorName]),
          ),
          children: _createThemeSelectorWidget(context),
        );
      },
    );
  }
}
