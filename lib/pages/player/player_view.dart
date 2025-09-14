import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/hooks/player/use_fvp_player.dart';
import 'package:iris/hooks/player/use_media_kit_player.dart';
import 'package:iris/models/store/app_state.dart';
import 'package:iris/pages/player/player.dart';

class PlayerView extends HookWidget {
  const PlayerView({super.key, required this.playerBackend});

  final PlayerBackend playerBackend;

  @override
  Widget build(BuildContext context) {
    switch (playerBackend) {
      case PlayerBackend.mediaKit:
        return const _MediaKitPlayerHost();
      case PlayerBackend.fvp:
        return const _FvpPlayerHost();
    }
  }
}

class _MediaKitPlayerHost extends HookWidget {
  const _MediaKitPlayerHost();

  @override
  Widget build(BuildContext context) {
    final player = useMediaKitPlayer(context);
    return Player(player: player);
  }
}

class _FvpPlayerHost extends HookWidget {
  const _FvpPlayerHost();

  @override
  Widget build(BuildContext context) {
    final player = useFvpPlayer(context);
    return Player(player: player);
  }
}
