import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/store/use_player_ui_store.dart';
import 'package:iris/utils/platform.dart';
import 'package:iris/utils/resize_window.dart';
import 'package:window_manager/window_manager.dart';

class DragAria extends StatelessWidget {
  const DragAria({
    super.key,
    required this.child,
  });

  final Widget child;
  @override
  Widget build(BuildContext context) {
    final aspectRatio =
        usePlayerUiStore().select(context, (state) => state.aspectRatio);
    final isFullScreen =
        usePlayerUiStore().select(context, (state) => state.isFullScreen);

    return GestureDetector(
      onDoubleTap: () async {
        if (isFullScreen) {
          await usePlayerUiStore().updateFullScreen(false);
        } else {
          if (isDesktop && await windowManager.isMaximized()) {
            await windowManager.unmaximize();
            await resizeWindow(aspectRatio);
          } else {
            await windowManager.maximize();
          }
        }
      },
      onPanStart: (details) async {
        if (isDesktop) {
          windowManager.startDragging();
        }
      },
      child: child,
    );
  }
}
