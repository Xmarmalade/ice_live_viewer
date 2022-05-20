import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';

class StreamPlayer extends StatefulWidget {
  const StreamPlayer({Key? key, required this.title, required this.url})
      : super(key: key);
  final String title;
  final String url;
  @override
  State<StreamPlayer> createState() => _StreamPlayerState();
}

class _StreamPlayerState extends State<StreamPlayer> {
  @override
  Widget build(BuildContext context) {
    final streamPlayer = Player(id: 11);
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
      body: Center(
        child: Video(
          player: streamPlayer,
          showControls: true,
        ),
      ),
    );
  }
}
