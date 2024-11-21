import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/info.dart';
import 'package:iris/pages/home_page.dart';
import 'package:iris/pages/settings_page.dart';
import 'package:iris/pages/video_page.dart';
import 'package:iris/pages/files_page.dart';
import 'package:iris/utils/is_desktop.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  if (isDesktop()) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: const Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: INFO.title,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const StoreScope(child: MyApp()));
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title: INFO.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
      routes: {
        // '/video': (BuildContext context) => const VideoPage(),
        '/settings': (BuildContext context) => const SettingsPage(),
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/files':
            final args = settings.arguments as FilesPageArguments;
            return MaterialPageRoute(
              builder: (BuildContext context) => FilesPage(
                storage: args.storage,
              ),
            );
          case '/video':
            final args = settings.arguments as VideoPageArguments;
            return MaterialPageRoute(
              builder: (BuildContext context) => VideoPage(
                playQueue: args.playQueue,
                index: args.index,
              ),
            );
        }
        return null;
      },
    );
  }
}
