import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

enum DataSourceType {
  network,
  file,
  contentUri,
}

VideoPlayerController useFvp({
  required String dataSource,
  required DataSourceType dataSourceType,
  bool autoPlay = false,
  bool looping = false,
  Future<ClosedCaptionFile>? closedCaptionFile,
  VideoPlayerOptions? videoPlayerOptions,
  Map<String, String> httpHeaders = const {},
}) {
  final controller = useMemoized(
    () {
      switch (dataSourceType) {
        case DataSourceType.network:
          return VideoPlayerController.networkUrl(
            Uri.parse(dataSource),
            closedCaptionFile: closedCaptionFile,
            videoPlayerOptions: videoPlayerOptions,
            httpHeaders: httpHeaders,
          );
        case DataSourceType.file:
          return VideoPlayerController.file(
            File(dataSource),
            closedCaptionFile: closedCaptionFile,
            videoPlayerOptions: videoPlayerOptions,
          );
        case DataSourceType.contentUri:
          return VideoPlayerController.contentUri(
            Uri.parse(dataSource),
            closedCaptionFile: closedCaptionFile,
            videoPlayerOptions: videoPlayerOptions,
          );
      }
    },
    [
      dataSource,
      closedCaptionFile,
      videoPlayerOptions,
      httpHeaders,
    ],
  );

  useEffect(
    () {
      controller
        ..initialize()
        ..setLooping(looping);

      if (autoPlay) {
        controller.play();
      }

      return controller.dispose;
    },
    [
      dataSource,
      closedCaptionFile,
      videoPlayerOptions,
      httpHeaders,
    ],
  );

  final playing = useState(false);

  useEffect(() {
    controller.addListener(() {
      playing.value = controller.value.isPlaying;
    });

    return () => controller.removeListener(() {});
  }, [controller]);

  return controller;
}
