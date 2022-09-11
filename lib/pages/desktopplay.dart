import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:ice_live_viewer/widgets/douyudanmaku.dart';
import 'package:ice_live_viewer/widgets/videoframe.dart';
import 'package:ice_live_viewer/widgets/bilibilianmaku.dart';
import 'package:ice_live_viewer/widgets/huyadanmaku.dart';

class VlcPlayer extends StatefulWidget {
  const VlcPlayer(
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
  State<VlcPlayer> createState() => _VlcPlayerState();
}

class _VlcPlayerState extends State<VlcPlayer> {
  final streamPlayer = Player(id: 11, registerTexture: true);
  @override
  void initState() {
    super.initState();
    final streamInfo = Media.network(widget.url);
    streamPlayer.open(streamInfo, autoStart: true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    final nativeVideo = Video(player: streamPlayer, showControls: false);
    final videoFrame =
        LiveVideoFrame(videoWidget: nativeVideo, player: streamPlayer);
    final danmakuListView = widget.type == 'huya'
        ? HuyaDanmakuListView(danmakuId: widget.danmakuId)
        : (widget.type == 'bilibili'
            ? BilibiliDanmakuListView(roomId: widget.danmakuId)
            : DouYuDanmakuListView(roomId: widget.danmakuId));
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
                  Expanded(flex: 4, child: videoFrame),
                  Expanded(flex: 1, child: danmakuListView),
                ],
              )
            : Column(
                children: <Widget>[
                  Expanded(flex: 3, child: videoFrame),
                  Expanded(flex: 5, child: danmakuListView),
                ],
              ));
  }
}
