import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';

class LiveVideoFrame extends StatefulWidget {
  const LiveVideoFrame({
    Key? key,
    required this.videoWidget,
    required this.player,
    //required this.isFullscreen,
  }) : super(key: key);

  final Video videoWidget;
  final Player player;
  //final bool isFullscreen;

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
                    child: Stack(fit: StackFit.expand, children: [
                      //widget.videoWidget,
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
                                  flex: 9, child: SizedBox(width: 8)),
                            ],
                          )),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: VolumeControl(
                          player: player,
                          thumbColor: Colors.white70,
                        ),
                      )
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

class VolumeControl extends StatefulWidget {
  final Player player;
  final Color? thumbColor;

  const VolumeControl({
    required this.player,
    required this.thumbColor,
    Key? key,
  }) : super(key: key);

  @override
  _VolumeControlState createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double volume = 0.5;
  bool _showVolume = false;
  double unmutedVolume = 0.5;

  Player get player => widget.player;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _showVolume ? 0.8 : 0,
          child: AbsorbPointer(
            absorbing: !_showVolume,
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _showVolume = true);
              },
              onExit: (_) {
                setState(() => _showVolume = false);
              },
              child: SizedBox(
                width: 50,
                height: 150,
                child: Card(
                  color: const Color(0xff424242),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbColor: widget.thumbColor,
                      ),
                      child: Slider.adaptive(
                        label: (player.general.volume * 100).toInt().toString(),
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        value: player.general.volume,
                        onChanged: (volume) {
                          player.setVolume(volume);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        MouseRegion(
          onEnter: (_) {
            setState(() => _showVolume = true);
          },
          onExit: (_) {
            setState(() => _showVolume = false);
          },
          child: IconButton(
            color: Colors.white,
            onPressed: () => muteUnmute(),
            icon: Icon(getIcon()),
          ),
        ),
      ],
    );
  }

  IconData getIcon() {
    if (player.general.volume > .5) {
      return Icons.volume_up_sharp;
    } else if (player.general.volume > 0) {
      return Icons.volume_down_sharp;
    } else {
      return Icons.volume_off_sharp;
    }
  }

  void muteUnmute() {
    if (player.general.volume > 0) {
      unmutedVolume = player.general.volume;
      player.setVolume(0);
    } else {
      player.setVolume(unmutedVolume);
    }
    setState(() {});
  }
}

/* class CdnControl extends StatefulWidget {
  final Player player;
  final Map streams;
  CdnControl({Key? key, required this.player, required this.streams})
      : super(key: key);

  @override
  State<CdnControl> createState() => _CdnControlState();
}

class _CdnControlState extends State<CdnControl> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
} */
