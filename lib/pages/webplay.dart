import 'package:flutter/material.dart';
import 'package:ice_live_viewer/widgets/douyudanmaku.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    final danmakuListView = widget.type == 'huya'
        ? HuyaDanmakuListView(danmakuId: widget.danmakuId)
        : (widget.type == 'bilibili'
            ? BilibiliDanmakuListView(roomId: widget.danmakuId)
            : DouYuDanmakuListView(roomId: widget.danmakuId));
    Widget videoFrame = Container(
      color: Colors.black,
      child: const Center(
        child: Text('Video Frame'),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
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
