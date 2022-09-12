import 'package:flutter/material.dart';
import 'package:ice_live_viewer/widgets/bilibilianmaku.dart';
import 'package:ice_live_viewer/widgets/huyadanmaku.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:ice_live_viewer/widgets/douyudanmaku.dart';
import 'package:wakelock/wakelock.dart';

class MobilePlayer extends StatefulWidget {
  const MobilePlayer(
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
  State<MobilePlayer> createState() => _MobilePlayerState();
}

class _MobilePlayerState extends State<MobilePlayer> {
  late VideoPlayerController _controller;
  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    //Wakelock.enabled.then((value) => print('Wakelock:$value'));
    final ratio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

    final chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
    );
    final nativeVideo = _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Chewie(
              controller: chewieController,
            ))
        : AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
            ),
          );
    final danmakuListView = widget.type == 'huya'
        ? HuyaDanmakuListView(danmakuId: widget.danmakuId)
        : (widget.type == 'bilibili'
            ? BilibiliDanmakuListView(roomId: widget.danmakuId)
            : DouYuDanmakuListView(roomId: widget.danmakuId));
    return WillPopScope(
      onWillPop: () async {
        _controller.pause();
        Wakelock.disable();
        //Wakelock.enabled.then((value) => print('Wakelock:$value'));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Wakelock.disable();
              //Wakelock.enabled.then((value) => print('Wakelock:$value'));
            },
          ),
          title: Text(widget.title),
        ),
        body: ratio > 1.2
            ? Row(
                children: <Widget>[
                  nativeVideo,
                  Expanded(
                    child: danmakuListView,
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  nativeVideo,
                  Expanded(
                    child: danmakuListView,
                  ),
                ],
              ),
      ),
    );
  }
}

class ChewiePlayer extends StatefulWidget {
  const ChewiePlayer({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<ChewiePlayer> createState() => _ChewiePlayerState();
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoInitialize: true,
        allowFullScreen: true,
        showControls: true,
        autoPlay: true);
    AspectRatio videoPlayerContainer =
        _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController,
                ))
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                ),
              );
    return videoPlayerContainer;
  }
}

/* class BPlayer extends StatefulWidget {
  const BPlayer({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<BPlayer> createState() => _BPlayerState();
}

class _BPlayerState extends State<BPlayer> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer.network(
        widget.url,
        betterPlayerConfiguration: const BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}
 */

class PlayPage extends StatelessWidget {
  const PlayPage(
      {Key? key,
      required this.title,
      required this.url,
      required this.danmakuId})
      : super(key: key);

  final String title;
  final String url;
  final int danmakuId;

  @override
  Widget build(BuildContext context) {
    final ratio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    final nativeVideo = ChewiePlayer(url: url);

    var huyaDanmakuListView = HuyaDanmakuListView(
      danmakuId: danmakuId,
    );
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
      body: ratio > 1.2
          ? Row(
              children: <Widget>[
                nativeVideo,
                Expanded(
                  child: huyaDanmakuListView,
                ),
              ],
            )
          : Column(
              children: <Widget>[
                nativeVideo,
                Expanded(
                  child: HuyaDanmakuListView(
                    danmakuId: danmakuId,
                  ),
                ),
              ],
            ),
    );
  }
}
