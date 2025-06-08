import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:fvp/fvp.dart';
import 'package:iris/models/file.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/storages/storage.dart';
import 'package:iris/store/use_play_queue_store.dart';
import 'package:iris/utils/get_localizations.dart';
import 'package:iris/utils/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_stream/media_stream.dart';

class SubtitleList extends HookWidget {
  const SubtitleList({super.key, required this.player});

  final MediaPlayer player;

  @override
  Widget build(BuildContext context) {
    final t = getLocalizations(context);

    final focusNode = useFocusNode();

    MediaStream mediaStream = MediaStream();
    final streamUrl = mediaStream.url;

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

    useEffect(() {
      focusNode.requestFocus();
      return () => focusNode.unfocus();
    }, []);

    if (player is MediaKitPlayer) {
      return ListView(
        children: [
          ...(player as MediaKitPlayer).subtitles.map(
                (subtitle) => ListTile(
                  focusNode: (player as MediaKitPlayer).subtitle == subtitle
                      ? focusNode
                      : null,
                  title: Text(
                    subtitle == SubtitleTrack.no()
                        ? t.off
                        : subtitle.title ?? subtitle.language ?? subtitle.id,
                    style: (player as MediaKitPlayer).subtitle == subtitle
                        ? TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                  ),
                  tileColor: (player as MediaKitPlayer).subtitle == subtitle
                      ? Theme.of(context).hoverColor
                      : null,
                  onTap: () {
                    logger(
                        'Set subtitle: ${subtitle.title ?? subtitle.language ?? subtitle.id}');
                    (player as MediaKitPlayer)
                        .player
                        .setSubtitleTrack(subtitle);
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ...(player as MediaKitPlayer).externalSubtitles.map(
                (subtitle) => ListTile(
                  title: Text(
                    subtitle.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    logger('Set external subtitle: $subtitle');
                    final uri = currentPlay?.file.storageType == StorageType.ftp
                        ? '$streamUrl/${subtitle.uri}'
                        : subtitle.uri;
                    logger('External subtitle uri: $uri');
                    (player as MediaKitPlayer).player.setSubtitleTrack(
                          SubtitleTrack.uri(
                            uri,
                            title: subtitle.name,
                          ),
                        );
                    Navigator.of(context).pop();
                  },
                ),
              ),
        ],
      );
    }

    if (player is FvpPlayer) {
      final subtitles =
          (player as FvpPlayer).controller.getMediaInfo()?.subtitle ?? [];
      final activeSubtitles =
          (player as FvpPlayer).controller.getActiveSubtitleTracks() ?? [];
      return ListView(
        children: [
          ListTile(
            focusNode: (player as FvpPlayer).externalSubtitle.value == null &&
                    activeSubtitles.isEmpty
                ? focusNode
                : null,
            title: Text(
              t.off,
              style: (player as FvpPlayer).externalSubtitle.value == null &&
                      activeSubtitles.isEmpty
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
            tileColor: (player as FvpPlayer).externalSubtitle.value == null &&
                    activeSubtitles.isEmpty
                ? Theme.of(context).hoverColor
                : null,
            onTap: () {
              logger('Set subtitle: ${t.off}');
              (player as FvpPlayer).externalSubtitle.value = null;
              (player as FvpPlayer).controller.setSubtitleTracks([]);
              Navigator.of(context).pop();
            },
          ),
          ...subtitles.map(
            (subtitle) => ListTile(
              focusNode: (player as FvpPlayer).externalSubtitle.value == null &&
                      activeSubtitles.contains(subtitles.indexOf(subtitle))
                  ? focusNode
                  : null,
              title: Text(
                subtitle.metadata['title'] ??
                    subtitle.metadata['language'] ??
                    subtitle.index.toString(),
                style: (player as FvpPlayer).externalSubtitle.value == null &&
                        activeSubtitles.contains(subtitles.indexOf(subtitle))
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
              tileColor: (player as FvpPlayer).externalSubtitle.value == null &&
                      activeSubtitles.contains(subtitles.indexOf(subtitle))
                  ? Theme.of(context).hoverColor
                  : null,
              onTap: () {
                logger(
                    'Set subtitle: ${subtitle.metadata['title'] ?? subtitle.metadata['language'] ?? subtitle.index.toString()}');
                (player as FvpPlayer).externalSubtitle.value = null;
                (player as FvpPlayer)
                    .controller
                    .setSubtitleTracks([subtitles.indexOf(subtitle)]);
                Navigator.of(context).pop();
              },
            ),
          ),
          ...(player as FvpPlayer).externalSubtitles.map(
                (subtitle) => ListTile(
                  focusNode: (player as FvpPlayer).externalSubtitle.value ==
                          (player as FvpPlayer)
                              .externalSubtitles
                              .indexOf(subtitle)
                      ? focusNode
                      : null,
                  title: (player as FvpPlayer).externalSubtitle.value ==
                          (player as FvpPlayer)
                              .externalSubtitles
                              .indexOf(subtitle)
                      ? Text(
                          subtitle.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        )
                      : Text(
                          subtitle.name,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                  tileColor: (player as FvpPlayer).externalSubtitle.value ==
                          (player as FvpPlayer)
                              .externalSubtitles
                              .indexOf(subtitle)
                      ? Theme.of(context).hoverColor
                      : null,
                  onTap: () {
                    logger('Set external subtitle: $subtitle');
                    (player as FvpPlayer).externalSubtitle.value =
                        (player as FvpPlayer)
                            .externalSubtitles
                            .indexOf(subtitle);
                    Navigator.of(context).pop();
                  },
                ),
              ),
        ],
      );
    }

    return Container();
  }
}
