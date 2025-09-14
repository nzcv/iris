import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/hooks/use_brightness.dart';
import 'package:iris/hooks/use_volume.dart';
import 'package:iris/models/player.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:iris/store/use_player_ui_store.dart';
import 'package:iris/utils/platform.dart';
import 'package:iris/utils/resize_window.dart';
import 'package:window_manager/window_manager.dart';

class Gesture {
  final void Function(TapDownDetails) onTapDown;
  final void Function() onTap;
  final void Function(TapDownDetails) onDoubleTapDown;
  final void Function(LongPressStartDetails) onLongPressStart;
  final void Function(LongPressMoveUpdateDetails) onLongPressMoveUpdate;
  final void Function(LongPressEndDetails) onLongPressEnd;
  final void Function() onLongPressCancel;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final void Function() onPanCancel;
  final void Function(PointerHoverEvent) onHover;

  final bool isLongPress;
  final bool isLeftGesture;
  final bool isRightGesture;
  final double? brightness;
  final double? volume;
  final MouseCursor cursor;

  Gesture({
    required this.onTapDown,
    required this.onTap,
    required this.onDoubleTapDown,
    required this.onLongPressStart,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
    required this.onLongPressCancel,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onPanCancel,
    required this.onHover,
    required this.isLongPress,
    required this.isLeftGesture,
    required this.isRightGesture,
    required this.brightness,
    required this.volume,
    required this.cursor,
  });
}

Gesture useGesture({
  required MediaPlayer player,
  required void Function() showControl,
  required void Function() hideControl,
  required void Function() showProgress,
}) {
  final context = useContext();

  final aspectRatio =
      usePlayerUiStore().select(context, (state) => state.aspectRatio);

  final isFullScreen =
      usePlayerUiStore().select(context, (state) => state.isFullScreen);

  final isShowControl =
      usePlayerUiStore().select(context, (state) => state.isShowControl);
  final isSeeking =
      usePlayerUiStore().select(context, (state) => state.isSeeking);

  final updateIsHovering = useCallback((bool value) {
    usePlayerUiStore().updateIsHovering(value);
  }, [usePlayerUiStore().updateIsHovering]);

  final isTouch = useState(false);
  final isLongPress = useState(false);
  final startPosition = useState<Offset?>(null);
  final isHorizontalGesture = useState(false);
  final isVerticalGesture = useState(false);
  final isLeftGesture = useState(false);
  final isRightGesture = useState(false);

  final brightness = useBrightness(isLeftGesture.value);
  final volume = useVolume(isRightGesture.value);

  void onTapDown(TapDownDetails details) {
    if (details.kind == PointerDeviceKind.touch) {
      isTouch.value = true;
    }
  }

  void onTap() {
    if (isShowControl) {
      hideControl();
    } else {
      showControl();
    }
  }

  void onDoubleTapDown(TapDownDetails details) async {
    if (details.kind == PointerDeviceKind.touch) {
      double position =
          details.globalPosition.dx / MediaQuery.of(context).size.width;
      if (position > 0.75) {
        if (isShowControl) {
          showControl();
        } else {
          showProgress();
        }
        await player.forward(5);
      } else if (position < 0.25) {
        if (isShowControl) {
          showControl();
        } else {
          showProgress();
        }
        player.backward(5);
      } else {
        if (player.isPlaying == true) {
          await useAppStore().updateAutoPlay(false);
          player.pause();
          showControl();
        } else {
          await useAppStore().updateAutoPlay(true);
          player.play();
        }
      }
    } else {
      if (isDesktop) {
        if (isFullScreen) {
          await resizeWindow(aspectRatio);
        }
        usePlayerUiStore().updateFullScreen(!isFullScreen);
      }
    }
  }

  void onLongPressStart(LongPressStartDetails details) {
    if (isTouch.value && player.isPlaying == true) {
      isLongPress.value = true;
      useAppStore().updateRate(2.0);
    }
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!isLongPress.value) return;
    int fast = (details.offsetFromOrigin.dx / 50).toInt();
    if (fast >= 1) {
      useAppStore().updateRate(fast > 4 ? 5.0 : (1 + fast).toDouble());
    } else if (fast <= -1) {
      useAppStore()
          .updateRate(fast < -3 ? 0.25 : (1 - 0.25 * fast.abs()).toDouble());
    }
  }

  void onLongPressEnd(LongPressEndDetails details) {
    if (isLongPress.value) {
      useAppStore().updateRate(1.0);
    }
    isLongPress.value = false;
    isTouch.value = false;
  }

  void onLongPressCancel() {
    if (isLongPress.value) {
      useAppStore().updateRate(1.0);
    }
    isLongPress.value = false;
    isTouch.value = false;
  }

  void onPanStart(DragStartDetails details) async {
    if (isDesktop && details.kind != PointerDeviceKind.touch) {
      windowManager.startDragging();
    } else if (details.kind == PointerDeviceKind.touch) {
      isTouch.value = true;
      startPosition.value = details.globalPosition;
    }
  }

  void onPanUpdate(DragUpdateDetails details) async {
    if (isTouch.value && startPosition.value != null) {
      // 判断滑动方向
      double dx = (details.globalPosition.dx - startPosition.value!.dx).abs();
      double dy = (details.globalPosition.dy - startPosition.value!.dy).abs();
      if (!isHorizontalGesture.value && !isVerticalGesture.value) {
        if (dx > dy) {
          isHorizontalGesture.value = true;
          usePlayerUiStore().updateIsSeeking(true);
        } else {
          isVerticalGesture.value = true;
        }
      }

      // 水平滑动
      if (isHorizontalGesture.value && isSeeking) {
        double dx = details.delta.dx;
        int seconds = (dx * 2 + player.position.inSeconds).toInt();
        Duration position = Duration(
            seconds: seconds < 0
                ? 0
                : seconds > player.duration.inSeconds
                    ? player.duration.inSeconds
                    : seconds);
        player.seek(position);
        if (isShowControl) {
          showControl();
        } else {
          showProgress();
        }
      }

      // 垂直滑动
      final startDX = startPosition.value?.dx;
      if (isVerticalGesture.value && startDX != null) {
        if (!isLeftGesture.value && !isRightGesture.value) {
          if (startDX < (MediaQuery.of(context).size.width / 2)) {
            isLeftGesture.value = true;
          } else {
            isRightGesture.value = true;
          }
        }

        double dy = details.delta.dy;

        // 屏幕亮度
        if (isLeftGesture.value && brightness.value != null) {
          final newBrightness = brightness.value! - dy / 200;
          brightness.value = newBrightness > 1
              ? 1
              : newBrightness < 0
                  ? 0
                  : newBrightness;
        }

        // 音量
        if (isRightGesture.value && volume.value != null) {
          final newVolume = volume.value! - dy / 200;
          volume.value = newVolume > 1
              ? 1
              : newVolume < 0
                  ? 0
                  : newVolume;
        }
      }
    }
  }

  void onPanEnd(DragEndDetails details) async {
    isTouch.value = false;
    isHorizontalGesture.value = false;
    isVerticalGesture.value = false;
    isLeftGesture.value = false;
    isRightGesture.value = false;
    startPosition.value = null;
    if (isSeeking) {
      await player.seek(player.position);
      usePlayerUiStore().updateIsSeeking(false);
    }
  }

  void onPanCancel() async {
    isHorizontalGesture.value = false;
    isVerticalGesture.value = false;
    isLeftGesture.value = false;
    isRightGesture.value = false;
    startPosition.value = null;
    if (isSeeking) {
      isTouch.value = false;
      await player.seek(player.position);
      usePlayerUiStore().updateIsSeeking(false);
    }
  }

  void onHover(PointerHoverEvent event) {
    if (event.kind != PointerDeviceKind.touch) {
      updateIsHovering(true);
      showControl();
    }
  }

  final cursor = useMemoized(() {
    return player.isPlaying == false
        ? SystemMouseCursors.basic
        : SystemMouseCursors.none;
  }, [player.isPlaying]);

  return Gesture(
    onTapDown: onTapDown,
    onTap: onTap,
    onDoubleTapDown: onDoubleTapDown,
    onLongPressStart: onLongPressStart,
    onLongPressMoveUpdate: onLongPressMoveUpdate,
    onLongPressEnd: onLongPressEnd,
    onLongPressCancel: onLongPressCancel,
    onPanStart: onPanStart,
    onPanUpdate: onPanUpdate,
    onPanEnd: onPanEnd,
    onPanCancel: onPanCancel,
    onHover: onHover,
    isLongPress: isLongPress.value,
    isLeftGesture: isLeftGesture.value,
    isRightGesture: isRightGesture.value,
    brightness: brightness.value,
    volume: volume.value,
    cursor: cursor,
  );
}
