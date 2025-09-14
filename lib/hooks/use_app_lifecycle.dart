import 'dart:ui';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/utils/logger.dart';

void useAppLifecycle(
  Future<void> Function() saveProgress,
) {
  AppLifecycleState? appLifecycleState = useAppLifecycleState();

  useEffect(() {
    try {
      if (appLifecycleState == AppLifecycleState.paused) {
        logger('App lifecycle state: paused');
        saveProgress();
      }
    } catch (e) {
      logger('App lifecycle state error: $e');
    }
    return;
  }, [appLifecycleState]);
}
