import 'package:flutter/material.dart';
import 'package:ice_live_viewer/widgets/douyudanmaku.dart';
import 'package:ice_live_viewer/widgets/huyadanmaku.dart';
import 'package:ice_live_viewer/widgets/bilibilianmaku.dart';

class PureDanmaku extends StatelessWidget {
  const PureDanmaku(
      {Key? key,
      required this.title,
      required this.danmakuId,
      required this.type})
      : super(key: key);

  final String title;
  final String type;
  final int danmakuId;
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
        title: Text(title),
      ),
      body: type == 'bilibili'
          ? BilibiliDanmakuListView(roomId: danmakuId)
          : (type == 'huya'
              ? HuyaDanmakuListView(danmakuId: danmakuId)
              : DouYuDanmakuListView(roomId: danmakuId)),
    );
  }
}
