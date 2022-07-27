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
          ListTile(
            title:
                Text('Settings', style: Theme.of(context).textTheme.headline1),
          ),
          ListTile(
            title: const Text('Settings'),
            subtitle: const Text('Settings'),
            leading: const Icon(
              Icons.settings,
              size: 32,
            ),
            onTap: () {},
          ),
          SwitchListTile.adaptive(
              title: Text('data'),
              value: false,
              onChanged: (value) {
                value = true;
              }),
        ],
      ),
    );
  }
}
