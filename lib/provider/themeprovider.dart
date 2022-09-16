import 'package:flutter/material.dart';

class AppThemeProvider extends ChangeNotifier {
  AppTheme() {
    changeThemeColor(0);
  }

  int _themeModeIndex = 0;
  int get themeModeIndex => _themeModeIndex;
  int _themeColorIndex = 4;
  int get themeColorIndex => _themeColorIndex;
  String _themeColorName = '';

  get themeColor => themeColors.values.toList()[_themeColorIndex];

  static Map<String, ThemeMode> themeModes = {
    "system": ThemeMode.system,
    "on": ThemeMode.dark,
    "off": ThemeMode.light,
  };

  static Map<String, Color> themeColors = {
    "indigo": Colors.indigo,
    "violet": Colors.deepPurple,
    "grass": Colors.lightGreen,
    "teal": Colors.teal,
    "seafoam": const Color.fromARGB(255, 112, 193, 207),
  };

  void setThemeModeIndex(int index) {
    _themeModeIndex = index;
    notifyListeners();
  }

  void setThemeColorIndex(int index) {
    _themeColorIndex = index;
    notifyListeners();
  }

  void changeThemeColor(int index) {
    _themeColorName = AppThemeProvider.themeColors.keys.toList()[index];
    notifyListeners();
  }

  List<Widget> _createThemeWidget(BuildContext context) {
    List<Widget> widgets = [];
    for (var item in AppThemeProvider.themeColors.keys) {
      widgets.add(RadioListTile(
        groupValue: item,
        value: _themeColorName,
        title: Text(item,
            style: TextStyle(color: AppThemeProvider.themeColors[item])),
        onChanged: (value) {
          setThemeColorIndex(
              AppThemeProvider.themeColors.keys.toList().indexOf(item));
          Navigator.of(context).pop();
        },
      ));
    }
    return widgets;
  }

  void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('切换主题'),
          children: _createThemeWidget(context),
        );
      },
    );
  }
}
