import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/models/player.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:video_player/video_player.dart';

class FvpVideo extends HookWidget {
  const FvpVideo({super.key, required this.player});

  final FvpPlayer player;

  @override
  Widget build(context) {
    final fit = useAppStore().select(context, (state) => state.fit);

    return FittedBox(
      fit: fit,
      child: SizedBox(
        width: player.width,
        height: player.height,
        child: VideoPlayer(player.controller),
      ),
    );
  }
}
