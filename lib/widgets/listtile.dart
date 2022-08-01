import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_live_viewer/pages/danmaku.dart';
import 'package:ice_live_viewer/pages/home.dart';
import 'package:ice_live_viewer/pages/play.dart';
import 'package:ice_live_viewer/utils/bilibiliparser.dart' as bilibili;
import 'package:ice_live_viewer/utils/huyaparseer.dart' as huya;
import 'package:ice_live_viewer/utils/linkparser.dart';
import 'package:ice_live_viewer/utils/storage.dart' as storage;

class HuyaFutureListTileSkeleton extends StatelessWidget {
  const HuyaFutureListTileSkeleton({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: huya.getLiveInfo(url),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> liveInfo =
              (snapshot.data as Map<String, dynamic>);
          if (liveInfo['liveStatus'] == 0) {
            return OfflineListTile(anchor: liveInfo['name'], rawLink: url);
          } else {
            return HuyaOnlineListTile(
                rawLink: url, context: context, liveInfo: liveInfo);
          }
        } else if (snapshot.hasError) {
          return ErrorListTile(error: snapshot.error, rawLink: url);
        }
        return const ListTile(
          title: Text('Loading...'),
          subtitle: LinearProgressIndicator(),
        );
      },
    );
  }
}

class HuyaOnlineListTile extends StatelessWidget {
  const HuyaOnlineListTile({
    Key? key,
    required this.rawLink,
    required this.liveInfo,
    required this.context,
  }) : super(key: key);

  final Map<String, dynamic> liveInfo;
  final BuildContext context;
  final String rawLink;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(liveInfo['avatar']),
      ),
      title: Text(liveInfo['title']),
      subtitle: Text(liveInfo['name']),
      trailing: const Icon(Icons.chevron_right_sharp),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              String title = liveInfo['title'];
              int lUid = liveInfo['luid'];
              List<String> linkList = liveInfo['linkList'];
              int cdnCount = liveInfo['cdnCount'];
              List<Widget> cdnListTiles = [];
              for (var i = 1; i <= cdnCount; i++) {
                String cdnName = linkList[i * 2 - 2];
                String cdnLink = linkList[i * 2 - 1];
                String fhdLink =
                    cdnLink.replaceAll('imgplus.flv', 'imgplus_4000.flv');
                String hdLink =
                    cdnLink.replaceAll('imgplus.flv', 'imgplus_2000.flv');
                String sdLink =
                    cdnLink.replaceAll('imgplus.flv', 'imgplus_1500.flv');
                List<PopupMenuEntry<String>> resolution = [
                  PopupMenuItem(
                    value: fhdLink,
                    child: const Text('1080P'),
                  ),
                  PopupMenuItem(
                    value: hdLink,
                    child: const Text('720P'),
                  ),
                  PopupMenuItem(
                    value: sdLink,
                    child: const Text('540P'),
                  ),
                ];
                cdnListTiles.add(ListTile(
                  leading: Text(cdnName),
                  subtitle: Text(
                    cdnLink,
                    maxLines: 2,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy',
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
                          return resolution;
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Play',
                        onSelected: (context) {
                          String roomSelectedUrl = context;
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => StreamPlayer(
                                        title: title,
                                        url: roomSelectedUrl,
                                        danmakuId: lUid,
                                      )));
                        },
                        itemBuilder: (context) {
                          return resolution;
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.text_fields),
                        tooltip: 'Only danmaku',
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PureDanmaku(
                                        title: title,
                                        danmakuId: lUid,
                                      )));
                        },
                      )
                    ],
                  ),
                ));
              }
              return AlertDialog(
                scrollable: true,
                title: Text(title),
                content: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      //show network image of cover
                      Image.network(liveInfo['cover'],
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
                                child:
                                    Center(child: CircularProgressIndicator()));
                      }),
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
      },
    );
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

class BilibiliFutureListTileSkeleton extends StatelessWidget {
  const BilibiliFutureListTileSkeleton({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    String roomId = LinkParser().getRoomId(url);
    return FutureBuilder(
      future: bilibili.getLiveInfoAndStreamLink(roomId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> liveInfo = (snapshot.data as Map)['liveInfo'];
          if (liveInfo['liveStatus'] == '0') {
            return OfflineListTile(anchor: liveInfo['uname'], rawLink: url);
          } else if (liveInfo['liveStatus'] == '2') {
            return OfflineListTile(anchor: liveInfo['uname'], rawLink: url);
          } else {
            Map<String, List> streamLink = (snapshot.data as Map)['streamLink'];
            return BilibiliOnlineListTile(
                context: context,
                rawLink: url,
                liveInfo: liveInfo,
                streamLink: streamLink);
          }
        } else if (snapshot.hasError) {
          return ErrorListTile(error: snapshot.error, rawLink: url);
        }
        return const ListTile(
          title: Text('Loading...'),
          subtitle: LinearProgressIndicator(),
        );
      },
    );
  }
}

class BilibiliOnlineListTile extends StatelessWidget {
  const BilibiliOnlineListTile({
    Key? key,
    required this.rawLink,
    required this.context,
    required this.liveInfo,
    required this.streamLink,
  }) : super(key: key);

  final String rawLink;
  final BuildContext context;
  final Map<String, dynamic> liveInfo;
  final Map<String, List> streamLink;

  ///liveStatus:直播状态 0未开播 1直播 2轮播
  ///title:直播标题
  ///uname:主播名字
  ///avatar:主播头像
  ///cover:直播封面
  ///keyframe:视频关键帧
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(liveInfo['avatar']),
      ),
      title: Text(liveInfo['title']),
      subtitle: Text(liveInfo['uname']),
      trailing: const Icon(Icons.chevron_right_sharp),
      onTap: () {},
    );
  }
}
