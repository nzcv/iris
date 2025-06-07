import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fvp/fvp.dart';
import 'package:iris/models/player.dart';
import 'package:iris/utils/get_localizations.dart';
import 'package:iris/utils/logger.dart';
import 'package:media_kit/media_kit.dart';

class AudioTrackList extends HookWidget {
  const AudioTrackList({super.key, required this.player});

  final MediaPlayer player;

  @override
  Widget build(BuildContext context) {
    final t = getLocalizations(context);

    final focusNode = useFocusNode();

    useEffect(() {
      focusNode.requestFocus();
      return () => focusNode.unfocus();
    }, []);

    if (player is MediaKitPlayer) {
      return ListView(
        children: [
          ...(player as MediaKitPlayer).audios.map(
                (audio) => ListTile(
                  focusNode: (player as MediaKitPlayer).audio == audio
                      ? focusNode
                      : null,
                  title: Text(
                    audio == AudioTrack.auto()
                        ? t.auto
                        : audio == AudioTrack.no()
                            ? t.off
                            : audio.title ?? audio.language ?? audio.id,
                    style: (player as MediaKitPlayer).audio == audio
                        ? TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                  ),
                  tileColor: (player as MediaKitPlayer).audio == audio
                      ? Theme.of(context).hoverColor
                      : null,
                  onTap: () {
                    logger(
                        'Set audio track: ${audio.title ?? audio.language ?? audio.id}');
                    (player as MediaKitPlayer).player.setAudioTrack(audio);
                    Navigator.of(context).pop();
                  },
                ),
              ),
        ],
      );
    }

    if (player is FvpPlayer) {
      final audios =
          (player as FvpPlayer).controller.getMediaInfo()?.audio ?? [];
      final activeAudioTracks =
          (player as FvpPlayer).controller.getActiveAudioTracks() ?? [];
      return ListView(
        children: [
          ListTile(
            focusNode: activeAudioTracks.isEmpty ? focusNode : null,
            title: Text(
              t.off,
              style: activeAudioTracks.isEmpty
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
            tileColor:
                activeAudioTracks.isEmpty ? Theme.of(context).hoverColor : null,
            onTap: () {
              logger('Set audio track: ${t.off}');
              (player as FvpPlayer).controller.setAudioTracks([]);
              Navigator.of(context).pop();
            },
          ),
          ...audios.map(
            (audio) => ListTile(
              focusNode: activeAudioTracks.contains(audios.indexOf(audio))
                  ? focusNode
                  : null,
              title: Text(
                audio.metadata['title'] ??
                    audio.metadata['language'] ??
                    audios.indexOf(audio).toString(),
                style: activeAudioTracks.contains(audios.indexOf(audio))
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
              tileColor: activeAudioTracks.contains(audios.indexOf(audio))
                  ? Theme.of(context).hoverColor
                  : null,
              onTap: () {
                logger(
                    'Set audio track: ${audio.metadata['title'] ?? audio.metadata['language'] ?? audios.indexOf(audio).toString()}');
                (player as FvpPlayer)
                    .controller
                    .setAudioTracks([audios.indexOf(audio)]);
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
