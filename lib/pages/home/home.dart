import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/hooks/use_fvp_player.dart';
import 'package:iris/hooks/use_media_kit_player.dart';
import 'package:iris/models/store/app_state.dart';
import 'package:iris/pages/player/iris_player.dart';
import 'package:iris/store/use_app_store.dart';

class Home extends HookWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final playerBackend =
        useAppStore().select(context, (state) => state.playerBackend);

    final player = () {
      switch (playerBackend) {
        case PlayerBackend.mediaKit:
          return IrisPlayer(
            key: const ValueKey('media-kit'),
            playerHooks: useMediaKitPlayer,
          );
        case PlayerBackend.fvp:
          return IrisPlayer(
            key: const ValueKey('fvp'),
            playerHooks: useFvpPlayer,
          );
      }
    }();

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(body: player),
    );
  }
}
