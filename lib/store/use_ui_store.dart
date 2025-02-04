import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/models/store/ui_state.dart';
import 'package:iris/utils/is_desktop.dart';
import 'package:window_manager/window_manager.dart';

class UiStore extends Store<UiState> {
  UiStore() : super(const UiState());

  Future<void> toggleIsAlwaysOnTop() async {
    if (isDesktop) {
      windowManager.setAlwaysOnTop(!state.isAlwaysOnTop);
      set(state.copyWith(isAlwaysOnTop: !state.isAlwaysOnTop));
    }
  }
}

UiStore useUiStore() => create(() => UiStore());
