import 'package:flutter/material.dart';
import 'package:ice_live_viewer/utils/http/checkupdate.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({
    this.version = '0.3.3',
    Key? key,
  }) : super(key: key);

  final String version;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: const Text('About'),
        leading: const Icon(Icons.info_outline_rounded),
        onTap: () {
          showAboutDialog(
              context: context,
              applicationName: 'IceLiveViewer',
              applicationVersion: version,
              applicationIcon: SizedBox(
                width: 60,
                child: Center(
                  child: Image.asset('assets/icon.png'),
                ),
              ),
              children: [
                ListTile(
                  title: const Text('Check for updates'),
                  leading: const Icon(
                    Icons.upload_rounded,
                    size: 32,
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => FutureBuilder(
                              future: judgeVersion(version),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List result =
                                      (snapshot.data as String).split('-');
                                  if (result[0] == '1') {
                                    return AlertDialog(
                                      title: const Text('Check for updates'),
                                      content: Text(
                                          'There is a new version: ${result[1]} available, do you want to update?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ElevatedButton(
                                          child: const Text('Update'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _launchUrl(
                                                'https://github.com/iiijam/ice_live_viewer/releases');
                                            //launch(snapshot.data);
                                          },
                                        ),
                                      ],
                                    );
                                  } else {
                                    return AlertDialog(
                                      title: const Text('Check for updates'),
                                      content: const Text(
                                          'You are using the latest version.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                } else if (snapshot.hasError) {
                                  return AlertDialog(
                                    title: const Text('Check for updates'),
                                    content: Text(
                                        'Failed to check for updates, please try again later.\n${snapshot.error}'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                } else {
                                  return const AlertDialog(
                                    title: Text('Loading'),
                                    content: LinearProgressIndicator(
                                      minHeight: 10,
                                    ),
                                  );
                                }
                              },
                            ));
                  },
                ),
                ListTile(
                  title: const Text('Github'),
                  leading: const Icon(
                    Icons.open_in_new_rounded,
                    size: 32,
                  ),
                  onTap: () {
                    _launchUrl('https://github.com/iiijam/ice_live_viewer/');
                  },
                ),
              ]);
        });
  }
}

Future<void> _launchUrl(_url) async {
  //print('launching $_url');
  if (!await launchUrl(Uri.parse(_url))) {
    throw 'Could not launch $_url';
  }
}
