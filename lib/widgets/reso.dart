/* import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';

class ResolutionControl extends StatefulWidget {
  final Player player;
  final Map resolutions;

  const ResolutionControl({
    required this.player,
    required this.resolutions,
    Key? key,
  }) : super(key: key);

  @override
  _ResolutionControlState createState() => _ResolutionControlState();
}

class _ResolutionControlState extends State<ResolutionControl> {
  bool _showResoluton = false;



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
} */