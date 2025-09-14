import 'dart:async';
import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/hooks/use_app_lifecycle.dart';
import 'package:iris/hooks/use_cover.dart';
import 'package:iris/hooks/use_keyboard.dart';
import 'package:iris/info.dart';
import 'package:iris/models/file.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/storages/local.dart';
import 'package:iris/pages/player/audio.dart';
import 'package:iris/pages/player/controls_overlay.dart';
import 'package:iris/pages/player/video_view.dart';
import 'package:iris/store/use_player_ui_store.dart';
import 'package:iris/utils/check_content_type.dart';
import 'package:iris/utils/logger.dart';
import 'package:iris/utils/platform.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:iris/store/use_play_queue_store.dart';
import 'package:iris/utils/get_localizations.dart';
import 'package:window_manager/window_manager.dart';

class Player extends HookWidget {
  const Player({super.key, required this.player});

  final MediaPlayer player;

  @override
  Widget build(BuildContext context) {
    final t = getLocalizations(context);

    useAppLifecycle(player.saveProgress);

    final cover = useCover(player.isPlaying);

    final playerUiStore = usePlayerUiStore();

    final isHovering =
        playerUiStore.select(context, (state) => state.isHovering);
    final isShowControl =
        playerUiStore.select(context, (state) => state.isShowControl);
    final isShowProgress =
        playerUiStore.select(context, (state) => state.isShowProgress);

    final updateIsHovering = useCallback((bool value) {
      playerUiStore.updateIsHovering(value);
    }, [playerUiStore.updateIsHovering]);

    final updateIsShowControl = useCallback((bool value) {
      playerUiStore.updateIsShowControl(value);
    }, [playerUiStore.updateIsShowControl]);

    final updateIsShowProgress = useCallback((bool value) {
      playerUiStore.updateIsShowProgress(value);
    }, [playerUiStore.updateIsShowProgress]);

    final controlHideTimer = useRef<Timer?>(null);
    final progressHideTimer = useRef<Timer?>(null);
    final systemUiHideTimer = useRef<Timer?>(null);

    final fit = useAppStore().select(context, (state) => state.fit);

    final playQueue =
        usePlayQueueStore().select(context, (state) => state.playQueue);
    final currentIndex =
        usePlayQueueStore().select(context, (state) => state.currentIndex);

    final int currentPlayIndex = useMemoized(
        () => playQueue.indexWhere((element) => element.index == currentIndex),
        [playQueue, currentIndex]);

    final PlayQueueItem? currentPlay = useMemoized(
        () => playQueue.isEmpty || currentPlayIndex < 0
            ? null
            : playQueue[currentPlayIndex],
        [playQueue, currentPlayIndex]);

    final title = useMemoized(
        () => currentPlay != null
            ? playQueue.length > 1
                ? '[${currentPlayIndex + 1}/${playQueue.length}] ${currentPlay.file.name}'
                : currentPlay.file.name
            : INFO.title,
        [currentPlay, currentPlayIndex, playQueue]);

    final focusNode = useFocusNode();

    useEffect(() {
      focusNode.requestFocus();
      return;
    }, []);

    final canPop = useState(false);

    useEffect(() {
      final timer = Future.delayed(Duration(seconds: 4), () {
        canPop.value = false;
      });
      return () {
        timer.ignore();
      };
    }, [canPop.value]);

    final startControlHideTimer = useCallback(() {
      controlHideTimer.value = Timer(
        const Duration(seconds: 5),
        () {
          if (isShowControl && !isHovering) {
            updateIsShowControl(false);
          }
        },
      );
    }, [isShowControl, isHovering, updateIsShowControl]);

    final startProgressHideTimer = useCallback(() {
      progressHideTimer.value = Timer(
        const Duration(seconds: 5),
        () {
          if (isShowProgress) {
            updateIsShowProgress(false);
          }
        },
      );
    }, [isShowProgress, updateIsShowProgress]);

    final startSystemUiHideTimer = useCallback(() {
      systemUiHideTimer.value = Timer(
        const Duration(seconds: 3),
        () {
          if (!isShowControl && currentPlay?.file.type == ContentType.video) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          }
        },
      );
    }, [isShowControl, currentPlay?.file.type]);

    final resetControlHideTimer = useCallback(() {
      controlHideTimer.value?.cancel();
      startControlHideTimer();
    }, [startControlHideTimer]);

    final resetBottomProgressTimer = useCallback(() {
      progressHideTimer.value?.cancel();
      startProgressHideTimer();
    }, [startProgressHideTimer]);

    final resetSystemUiHideTimer = useCallback(() {
      systemUiHideTimer.value?.cancel();
      startSystemUiHideTimer();
    }, [startSystemUiHideTimer]);

    final showControl = useCallback(() {
      updateIsShowControl(true);
      updateIsHovering(false);
      resetControlHideTimer();
    }, [updateIsShowControl, updateIsHovering, resetControlHideTimer]);

    final hideControl = useCallback(() {
      updateIsShowControl(false);
      updateIsHovering(false);
      controlHideTimer.value?.cancel();
    }, [updateIsShowControl, updateIsHovering]);

    final showControlForHover = useCallback((Future<void> callback) async {
      try {
        player.saveProgress();
        showControl();
        updateIsHovering(true);
        await callback;
        showControl();
      } catch (e) {
        logger(e.toString());
      }
    }, [showControl, updateIsHovering]);

    final showProgress = useCallback(() {
      updateIsShowProgress(true);
      resetBottomProgressTimer();
    }, [updateIsShowProgress, resetBottomProgressTimer]);

    final onKeyEvent = useKeyboard(
      player: player,
      showControl: showControl,
      showControlForHover: showControlForHover,
      showProgress: showProgress,
    );

    useEffect(() {
      startControlHideTimer();
      return () => controlHideTimer.value?.cancel();
    }, []);

    useEffect(() {
      return () => progressHideTimer.value?.cancel();
    }, []);

    useEffect(() {
      if (isDesktop) {
        windowManager.setTitle(title);
      }
      return;
    }, [title, player.isPlaying]);

    useEffect(() {
      if (isShowControl || currentPlay?.file.type == ContentType.video) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        systemUiHideTimer.value?.cancel();
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
      return;
    }, [isShowControl, currentPlay?.file.type]);

    useEffect(() {
      SystemChrome.setSystemUIChangeCallback((value) async {
        if (value) {
          resetSystemUiHideTimer();
        }
      });
      return null;
    }, []);

    final scaleFactor = useMemoized(
      () =>
          View.of(context).physicalSize.width /
          MediaQuery.of(context).size.width,
      [View.of(context).physicalSize.width, MediaQuery.of(context).size.width],
    );

    final videoViewSize = useMemoized(() {
      if (fit != BoxFit.none || player.width == 0 || player.height == 0) {
        return MediaQuery.of(context).size;
      } else {
        return Size(player.width! / scaleFactor, player.height! / scaleFactor);
      }
    }, [
      fit,
      MediaQuery.of(context).size,
      player.width,
      player.height,
      scaleFactor
    ]);

    final videoViewOffset = useMemoized(
        () => fit == BoxFit.none
            ? Offset(
                (MediaQuery.of(context).size.width - videoViewSize.width) / 2,
                (MediaQuery.of(context).size.height - videoViewSize.height) / 2,
              )
            : Offset(0, 0),
        [fit, MediaQuery.of(context).size, videoViewSize]);

    return DropTarget(
      onDragDone: (details) async {
        final files = details.files
            .map((file) => checkContentType(file.path) == ContentType.video ||
                    checkContentType(file.path) == ContentType.audio
                ? file.path
                : null)
            .where((element) => element != null)
            .toList() as List<String>;
        if (files.isNotEmpty) {
          final firstFile = files[0];
          if (firstFile.isEmpty) return;
          final playQueue = await getLocalPlayQueue(firstFile);
          if (playQueue == null || playQueue.playQueue.isEmpty) return;
          final List<PlayQueueItem> filteredPlayQueue = [];
          for (final item in playQueue.playQueue) {
            final file = item.file;
            if (files.contains(file.uri)) {
              filteredPlayQueue.add(item);
            }
          }
          if (filteredPlayQueue.isEmpty) return;
          useAppStore().updateAutoPlay(true);
          usePlayQueueStore().update(
              playQueue: filteredPlayQueue, index: playQueue.currentIndex);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (!didPop) {
            await player.saveProgress();
            if (!canPop.value) {
              canPop.value = true;
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.exit_app_back_again)),
                );
              }
            } else {
              exit(0);
            }
          }
        },
        child: KeyboardListener(
          focusNode: focusNode,
          onKeyEvent: onKeyEvent,
          child: Stack(
            children: [
              // Video
              Positioned(
                left: videoViewOffset.dx,
                top: videoViewOffset.dy,
                width: videoViewSize.width,
                height: videoViewSize.height,
                child: VideoView(
                  key: ValueKey(currentPlay?.file.uri),
                  player: player,
                  fit: fit,
                ),
              ),
              // Audio
              if (currentPlay?.file.type == ContentType.audio)
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Audio(cover: cover),
                ),
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: ControlsOverlay(
                  player: player,
                  currentPlay: currentPlay,
                  title: title,
                  showControl: showControl,
                  showControlForHover: showControlForHover,
                  hideControl: hideControl,
                  showProgress: showProgress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
