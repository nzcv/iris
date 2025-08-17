import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/hooks/player/use_fvp_player.dart';
import 'package:iris/hooks/player/use_media_kit_player.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/store/app_state.dart';
import 'package:iris/store/use_app_store.dart';

MediaPlayer usePlayer(BuildContext context) {
  final playerBackend =
      useAppStore().select(context, (state) => state.playerBackend);

  final mediaKitPlayer =
      useMediaKitPlayer(context, playerBackend == PlayerBackend.mediaKit);
  final fvpPlayer = useFvpPlayer(context, playerBackend == PlayerBackend.fvp);

  return fvpPlayer ?? mediaKitPlayer!;
}
