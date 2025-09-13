import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/hooks/player/use_fvp_player.dart';
import 'package:iris/hooks/player/use_media_kit_player.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/store/app_state.dart';
import 'package:iris/pages/player/iris_player.dart';
import 'package:iris/store/use_app_store.dart';

class Home extends HookWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final playerBackend =
        useAppStore().select(context, (state) => state.playerBackend);

    final playerState = useState<MediaPlayer?>(null);

    void handlePlayerCreated(MediaPlayer player) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          playerState.value = player;
        }
      });
    }

    final Widget playerHost;
    switch (playerBackend) {
      case PlayerBackend.mediaKit:
        playerHost = _MediaKitPlayerHost(onPlayerCreated: handlePlayerCreated);
        break;
      case PlayerBackend.fvp:
        playerHost = _FvpPlayerHost(onPlayerCreated: handlePlayerCreated);
        break;
    }

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFF2f2f2f),
        body: Stack(
          children: [
            playerHost,
            if (playerState.value != null)
              IrisPlayer(player: playerState.value!)
          ],
        ),
      ),
    );
  }
}

class _MediaKitPlayerHost extends HookWidget {
  final ValueChanged<MediaPlayer> onPlayerCreated;

  const _MediaKitPlayerHost({required this.onPlayerCreated});

  @override
  Widget build(BuildContext context) {
    final player = useMediaKitPlayer(context);
    onPlayerCreated(player);
    return Container(); // Doesn't build any UI itself.
  }
}

class _FvpPlayerHost extends HookWidget {
  final ValueChanged<MediaPlayer> onPlayerCreated;

  const _FvpPlayerHost({required this.onPlayerCreated});

  @override
  Widget build(BuildContext context) {
    final player = useFvpPlayer(context);
    onPlayerCreated(player);
    return Container(); // Doesn't build any UI itself.
  }
}
