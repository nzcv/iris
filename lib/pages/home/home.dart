import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/hooks/ui/use_full_screen.dart';
import 'package:iris/hooks/ui/use_orientation.dart';
import 'package:iris/hooks/ui/use_resize_window.dart';
import 'package:iris/pages/player/player_view.dart';
import 'package:iris/store/use_app_store.dart';

class Home extends HookWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    useFullScreen();
    useOrientation();
    useResizeWindow();

    final playerBackend =
        useAppStore().select(context, (state) => state.playerBackend);

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        body: PlayerView(playerBackend: playerBackend),
      ),
    );
  }
}
