import 'package:flutter/material.dart';
import 'package:ice_live_viewer/provider/themeprovider.dart';
import 'package:ice_live_viewer/utils/storage.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Settings'),
      ),
      body: Column(
        children: <Widget>[
          const SectionTitle(
            title: 'General',
          ),
          ListTile(
            title: const Text('Under Construction'),
            subtitle: const Text('This page is still not complete'),
            leading: const Icon(
              Icons.construction_rounded,
              size: 32,
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Change Theme'),
            subtitle: const Text('Change the theme of the app'),
            leading: const Icon(
              Icons.color_lens,
              size: 32,
            ),
            onTap: () {
              Provider.of<AppThemeProvider>(context, listen: false)
                  .showThemeSelectorDialog(context);
            },
          ),
          ListTile(
            title: const Text('Change Language'),
            subtitle: const Text('Change the language of the app'),
            leading: const Icon(
              Icons.translate,
              size: 32,
            ),
            onTap: () {},
          ),
          const SwitchTile(
            title: 'Use custom resolution for Huya',
            subtitle:
                'Use custom resolution for Huya, if you want to use a custom resolution for Huya, you should enable this option',
            settingKey: 'use_custom_resolution_for_huya',
          ),
          const SwitchTile(
            title: 'Use .m3u8 for Bilibili',
            subtitle:
                'Use .m3u8 format to play Bilibili live stream instead of the default .flv format, when you find that Bilibili live stream cannot be played, you can try this option.',
            settingKey: 'use_m3u8',
          ),
          const SectionTitle(
            title: 'Experimental',
          ),
          const SwitchTile(
            title: '[Only Windows|Not complete] Use Native Player',
            subtitle:
                'This setup only uses Win32 APIs & no texture, intermediate buffers or copying of pixel buffers.',
            settingKey: 'use_native_player',
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    Key? key,
  }) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.headline1),
    );
  }
}

class SwitchTile extends StatefulWidget {
  const SwitchTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.settingKey,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String settingKey;

  @override
  State<SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  bool? _toggled = false;

  @override
  void initState() {
    getSwitchPref(widget.settingKey).then((value) {
      _toggled = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        title: Text(widget.title),
        subtitle: Text(widget.subtitle),
        value: _toggled!,
        activeColor: Provider.of<AppThemeProvider>(context).themeColor,
        onChanged: (bool value) {
          switchPref(widget.settingKey);
          setState(() {
            _toggled = value;
          });
        });
  }
}
