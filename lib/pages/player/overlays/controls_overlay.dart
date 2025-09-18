import 'dart:async';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/globals.dart' show speedStops, speedSelectorItemWidth;
import 'package:iris/hooks/use_gesture.dart';
import 'package:iris/models/file.dart';
import 'package:iris/models/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/pages/player/control_bar/control_bar.dart';
import 'package:iris/pages/player/control_bar/control_bar_slider.dart';
import 'package:iris/pages/player/overlays/speed_selector.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:iris/store/use_player_ui_store.dart';
import 'package:iris/utils/format_duration_to_minutes.dart';
import 'package:iris/widgets/drag_area.dart';
import 'package:iris/widgets/title_bar.dart';
import 'package:provider/provider.dart';

class ControlsOverlay extends HookWidget {
  const ControlsOverlay({
    super.key,
    required this.file,
    required this.title,
    required this.showControl,
    required this.showControlForHover,
    required this.hideControl,
    required this.showProgress,
  });

  final FileItem? file;
  final String title;
  final Function() showControl;
  final Future<void> Function(Future<void> callback) showControlForHover;
  final Function() hideControl;
  final Function() showProgress;

  @override
  Widget build(BuildContext context) {
    final isPlaying =
        context.select<MediaPlayer, bool>((player) => player.isPlaying);

    final progress =
        context.select<MediaPlayer, ({Duration position, Duration duration})>(
      (player) => (position: player.position, duration: player.duration),
    );

    final saveProgress = context.read<MediaPlayer>().saveProgress;

    final isShowControl =
        usePlayerUiStore().select(context, (state) => state.isShowControl);
    final isShowProgress =
        usePlayerUiStore().select(context, (state) => state.isShowProgress);

    final isSpeedSelectorVisible = useState(false);
    final selectedSpeed = useState(1.0);
    final speedSelectorPosition = useState(Offset.zero);
    final visualOffset = useState(0.0);
    final initialSpeed = useRef(1.0);

    void showSpeedSelectorCallback(Offset position) {
      isSpeedSelectorVisible.value = true;
      speedSelectorPosition.value = position;
      visualOffset.value = 0.0;
      initialSpeed.value = useAppStore().state.rate;
    }

    void hideSpeedSelectorCallback(double finalSpeed) {
      final initialIndex = speedStops.indexOf(initialSpeed.value);
      final finalIndex = speedStops.indexOf(finalSpeed);

      if (initialIndex == -1 || finalIndex == -1) return;

      visualOffset.value = (initialIndex - finalIndex) * speedSelectorItemWidth;

      Future.delayed(
        const Duration(milliseconds: 200),
        () {
          if (context.mounted) {
            isSpeedSelectorVisible.value = false;
          }
        },
      );
    }

    void updateSelectedSpeedCallback(double speed, double newVisualOffset) {
      selectedSpeed.value = speed;
      visualOffset.value = newVisualOffset;
    }

    final gesture = useGesture(
      showControl: showControl,
      hideControl: hideControl,
      showProgress: showProgress,
      showSpeedSelector: showSpeedSelectorCallback,
      hideSpeedSelector: hideSpeedSelectorCallback,
      updateSelectedSpeed: updateSelectedSpeedCallback,
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
        Positioned.fill(
          child: MouseRegion(
            cursor: isShowControl || isPlaying == false
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
                  if (isSpeedSelectorVisible.value)
                    Positioned.fill(
                      child: SpeedSelector(
                        selectedSpeed: selectedSpeed.value,
                        visualOffset: visualOffset.value,
                        initialSpeed: initialSpeed.value,
                      ),
                    ),
                  // 屏幕亮度
                  if (gesture.isLeftGesture && gesture.brightness != null)
                    Positioned.fill(
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
                    Positioned.fill(
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
                      file?.type == ContentType.video)
                    Positioned(
                      left: -28,
                      right: -28,
                      bottom: -16,
                      height: 32,
                      child: ControlBarSlider(
                        showControl: showControl,
                        disabled: true,
                      ),
                    ),
                  if (isShowProgress &&
                      !isShowControl &&
                      file?.type == ContentType.video)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file != null ? title : '',
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
                      file?.type == ContentType.video)
                    Positioned(
                      left: 12,
                      bottom: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatDurationToMinutes(progress.position)} / ${formatDurationToMinutes(progress.duration)}',
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
          top: isShowControl || file?.type != ContentType.video ? 0 : -72,
          left: 0,
          right: 0,
          child: MouseRegion(
            onHover: gesture.onHover,
            child: GestureDetector(
              onTap: () => showControl(),
              child: DragArea(
                child: TitleBar(
                  title: title,
                  actions: [const SizedBox(width: 8)],
                  color: contentColor,
                  overlayColor: overlayColor,
                  saveProgress: () => saveProgress(),
                ),
              ),
            ),
          ),
        ),
        // 控制栏
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubicEmphasized,
          bottom: isShowControl || file?.type != ContentType.video ? 0 : -128,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: MouseRegion(
              onHover: gesture.onHover,
              child: GestureDetector(
                onTap: () => showControl(),
                child: ControlBar(
                  showControl: showControl,
                  showControlForHover: showControlForHover,
                  color: contentColor,
                  overlayColor: overlayColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
