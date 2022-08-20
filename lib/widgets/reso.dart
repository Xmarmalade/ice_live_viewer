import 'package:flutter/material.dart';
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
  final bool _showResoluton = false;

  Player get player => widget.player;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      iconSize: 24,
      icon: const Icon(Icons.hd_rounded, color: Colors.white),
      onSelected: (Device device) {
        player.setDevice(device);
        setState(() {});
      },
      itemBuilder: (context) {
        return Devices.all
            .map(
              (device) => PopupMenuItem(
                child: Text(device.name,
                    style: const TextStyle(
                      fontSize: 14.0,
                    )),
                value: device,
              ),
            )
            .toList();
      },
    );
  }
}
