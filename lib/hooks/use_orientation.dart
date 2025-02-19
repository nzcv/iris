import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/store/app_state.dart';
import 'package:iris/store/use_app_store.dart';

void useOrientation(BuildContext context, MediaPlayer player) {
  final orientation =
      useAppStore().select(context, (state) => state.orientation);

  setOrientation(ScreenOrientation orientation, double? aspect) {
    if (Platform.isAndroid || Platform.isIOS) {
      switch (orientation) {
        case ScreenOrientation.device:
          SystemChrome.setPreferredOrientations([]);
          break;
        case ScreenOrientation.landscape:
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          break;
        case ScreenOrientation.portrait:
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          break;
      }
    }
  }

  useEffect(() {
    setOrientation(orientation, player.aspect);
    return () => SystemChrome.setPreferredOrientations([]);
  }, []);

  useEffect(() {
    setOrientation(orientation, player.aspect);
    return;
  }, [orientation, player.aspect]);
}
