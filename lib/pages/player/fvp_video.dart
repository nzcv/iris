import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/hooks/use_fvp.dart';
import 'package:iris/models/file.dart';
import 'package:iris/utils/check_data_source_type.dart';
import 'package:video_player/video_player.dart';

class FvpVideo extends HookWidget {
  const FvpVideo({
    super.key,
    required this.file,
    this.autoPlay = false,
    this.looping = false,
    this.fit = BoxFit.contain,
  });

  final FileItem file;
  final bool autoPlay;
  final bool looping;
  final BoxFit fit;

  @override
  Widget build(context) {
    final controller = useFvp(
      dataSource: file.uri,
      dataSourceType: checkDataSourceType(file),
      httpHeaders: file.auth != null ? {'authorization': file.auth!} : {},
      autoPlay: autoPlay,
      looping: looping,
    );

    return FittedBox(
      fit: fit,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
