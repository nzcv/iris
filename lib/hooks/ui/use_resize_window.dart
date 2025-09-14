import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:iris/store/use_player_ui_store.dart';
import 'package:iris/utils/platform.dart';
import 'package:iris/utils/resize_window.dart';

void useResizeWindow() {
  final context = useContext();

  final autoResize = useAppStore().select(context, (state) => state.autoResize);
  final aspectRatio =
      usePlayerUiStore().select(context, (state) => state.aspectRatio);

  useEffect(() {
    if (isDesktop) {
      resizeWindow(!autoResize ? 0 : aspectRatio);
    }
    return;
  }, [aspectRatio, autoResize]);
}
