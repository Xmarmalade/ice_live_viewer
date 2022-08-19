import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_live_viewer/pages/danmaku.dart';
import 'package:ice_live_viewer/pages/home.dart';
import 'package:ice_live_viewer/pages/play.dart';
import 'package:ice_live_viewer/utils/bilibiliparser.dart' as bilibili;
import 'package:ice_live_viewer/utils/huyaparseer.dart' as huya;
import 'package:ice_live_viewer/utils/douyuparser.dart';
import 'package:ice_live_viewer/utils/keepalivewrapper.dart';
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
    return KeepAliveWrapper(
      keepAlive: true,
      child: FutureBuilder(
        future: huya.getLiveInfo(url),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> liveInfo =
                (snapshot.data as Map<String, dynamic>);
            if (liveInfo['liveStatus'] == "0") {
              return OfflineListTile(
                anchor: liveInfo['name'],
                rawLink: url,
                avatar: liveInfo['avatar'],
                title: liveInfo['title'],
              );
            } else if (liveInfo['liveStatus'] == "2") {
              return OfflineListTile(
                anchor: liveInfo['name'],
                rawLink: url,
                avatar: liveInfo['avatar'],
                title: liveInfo['title'],
              );
            } else {
              return HuyaOnlineListTile(
                  rawLink: url, context: context, liveInfo: liveInfo);
            }
          } else if (snapshot.hasError) {
            return ErrorListTile(
              error: snapshot.error,
              rawLink: url,
              stackTrace: snapshot.stackTrace,
            );
          }
          return const ListTile(
            title: Text('Loading...'),
            subtitle: LinearProgressIndicator(),
          );
        },
      ),
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
              Map linkList = liveInfo['linkList'];
              List<Widget> cdnListTiles = [];
              for (String cdn in linkList.keys) {
                String cdnName = cdn;
                Map cdnLinkMap = linkList[cdn];
                String cdnLink = cdnLinkMap['原画'];
/*                 String fhdLink =
                    cdnLink.replaceAll('imgplus.flv', 'imgplus_4000.flv');
                String hdLink =
                    cdnLink.replaceAll('imgplus.flv', 'imgplus_2000.flv');
                String sdLink =
                    cdnLink.replaceAll('imgplus.flv', 'imgplus_1500.flv'); */
                //给定的清晰度
                List<PopupMenuEntry<String>> givenResolution = [];
                for (String reso in cdnLinkMap.keys) {
                  givenResolution.add(
                    PopupMenuItem(
                      value: cdnLinkMap[reso],
                      child: Text(reso),
                    ),
                  );
                }
                /* //自定的清晰度
                List<PopupMenuEntry<String>> customResolution = [
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
                ]; */
                cdnListTiles.add(
                  ListTile(
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
                            ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copied to clipboard')));
                          },
                          itemBuilder: (context) {
                            return givenResolution;
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
                                        type: 'huya')));
                          },
                          itemBuilder: (context) {
                            return givenResolution;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          tooltip: 'Only danmaku',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PureDanmaku(
                                        title: title,
                                        danmakuId: lUid,
                                        type: 'huya')));
                          },
                        )
                      ],
                    ),
                  ),
                );
              }
              return AlertDialog(
                scrollable: true,
                title:
                    Text(title, style: Theme.of(context).textTheme.headline1),
                content: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      //show network image of cover
                      Image.network(liveInfo['cover'],
                          //show loading progress
                          height: 200, errorBuilder: (context, child, error) {
                        debugPrint(error.toString());
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child:
                                Text('Error loading image:$error.toString()'),
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
    this.title = '',
    required this.avatar,
  }) : super(key: key);

  final String anchor;
  final String rawLink;
  final String? title;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatar),
      ),
      title: Text(title == '' ? 'Disconnected' : 'Disconnected - $title'),
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
    required this.stackTrace,
  }) : super(key: key);

  final Object? error;
  final String rawLink;
  final Object? stackTrace;

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
                  scrollable: true,
                  title: const Text(
                      'For specific reasons, we do not have access to this live room. Please check whether this live room can be accessed normally, if not, please submit the error message below.\n出现了问题，下面的内容或许可以帮助解决问题'),
                  content: Text(
                      'The Error is:\n$error \nHere is the raw link: $rawLink\nStack is:\n$stackTrace'),
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
                        child: const Text('Copy Error'),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: '$error\n$stackTrace'));
                        }),
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
    return KeepAliveWrapper(
      keepAlive: true,
      child: FutureBuilder(
        future: bilibili.getLiveInfoAndStreamLink(roomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> liveInfo = (snapshot.data as Map)['liveInfo'];
            if (liveInfo['liveStatus'] == '0') {
              return OfflineListTile(
                  anchor: liveInfo['uname'],
                  rawLink: url,
                  avatar: liveInfo['avatar']);
            } else if (liveInfo['liveStatus'] == '2') {
              return OfflineListTile(
                  anchor: liveInfo['uname'],
                  rawLink: url,
                  avatar: liveInfo['avatar']);
            } else {
              Map<String, List> streamLink =
                  (snapshot.data as Map)['streamLink'];
              liveInfo['roomId'] = roomId;
              return BilibiliOnlineListTile(
                  context: context,
                  rawLink: url,
                  liveInfo: liveInfo,
                  streamLink: streamLink);
            }
          } else if (snapshot.hasError) {
            return ErrorListTile(
                error: snapshot.error,
                rawLink: url,
                stackTrace: snapshot.stackTrace);
          }
          return const ListTile(
            title: Text('Loading...'),
            subtitle: LinearProgressIndicator(),
          );
        },
      ),
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
      onTap: () {
        debugPrint(streamLink.toString());
        showDialog(
            context: context,
            builder: (context) {
              List<Widget> resolutionListTiles = [];
              for (String resolution in streamLink.keys) {
                String resolutionHint = resolution == '4'
                    ? '原画'
                    : (resolution == '3' ? '超清' : '高清');
                List linkList = streamLink[resolution]!;
                List<PopupMenuEntry<String>> givenCdn = [];
                for (String cdnLink in linkList) {
                  givenCdn.add(
                    PopupMenuItem<String>(
                      value: cdnLink,
                      child: Text(
                          cdnLink.split('&').last.replaceAll('order=', '线路')),
                    ),
                  );
                }
                resolutionListTiles.add(ListTile(
                  leading: Text(resolutionHint),
                  subtitle: Text(
                    streamLink[resolution]![0] as String,
                    maxLines: 2,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Play',
                        onSelected: (context) {
                          String roomSelectedUrl = context;
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                  builder: (context) => StreamPlayer(
                                      url: roomSelectedUrl,
                                      title: liveInfo['title'],
                                      danmakuId: int.parse(liveInfo['roomId']),
                                      type: 'bilibili')));
                        },
                        itemBuilder: (context) {
                          return givenCdn;
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy',
                        onSelected: (context) {
                          String roomSelectedUrl = context;
                          Clipboard.setData(
                              ClipboardData(text: roomSelectedUrl));
                          //show a scaffold to show the copy success
                          ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                  content: Text('Copied to clipboard')));
                        },
                        itemBuilder: (context) {
                          return givenCdn;
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        tooltip: 'Only danmaku',
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PureDanmaku(
                                      title: liveInfo['title'],
                                      danmakuId: int.parse(liveInfo['roomId']),
                                      type: 'bilibili')));
                        },
                      ),
                    ],
                  ),
                  //onTap: () {},
                ));
              }
              return AlertDialog(
                title: Text(liveInfo['title']),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.network(liveInfo['keyframe'],
                        //show loading progress
                        height: 200, errorBuilder: (context, child, error) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child:
                              Text('Error loading image:${error.toString()}'),
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
                    const SizedBox(height: 10),
                    Column(
                      children: resolutionListTiles,
                    ),
                  ],
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
/*                   TextButton(
                    child: const Text('jump to danmaku(test)'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PureDanmaku(
                                    title: liveInfo['title'],
                                    danmakuId: int.parse(liveInfo['roomId']),
                                    type: 'bilibili',
                                  )));
                    },
                  ), */
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

class DouyuFutureListTileSkeleton extends StatelessWidget {
  const DouyuFutureListTileSkeleton({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    String roomId = url.split('/').last;
    return KeepAliveWrapper(
      keepAlive: true,
      child: FutureBuilder(
        future: Douyu(roomId).getRoomFullInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> liveInfo =
                (snapshot.data as Map<String, dynamic>);
            if (liveInfo['liveStatus'] == 0) {
              return OfflineListTile(
                anchor: liveInfo['name'],
                rawLink: url,
                avatar: liveInfo['avatar'],
                title: liveInfo['title'],
              );
            } else {
              return DouyuOnlineListTile(
                  rawLink: url, context: context, liveInfo: liveInfo);
            }
          } else if (snapshot.hasError) {
            return ErrorListTile(
              error: snapshot.error,
              rawLink: url,
              stackTrace: snapshot.stackTrace,
            );
          }
          return const ListTile(
            title: Text('Loading...'),
            subtitle: LinearProgressIndicator(),
          );
        },
      ),
    );
  }
}

class DouyuOnlineListTile extends StatelessWidget {
  const DouyuOnlineListTile({
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
              int lUid = int.parse(liveInfo['id']);
              Map linkList = liveInfo['linkList'];
              List<Widget> cdnListTiles = [];
              for (String cdn in linkList.keys) {
                String cdnName = cdn;
                Map cdnLinkMap = linkList[cdn];
                String cdnLink = cdnLinkMap['原画'];
                //给定的清晰度
                List<PopupMenuEntry<String>> givenResolution = [];
                for (String reso in cdnLinkMap.keys) {
                  givenResolution.add(
                    PopupMenuItem(
                      value: cdnLinkMap[reso],
                      child: Text(reso),
                    ),
                  );
                }
                cdnListTiles.add(
                  ListTile(
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
                            ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copied to clipboard')));
                          },
                          itemBuilder: (context) {
                            return givenResolution;
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
                                        type: 'huya')));
                          },
                          itemBuilder: (context) {
                            return givenResolution;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          tooltip: 'Only danmaku',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PureDanmaku(
                                        title: title,
                                        danmakuId: lUid,
                                        type: 'huya')));
                          },
                        )
                      ],
                    ),
                  ),
                );
              }
              return AlertDialog(
                scrollable: true,
                title:
                    Text(title, style: Theme.of(context).textTheme.headline1),
                content: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      //show network image of cover
                      Image.network(liveInfo['cover'],
                          //show loading progress
                          height: 200, errorBuilder: (context, child, error) {
                        debugPrint(error.toString());
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child:
                                Text('Error loading image:$error.toString()'),
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
