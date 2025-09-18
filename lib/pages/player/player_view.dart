import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/hooks/player/use_fvp_player.dart';
import 'package:iris/hooks/player/use_media_kit_player.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/store/app_state.dart';
import 'package:iris/pages/player/player.dart';
import 'package:provider/provider.dart';

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
    return Provider<MediaPlayer>.value(
      value: player,
      child: const Player(key: ValueKey('media_kit_player')),
    );
  }
}

class _FvpPlayerHost extends HookWidget {
  const _FvpPlayerHost();

  @override
  Widget build(BuildContext context) {
    final player = useFvpPlayer(context);
    return Provider<MediaPlayer>.value(
      value: player,
      child: const Player(key: ValueKey('fvp_player')),
    );
  }
}
