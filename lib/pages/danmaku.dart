import 'package:flutter/material.dart';
import 'package:ice_live_viewer/widgets/huyadanmaku.dart';

class PureDanmaku extends StatelessWidget {
  const PureDanmaku({Key? key, required this.title, required this.danmakuId})
      : super(key: key);

  final String title;
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
      body: HuyaDanmakuListView(
        danmakuId: danmakuId,
      ),
    );
  }
}
