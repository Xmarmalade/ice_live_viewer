import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';

class LiveVideoFrame extends StatefulWidget {
  const LiveVideoFrame({
    Key? key,
    required this.videoWidget,
    required this.player,
  }) : super(key: key);

  final Video videoWidget;
  final Player player;

  @override
  State<LiveVideoFrame> createState() => _LiveVideoFrameState();
}

class _LiveVideoFrameState extends State<LiveVideoFrame>
    with SingleTickerProviderStateMixin {
  Player get player => widget.player;

  bool _hideControls = true;
  bool _displayTapped = false;
  Timer? _hideTimer;
  late StreamSubscription<PlaybackState> playPauseStream;
  late AnimationController playPauseController;

  @override
  void initState() {
    super.initState();
    playPauseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    playPauseStream = player.playbackStream
        .listen((event) => setPlaybackMode(event.isPlaying));
    if (player.playback.isPlaying) playPauseController.forward();
  }

  @override
  void dispose() {
    playPauseStream.cancel();
    playPauseController.dispose();
    super.dispose();
  }

  void setPlaybackMode(bool isPlaying) {
    if (isPlaying) {
      playPauseController.forward();
    } else {
      playPauseController.reverse();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (player.playback.isPlaying) {
            if (_displayTapped) {
              setState(() => _hideControls = true);
            } else {
              _cancelAndRestartTimer();
            }
          } else {
            setState(() => _hideControls = true);
          }
        },
        child: MouseRegion(
          onHover: (_) => _cancelAndRestartTimer(),
          child: AbsorbPointer(
              absorbing: _hideControls,
              child: Stack(
                children: [
                  widget.videoWidget,
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _hideControls ? 0.0 : 1.0,
                    child: Stack(children: [
                      widget.videoWidget,
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xCC000000),
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0xCC000000),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 8,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    color: Colors.white,
                                    splashRadius: 12,
                                    iconSize: 28,
                                    icon: AnimatedIcon(
                                        icon: AnimatedIcons.play_pause,
                                        progress: playPauseController),
                                    onPressed: () {
                                      if (player.playback.isPlaying) {
                                        player.pause();
                                        playPauseController.reverse();
                                      } else {
                                        player.play();
                                        playPauseController.forward();
                                      }
                                    },
                                  ),
                                ),
                                const Expanded(
                                    flex: 8, child: SizedBox(width: 8)),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    color: Colors.white,
                                    splashRadius: 12,
                                    iconSize: 28,
                                    icon: const Icon(Icons.fullscreen),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            /* IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        if (player.playback.isPlaying) {
                          player.pause();
                        } else {
                          player.play();
                        }
                      },
                    ), */
                          )),
                    ]),
                  ),
                ],
              )),
        ));
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();

    if (mounted) {
      _startHideTimer();

      setState(() {
        _hideControls = false;
        _displayTapped = true;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hideControls = true;
        });
      }
    });
  }
}
