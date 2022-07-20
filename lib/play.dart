import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:ice_live_viewer/websocket.dart';

class StreamPlayer extends StatefulWidget {
  const StreamPlayer(
      {Key? key,
      required this.title,
      required this.url,
      required this.danmakuId})
      : super(key: key);
  final String title;
  final String url;
  final int danmakuId;
  @override
  State<StreamPlayer> createState() => _StreamPlayerState();
}

class _StreamPlayerState extends State<StreamPlayer> {
  @override
  Widget build(BuildContext context) {
    final streamPlayer = Player(id: 11, registerTexture: false);
    final streamInfo = Media.network(widget.url);
    streamPlayer.open(streamInfo, autoStart: true);
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
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: NativeVideo(
              player: streamPlayer,
              showControls: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: HuyaDanmakuListView(
              danmakuId: widget.danmakuId,
            ),
          ),
        ],
      ),
    );
  }
}

/*
Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Center(
                  child: Text(
                    '${widget.danmakuId}',
                    style: TextStyle(fontSize: 20),
                  ),
                )),
              ],
            )


Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NativeVideo(
                    player: streamPlayer,
                    showControls: true,
                    //fit: BoxFit.contain,
                    height: 400,
                  ),
                ),
              ],
            ),
*/