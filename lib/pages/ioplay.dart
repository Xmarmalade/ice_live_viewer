import 'package:flutter/material.dart';
import 'package:ice_live_viewer/pages/mobileplay.dart';
import 'package:ice_live_viewer/pages/desktopplay.dart';
import 'dart:io';

class StreamPlayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return (Platform.isWindows)
        ? VlcPlayer(
            title: title,
            url: url,
            danmakuId: danmakuId,
            type: type,
          )
        : MobilePlayer(
            title: title,
            url: url,
            danmakuId: danmakuId,
            type: type,
          );
  }
}
