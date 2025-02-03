import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/theme.dart';

class DarkTheme extends HookWidget {
  const DarkTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = getTheme(
      context: context,
      lightDynamic: ThemeData.light().colorScheme,
      darkDynamic: ThemeData.dark().colorScheme,
    );

    return Theme(
      data: theme.dark.copyWith(
          colorScheme: theme.dark.colorScheme.copyWith(
        onSurfaceVariant: Colors.white.withValues(alpha: 0.95),
      )),
      child: child,
    );
  }
}
