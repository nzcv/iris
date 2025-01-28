import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:fvp/fvp.dart';
import 'package:iris/models/file.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/progress.dart';
import 'package:iris/models/store/app_state.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:iris/store/use_history_store.dart';
import 'package:iris/store/use_play_queue_store.dart';
import 'package:iris/utils/check_data_source_type.dart';
import 'package:iris/utils/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

FvpPlayer useFvpPlayer(BuildContext context) {
  final autoPlay = useAppStore().select(context, (state) => state.autoPlay);
  final repeat = useAppStore().select(context, (state) => state.repeat);
  final playQueue =
      usePlayQueueStore().select(context, (state) => state.playQueue);
  final currentIndex =
      usePlayQueueStore().select(context, (state) => state.currentIndex);
  final bool alwaysPlayFromBeginning =
      useAppStore().select(context, (state) => state.alwaysPlayFromBeginning);

  final history = useHistoryStore().select(context, (state) => state.history);

  final looping =
      useMemoized(() => repeat == Repeat.one ? true : false, [repeat]);

  final int currentPlayIndex = useMemoized(
      () => playQueue.indexWhere((element) => element.index == currentIndex),
      [playQueue, currentIndex]);

  final PlayQueueItem? currentPlay = useMemoized(
      () => playQueue.isEmpty || currentPlayIndex < 0
          ? null
          : playQueue[currentPlayIndex],
      [playQueue, currentPlayIndex]);

  final file = useMemoized(() => currentPlay?.file, [currentPlay]);

  final controller = useMemoized(() {
    if (file == null) return VideoPlayerController.networkUrl(Uri.parse(''));
    switch (checkDataSourceType(file)) {
      case DataSourceType.network:
        return VideoPlayerController.networkUrl(
          Uri.parse(file.uri),
          httpHeaders: file.auth != null ? {'authorization': file.auth!} : {},
        );
      case DataSourceType.file:
        return VideoPlayerController.file(
          File(file.uri),
          httpHeaders: file.auth != null ? {'authorization': file.auth!} : {},
        );
      case DataSourceType.contentUri:
        return VideoPlayerController.contentUri(
          Uri.parse(file.uri),
        );
      default:
        return VideoPlayerController.networkUrl(
          Uri.parse(file.uri),
          httpHeaders: file.auth != null ? {'authorization': file.auth!} : {},
        );
    }
  }, [file]);

  final isPlaying = useState(false);
  final externalSubtitle = useState<int?>(null);
  final List<Subtitle> externalSubtitles = useMemoized(
      () => currentPlay?.file.subtitles ?? [], [currentPlay?.file.subtitles]);
  final position = useState(controller.value.position);
  final duration = useState(controller.value.duration);
  final buffered = useState(controller.value.buffered);
  final width = useState(controller.value.size.width);
  final height = useState(controller.value.size.height);
  final double aspect = useMemoized(
      () => width.value != 0 && height.value != 0
          ? width.value / height.value
          : 0,
      [width.value, height.value]);
  final rate = useState(controller.value.playbackSpeed);
  final seeking = useState(false);

  void updateSeeking(bool value) => seeking.value = value;

  useEffect(() {
    () async {
      if (controller.dataSource.isEmpty) return;
      await controller.initialize();

      if (currentPlay != null &&
          currentPlay.file.type == ContentType.video &&
          duration.value != Duration.zero) {
        Progress? progress = history[currentPlay.file.getID()];
        if (progress != null) {
          if (!alwaysPlayFromBeginning &&
              progress.duration.inMilliseconds ==
                  duration.value.inMilliseconds &&
              (progress.duration.inMilliseconds -
                      progress.position.inMilliseconds) >
                  5000) {
            logger(
                'Resume progress: ${currentPlay.file.name} position: ${progress.position} duration: ${progress.duration}');
            await controller.seekTo(progress.position);
          }
        }
      }

      if (externalSubtitles.isNotEmpty) {
        externalSubtitle.value = 0;
        controller.setExternalSubtitle(externalSubtitles[0].uri);
      }

      await controller.setLooping(repeat == Repeat.one ? true : false);

      if (autoPlay) {
        await controller.play();
      }
    }();

    return () {
      controller.pause();
      controller.dispose();
    };
  }, [controller]);

  useEffect(() {
    controller.addListener(() async {
      isPlaying.value = controller.value.isPlaying;
      position.value = controller.value.position;
      duration.value = controller.value.duration;
      buffered.value = controller.value.buffered;
      width.value = controller.value.size.width;
      height.value = controller.value.size.height;
      rate.value = controller.value.playbackSpeed;

      if (controller.value.isCompleted) {
        if (repeat == Repeat.one) return;
        if (currentPlayIndex == playQueue.length - 1) {
          if (repeat == Repeat.all) {
            await usePlayQueueStore().updateCurrentIndex(playQueue[0].index);
          }
        } else {
          await usePlayQueueStore()
              .updateCurrentIndex(playQueue[currentPlayIndex + 1].index);
        }
      }
    });

    return () {
      position.value = Duration.zero;
      duration.value = Duration.zero;
      buffered.value = [];
      width.value = 0;
      height.value = 0;
      rate.value = 1;
      controller.removeListener(() {});
    };
  }, [controller]);

  useEffect(() {
    if (controller.value.isInitialized) {
      logger('Set looping: $looping');
      controller.setLooping(repeat == Repeat.one ? true : false);
    }
    return;
  }, [looping]);

  useEffect(() {
    return () {
      if (currentPlay != null &&
          controller.value.isInitialized &&
          controller.value.duration.inSeconds != 0) {
        if (Platform.isAndroid &&
            currentPlay.file.uri.startsWith('content://')) {
          return;
        }
        logger('Save progress: ${currentPlay.file.name}');
        useHistoryStore().add(Progress(
          dateTime: DateTime.now().toUtc(),
          position: controller.value.position,
          duration: controller.value.duration,
          file: currentPlay.file,
        ));
      }
    };
  }, [currentPlay?.file]);

  useEffect(() {
    if (isPlaying.value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    return;
  }, [isPlaying.value]);

  Future<void> play() async {
    await useAppStore().updateAutoPlay(true);
    controller.play();
  }

  Future<void> pause() async => controller.pause();

  Future<void> seekTo(Duration newPosition) async => newPosition.inSeconds < 0
      ? await controller.seekTo(Duration.zero)
      : newPosition.inSeconds > duration.value.inSeconds
          ? await controller.seekTo(duration.value)
          : await controller.seekTo(newPosition);

  Future<void> saveProgress() async {
    if (file != null && duration.value != Duration.zero) {
      if (Platform.isAndroid && file.uri.startsWith('content://')) {
        return;
      }
      logger('Save progress: ${file.name}');
      useHistoryStore().add(Progress(
        dateTime: DateTime.now().toUtc(),
        position: controller.value.position,
        duration: controller.value.duration,
        file: file,
      ));
    }
  }

  return FvpPlayer(
    controller: controller,
    isPlaying: isPlaying.value,
    externalSubtitle: externalSubtitle,
    externalSubtitles: externalSubtitles,
    position: position.value,
    duration: duration.value,
    buffer: buffered.value.isEmpty ? Duration.zero : buffered.value.last.end,
    aspect: aspect,
    width: width.value,
    height: height.value,
    rate: rate.value,
    play: play,
    pause: pause,
    backward: (seconds) =>
        seekTo(Duration(seconds: position.value.inSeconds - seconds)),
    forward: (seconds) =>
        seekTo(Duration(seconds: position.value.inSeconds + seconds)),
    updateRate: (value) => controller.setPlaybackSpeed(value),
    seekTo: seekTo,
    saveProgress: saveProgress,
    seeking: seeking.value,
    updatePosition: seekTo,
    updateSeeking: updateSeeking,
  );
}
