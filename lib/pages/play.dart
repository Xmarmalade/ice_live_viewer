import 'package:flutter/material.dart';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:ice_live_viewer/widgets/bilibilianmaku.dart';
import 'package:ice_live_viewer/widgets/huyadanmaku.dart';

class StreamPlayer extends StatefulWidget {
  const StreamPlayer(
      {Key? key,
      required this.title,
      required this.url,
      required this.danmakuId,
      required this.type})
      : super(key: key);

  final String title;
  final String url;
  final int danmakuId;
  final String type;
  @override
  State<StreamPlayer> createState() => _StreamPlayerState();
}

class _StreamPlayerState extends State<StreamPlayer> {
  final streamPlayer = Player(id: 11, registerTexture: true);
  @override
  void initState() {
    super.initState();
    debugPrint('initState');
    final streamInfo = Media.network(widget.url);
    streamPlayer.open(streamInfo, autoStart: true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    final nativeVideo = Video(
      player: streamPlayer,
      showControls: true,
      //showFullscreenButton: true,
      showTimeLeft: false,
    );
    final danmakuListView = widget.type == 'huya'
        ? HuyaDanmakuListView(danmakuId: widget.danmakuId)
        : BilibiliDanmakuListView(roomId: widget.danmakuId);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              streamPlayer.stop();
            },
          ),
          title: Text(widget.title),
        ),
        body: ratio > 1.2
            ? Row(
                children: <Widget>[
                  Expanded(flex: 4, child: nativeVideo),
                  Expanded(flex: 1, child: danmakuListView),
                ],
              )
            : Column(
                children: <Widget>[
                  Expanded(flex: 3, child: nativeVideo),
                  Expanded(flex: 5, child: danmakuListView),
                ],
              ));
  }
}
