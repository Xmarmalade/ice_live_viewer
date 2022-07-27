import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: const Text('About'),
        leading: const Icon(Icons.info_outline_rounded),
        onTap: () {
          showAboutDialog(
              context: context,
              applicationName: 'IceLiveViewer',
              applicationVersion: 'beta v3',
              applicationIcon: const Icon(
                Icons.hexagon_rounded,
                size: 64.0,
              ),
              applicationLegalese: 'Copyright 2022',
              children: [
                const Text('IceLiveViewer is a simple app to view streams.'),
                const Text(
                    'Sometimes the inner VLC player can\'t play the stream, you can download vlc and use it to play the stream.'),
              ]);
        });
  }
}
