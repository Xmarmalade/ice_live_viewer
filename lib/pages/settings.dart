import 'package:flutter/material.dart';

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
            title: const Text('Settings'),
            subtitle: const Text('This page is still not complete'),
            leading: const Icon(
              Icons.settings,
              size: 32,
            ),
            onTap: () {},
          ),
          SwitchListTile(
              title: const Text('A Switch List Tile'),
              value: false,
              onChanged: (value) {
                value = true;
              }),
          const SectionTitle(
            title: 'Experimental',
          ),
          SwitchListTile(
              title: const Text('Use Native Player'),
              subtitle: const Text(
                  'This setup only uses Win32 APIs & no texture, intermediate buffers or copying of pixel buffers.'),
              value: false,
              onChanged: (value) {
                value = true;
              }),
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
