import 'dart:async';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/hooks/use_gesture.dart';
import 'package:iris/models/file.dart';
import 'package:iris/models/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/pages/player/control_bar/control_bar.dart';
import 'package:iris/pages/player/control_bar/control_bar_slider.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:iris/store/use_player_ui_store.dart';
import 'package:iris/utils/format_duration_to_minutes.dart';
import 'package:iris/utils/resize_window.dart';
import 'package:iris/widgets/drag_aria.dart';
import 'package:iris/widgets/title_bar.dart';

class ControlsOverlay extends HookWidget {
  const ControlsOverlay({
    super.key,
    required this.player,
    required this.currentPlay,
    required this.title,
    required this.showControl,
    required this.showControlForHover,
    required this.hideControl,
    required this.showProgress,
  });

  final MediaPlayer player;
  final PlayQueueItem? currentPlay;
  final String title;
  final Function() showControl;
  final Future<void> Function(Future<void> callback) showControlForHover;
  final Function() hideControl;
  final Function() showProgress;

  @override
  Widget build(BuildContext context) {
    final rate = useAppStore().select(context, (state) => state.rate);

    final aspectRatio =
        usePlayerUiStore().select(context, (state) => state.aspectRatio);
    final isShowControl =
        usePlayerUiStore().select(context, (state) => state.isShowControl);
    final isShowProgress =
        usePlayerUiStore().select(context, (state) => state.isShowProgress);

    final gesture = useGesture(
      player: player,
      showControl: showControl,
      hideControl: hideControl,
      showProgress: showProgress,
    );

    final contentColor = useMemoized(
        () => Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.surface,
        [context]);

    final overlayColor = useMemoized(
        () =>
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return contentColor.withValues(alpha: 0.2);
              } else if (states.contains(WidgetState.hovered)) {
                return contentColor.withValues(alpha: 0.2);
              }
              return null;
            }),
        [contentColor]);

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: isShowControl || player.isPlaying == false
                ? SystemMouseCursors.basic
                : SystemMouseCursors.none,
            onHover: gesture.onHover,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: gesture.onTap,
              onTapDown: gesture.onTapDown,
              onDoubleTapDown: gesture.onDoubleTapDown,
              onLongPressStart: gesture.onLongPressStart,
              onLongPressMoveUpdate: gesture.onLongPressMoveUpdate,
              onLongPressEnd: gesture.onLongPressEnd,
              onLongPressCancel: gesture.onLongPressCancel,
              onPanStart: gesture.onPanStart,
              onPanUpdate: gesture.onPanUpdate,
              onPanEnd: gesture.onPanEnd,
              onPanCancel: gesture.onPanCancel,
              child: Stack(
                children: [
                  // 播放速度
                  if (rate != 1.0 && gesture.isLongPress)
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 18, 12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, 1.5),
                                child: Icon(
                                  Icons.speed_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                rate.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // 屏幕亮度
                  if (gesture.isLeftGesture && gesture.brightness != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 18, 12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                gesture.brightness == 0
                                    ? Icons.brightness_low_rounded
                                    : gesture.brightness! < 1
                                        ? Icons.brightness_medium_rounded
                                        : Icons.brightness_high_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  value: gesture.brightness,
                                  borderRadius: BorderRadius.circular(4),
                                  backgroundColor: Colors.grey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // 音量
                  if (gesture.isRightGesture && gesture.volume != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 18, 12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                gesture.volume == 0
                                    ? Icons.volume_mute_rounded
                                    : gesture.volume! < 0.5
                                        ? Icons.volume_down_rounded
                                        : Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  value: gesture.volume,
                                  borderRadius: BorderRadius.circular(4),
                                  backgroundColor: Colors.grey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (isShowProgress &&
                      !isShowControl &&
                      currentPlay?.file.type == ContentType.video)
                    Positioned(
                      left: -28,
                      right: -28,
                      bottom: -16,
                      height: 32,
                      child: ControlBarSlider(
                        player: player,
                        showControl: showControl,
                        disabled: true,
                      ),
                    ),
                  if (isShowProgress &&
                      !isShowControl &&
                      currentPlay?.file.type == ContentType.video)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPlay != null ? title : '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 1,
                              decoration: TextDecoration.none,
                              shadows: const [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(0, 0),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isShowProgress &&
                      !isShowControl &&
                      currentPlay?.file.type == ContentType.video)
                    Positioned(
                      left: 12,
                      bottom: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatDurationToMinutes(player.position)} / ${formatDurationToMinutes(player.duration)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 2,
                              decoration: TextDecoration.none,
                              shadows: const [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(0, 0),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // 标题栏
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubicEmphasized,
          top: isShowControl || currentPlay?.file.type != ContentType.video
              ? 0
              : -72,
          left: 0,
          right: 0,
          child: SafeArea(
            child: MouseRegion(
              onHover: gesture.onHover,
              child: GestureDetector(
                onTap: () => showControl(),
                child: DragAria(
                  child: TitleBar(
                    title: title,
                    actions: [const SizedBox(width: 8)],
                    color: contentColor,
                    overlayColor: overlayColor,
                    saveProgress: () => player.saveProgress(),
                    resizeWindow: () => resizeWindow(aspectRatio),
                  ),
                ),
              ),
            ),
          ),
        ),
        // 控制栏
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubicEmphasized,
          bottom: isShowControl || currentPlay?.file.type != ContentType.video
              ? 0
              : -128,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: MouseRegion(
                onHover: gesture.onHover,
                child: GestureDetector(
                  onTap: () => showControl(),
                  child: ControlBar(
                    player: player,
                    showControl: showControl,
                    showControlForHover: showControlForHover,
                    color: contentColor,
                    overlayColor: overlayColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
