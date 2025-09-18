import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/models/store/player_ui_state.dart';
import 'package:iris/utils/platform.dart';
import 'package:window_manager/window_manager.dart';

class PlayerUiStore extends Store<PlayerUiState> {
  PlayerUiStore() : super(const PlayerUiState());

  void updateAspectRatio(double ratio) {
    set(state.copyWith(aspectRatio: ratio));
  }

  Future<void> toggleIsAlwaysOnTop() async {
    if (isDesktop) {
      windowManager.setAlwaysOnTop(!state.isAlwaysOnTop);
      set(state.copyWith(isAlwaysOnTop: !state.isAlwaysOnTop));
    }
  }

  Future<void> updateFullScreen(bool bool) async {
    if (isDesktop) {
      windowManager.setFullScreen(!state.isFullScreen);
      set(state.copyWith(isFullScreen: !state.isFullScreen));
    }
  }

  void updateIsSeeking(bool bool) {
    set(state.copyWith(isSeeking: bool));
  }

  void updateIsHovering(bool bool) {
    set(state.copyWith(isHovering: bool));
  }

  void updateIsShowControl(bool bool) {
    set(state.copyWith(isShowControl: bool));
  }

  void updateIsShowProgress(bool bool) {
    set(state.copyWith(isShowProgress: bool));
  }
}

PlayerUiStore usePlayerUiStore() => create(() => PlayerUiStore());
