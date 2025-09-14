import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/models/player.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';

class VideoView extends HookWidget {
  const VideoView({
    super.key,
    required this.player,
    required this.fit,
  });

  final MediaPlayer player;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return switch (player) {
      MediaKitPlayer player => Video(
          controller: player.controller,
          controls: NoVideoControls,
          fit: fit == BoxFit.none ? BoxFit.contain : fit,
        ),
      FvpPlayer player => FittedBox(
          fit: fit,
          child: SizedBox(
            width: player.width,
            height: player.height,
            child: VideoPlayer(player.controller),
          ),
        ),
      _ => Container(),
    };
  }
}
