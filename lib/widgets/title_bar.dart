import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/info.dart';
import 'package:iris/store/app_store.dart';
import 'package:iris/utils/is_desktop.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends HookWidget implements PreferredSizeWidget {
  const TitleBar(
      {super.key,
      required this.title,
      this.bgColor,
      this.textColor,
      this.iconColor});
  final String title;
  final Color? bgColor;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: bgColor ?? Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    final inHome =
        useMemoized(() => ModalRoute.of(context)?.settings.name == '/');

    final isMaximized = useState(false);

    useEffect(() {
      final subscription = useAppStore().stream.listen((state) {
        isMaximized.value = state.isMaximized;
      });
      return subscription.cancel;
    }, []);

    useEffect(() {
      if (isDesktop()) {
        if (isMaximized.value) {
          windowManager.maximize();
        } else {
          windowManager.unmaximize();
        }
      }
      return null;
    }, [isMaximized.value]);

    return GestureDetector(
        onPanStart: (details) {
          if (isDesktop()) {
            windowManager.startDragging();
          }
        },
        onDoubleTap: () {
          if (isDesktop()) {
            () => useAppStore().toggleMaximize();
          }
        },
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: isDesktop() ? null : 64,
            color: bgColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!inHome)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: iconColor),
                    onPressed: () {
                      Navigator.pop(context);
                      if (isDesktop()) {
                        windowManager.setTitle(INFO.title);
                      }
                    },
                  ),
                if (inHome) const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        decoration: TextDecoration.none),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                inHome
                    ? IconButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/settings'),
                        icon: const Icon(Icons.settings),
                      )
                    : const SizedBox(),
                const SizedBox(width: 10),
                isDesktop()
                    ? Row(children: [
                        IconButton(
                          onPressed: () => windowManager.minimize(),
                          icon: Icon(Icons.minimize, color: iconColor),
                        ),
                        IconButton(
                          onPressed: () async =>
                              await windowManager.isFullScreen()
                                  ? windowManager.setFullScreen(false)
                                  : useAppStore().toggleMaximize(),
                          icon: isMaximized.value == true
                              ? Icon(Icons.fullscreen_exit, color: iconColor)
                              : Icon(Icons.fullscreen, color: iconColor),
                        ),
                        IconButton(
                          onPressed: () => windowManager.close(),
                          icon: Icon(Icons.close, color: iconColor),
                        ),
                      ])
                    : const SizedBox(),
              ],
            ),
          ),
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
