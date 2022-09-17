import 'package:flutter/material.dart';
import 'package:ice_live_viewer/utils/prefs_helper.dart';

class AppThemeProvider extends ChangeNotifier {
  AppThemeProvider() {
    changeThemeColor(PrefsHelper.getThemeColorPrefIndex());
    changeThemeMode(PrefsHelper.getThemeModePrefIndex());
  }

  static Map<String, ThemeMode> themeModes = {
    "System": ThemeMode.system,
    "Dark": ThemeMode.dark,
    "Light": ThemeMode.light,
  };

  late ThemeMode _themeMode;
  late String _themeModeName;
  get themeMode => _themeMode;
  get themeModeName => _themeModeName;
  void changeThemeMode(int index) {
    _themeMode = AppThemeProvider.themeModes.values.toList()[index];
    _themeModeName = AppThemeProvider.themeModes.keys.toList()[index];
    notifyListeners();
    PrefsHelper.setThemeModePrefIndex(index);
  }

  void showThemeModeSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Theme Mode'),
          children: _createThemeModeSelectorWidget(context),
        );
      },
    );
  }

  List<Widget> _createThemeModeSelectorWidget(BuildContext context) {
    List<Widget> widgets = [];
    for (var item in AppThemeProvider.themeModes.keys) {
      widgets.add(RadioListTile(
        activeColor: _themeColor,
        groupValue: item,
        value: _themeModeName,
        title: Text(item),
        onChanged: (value) {
          changeThemeMode(
              AppThemeProvider.themeModes.keys.toList().indexOf(item));
          Navigator.of(context).pop();
        },
      ));
    }
    return widgets;
  }

  static Map<String, Color> themeColors = {
    "Crimson": const Color.fromARGB(255, 220, 20, 60),
    "Orange": Colors.orange,
    "Chrome": const Color.fromARGB(255, 230, 184, 0),
    "Grass": Colors.lightGreen,
    "Teal": Colors.teal,
    "Sea Foam": const Color.fromARGB(255, 112, 193, 207),
    "Ice": const Color.fromARGB(255, 115, 155, 208),
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

  List<Widget> _createThemeColorSelectorWidget(BuildContext context) {
    List<Widget> themeSelectorWidgets = [];
    for (var item in AppThemeProvider.themeColors.keys) {
      themeSelectorWidgets.add(RadioListTile(
        activeColor: _themeColor,
        groupValue: item,
        value: _themeColorName,
        title: Text(item,
            style: TextStyle(color: AppThemeProvider.themeColors[item])),
        onChanged: (value) {
          changeThemeColor(
              AppThemeProvider.themeColors.keys.toList().indexOf(item));
          Navigator.of(context).pop();
          //Navigator.of(context).pop();
        },
      ));
    }
    return themeSelectorWidgets;
  }

  void showThemeColorSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Change Theme',
            style: TextStyle(
                color: AppThemeProvider.themeColors[_themeColorName],
                fontWeight: FontWeight.bold),
          ),
          children: _createThemeColorSelectorWidget(context),
        );
      },
    );
  }
}
