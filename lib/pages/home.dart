import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_live_viewer/pages/play.dart';
import 'package:ice_live_viewer/pages/settings.dart';
import 'package:ice_live_viewer/widgets/about.dart';
import 'package:ice_live_viewer/utils/huyaparseer.dart' as huya;
import 'package:ice_live_viewer/utils/storage.dart' as storage;

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  //homepage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IceLiveViewer'),
      ),
      body: const HuyaListFutureBuilder(),
      drawer: const HomeDrawer(),
      floatingActionButton: const FloatingButton(),
    );
  }
}

class FloatingButton extends StatelessWidget {
  const FloatingButton({Key? key}) : super(key: key);
  //create floating button
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        //create a new dialog window to ask a number
        showDialog(
          context: context,
          builder: (BuildContext context) {
            var linkTextController = TextEditingController();
            return AlertDialog(
              title: const Text('Enter the link'),
              content: TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Link',
                  hintText: 'https://m.huya.com/243547',
                ),
                onChanged: (String value) {},
                //get the text and store it
                controller: linkTextController,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          storage.saveSingleLink(linkTextController.text);
                          return AlertDialog(
                            title: const Text('Success'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const Home();
                                    }));
                                  },
                                  child: const Text('Refresh'))
                            ],
                          );
                        });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({Key? key}) : super(key: key);
  //create the drawer
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Image.asset('assets/icon.png'),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 10)),
                Center(
                    child: Text('IceLiveViewer',
                        style: Theme.of(context).textTheme.headline1)),
              ],
            ),
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Refresh Data'),
            leading: const Icon(Icons.refresh),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Home();
              }));
            },
          ),
          ListTile(
            title: const Text('Clear Data'),
            leading: const Icon(Icons.delete),
            onTap: () {
              //ask user if he is sure to clear the data
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear Data'),
                    content: const Text(
                        'Are you sure to clear all the data?\nAll these data will disappear!'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          storage.clearData();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Success'),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const Home();
                                        }));
                                      },
                                      child: const Text('Refresh'))
                                ],
                              );
                            },
                          );
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const About()
        ],
      ),
    );
  }
}

class HuyaListFutureBuilder extends StatefulWidget {
  const HuyaListFutureBuilder({Key? key}) : super(key: key);
  @override
  _HuyaListFutureBuilderState createState() => _HuyaListFutureBuilderState();
}

class _HuyaListFutureBuilderState extends State<HuyaListFutureBuilder> {
  @override
  Widget build(BuildContext context) {
    //create a future builder to get the data from storage
    return FutureBuilder(
        future: storage.getAllLinks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              onRefresh: () async {
                //reload the page
                setState(() {});
              },
              child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      //enable the drag on mouse and touch devices
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                    },
                  ),
                  child: ListView.builder(
                    itemCount: (snapshot.data as Map<String, dynamic>).length,
                    itemBuilder: (context, index) {
                      //get the key and value pairs number
                      int indexNum = index + 1;
                      String listURL =
                          (snapshot.data as Map<String, dynamic>)['$indexNum']
                              .toString();
                      return FutureBuilder(
                          future: huya.getLiveList(listURL),
                          builder: (context, snapshot) {
                            //Determine if the data is loaded or not
                            if (snapshot.hasData) {
                              Object? snapshotData = snapshot.data;
                              //Determine whether the anchor is on or off
                              if ((snapshotData as List<dynamic>)[0] == 0) {
                                //NO
                                return OfflineListTile(
                                    anchor: (snapshotData)[1],
                                    rawLink: listURL);
                              } else {
                                //YES
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage((snapshotData)[2]),
                                  ),
                                  title: Text((snapshotData)[3]),
                                  subtitle: Text((snapshotData)[1]),
                                  trailing:
                                      const Icon(Icons.chevron_right_sharp),
                                  onTap: () {
                                    showChosenDialog(
                                        context, snapshotData, listURL);
                                  },
                                );
                              }
                            } else if (snapshot.hasError) {
                              return ErrorListTile(
                                  error: snapshot.error, rawLink: listURL);
                            }
                            return const ListTile(
                              title: Text('Loading...'),
                              subtitle: LinearProgressIndicator(),
                            );
                          });
                    },
                  )),
            );
          } else if (snapshot.hasError) {
            return ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text('${snapshot.error}'),
            );
          }
          return const CircularProgressIndicator();
        });
  }

  Future<dynamic> showChosenDialog(
      BuildContext context, List<dynamic> snapshotData, String rawLink) {
    return showDialog(
        context: context,
        builder: (context) {
          String roomName = (snapshotData)[3];
          int roomCdnLength = (snapshotData)[6];
          List<Widget> cdnListTiles = [];
          for (var i = 1; i <= roomCdnLength; i++) {
            cdnListTiles.add(ListTile(
              leading: Text((snapshotData)[i * 2 + 5]),
              subtitle: Text(
                (snapshotData)[i * 2 + 6],
                maxLines: 2,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.copy),
                    onSelected: (context) {
                      Clipboard.setData(ClipboardData(text: context));
                      //show a scaffold to show the copy success
                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(const SnackBar(
                              content: Text(
                        'Copied to clipboard',
                      )));
                    },
                    itemBuilder: (context) {
                      String rawLink = (snapshotData)[i * 2 + 6];
                      String hdLink =
                          rawLink.replaceAll('imgplus.flv', 'imgplus_4000.flv');
                      String sdLink =
                          rawLink.replaceAll('imgplus.flv', 'imgplus_2000.flv');
                      String saveDataLink =
                          rawLink.replaceAll('imgplus.flv', 'imgplus_1500.flv');
                      return <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: hdLink,
                          child: const Text('1080P'),
                        ),
                        PopupMenuItem(
                          value: sdLink,
                          child: const Text('720P'),
                        ),
                        PopupMenuItem(
                          value: saveDataLink,
                          child: const Text('540P'),
                        ),
                      ];
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.play_arrow),
                    onSelected: (context) {
                      int lUid = (snapshotData)[5];
                      String roomSelectedUrl = context;
                      Navigator.push(
                          this.context,
                          MaterialPageRoute(
                              builder: (context) => StreamPlayer(
                                    title: roomName,
                                    url: roomSelectedUrl,
                                    danmakuId: lUid,
                                  )));
                    },
                    itemBuilder: (context) {
                      String rawLink = (snapshotData)[i * 2 + 6];
                      String hdLink =
                          rawLink.replaceAll('imgplus.flv', 'imgplus_4000.flv');
                      String sdLink =
                          rawLink.replaceAll('imgplus.flv', 'imgplus_2000.flv');
                      String saveDataLink =
                          rawLink.replaceAll('imgplus.flv', 'imgplus_1500.flv');
                      return <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: hdLink,
                          child: const Text('1080P'),
                        ),
                        PopupMenuItem(
                          value: sdLink,
                          child: const Text('720P'),
                        ),
                        PopupMenuItem(
                          value: saveDataLink,
                          child: const Text('540P'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ));
          }
          return AlertDialog(
            scrollable: true,
            title: Text((snapshotData)[3]),
            content: SizedBox(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  //show network image of cover
                  Image.network((snapshotData)[4],
                      //show loading progress
                      height: 200, errorBuilder: (context, child, error) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text('Error loading image'),
                      ),
                    );
                  }, loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()));
                  }),
                  //gridview to show the links and copy button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: cdnListTiles,
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    storage.deleteSingleLink(rawLink);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const Home();
                    }));
                  }),
              ElevatedButton(
                child: const Text('Back'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}

class OfflineListTile extends StatelessWidget {
  const OfflineListTile({
    Key? key,
    required this.anchor,
    required this.rawLink,
  }) : super(key: key);

  final String anchor;
  final String rawLink;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.tv_off_rounded,
        size: 40.0,
        color: Color.fromARGB(255, 255, 112, 112),
      ),
      title: const Text('Disconnected'),
      subtitle: Text(anchor),
      trailing: const Icon(Icons.chevron_right_sharp),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Offline'),
                actions: [
                  TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        storage.deleteSingleLink(rawLink);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const Home();
                        }));
                      }),
                ],
              );
            });
      },
    );
  }
}

class ErrorListTile extends StatelessWidget {
  const ErrorListTile({
    Key? key,
    required this.error,
    required this.rawLink,
  }) : super(key: key);

  final Object? error;
  final String rawLink;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.tv_off_sharp,
        size: 40.0,
        color: Color.fromARGB(255, 255, 112, 112),
      ),
      title: const Text('Error'),
      subtitle: const Text(
          'For specific reasons, we do not have access to this live room'),
      trailing: const Icon(Icons.chevron_right_sharp),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text('$error'),
                  content: const Text(
                      'For specific reasons, we do not have access to this live room. Please check whether this live room can be accessed normally, if not, please submit the error message above.'),
                  actions: <Widget>[
                    TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          storage.deleteSingleLink(rawLink);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const Home();
                          }));
                        })
                  ]);
            });
      },
    );
  }
}
