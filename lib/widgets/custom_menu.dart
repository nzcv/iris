import 'dart:math';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

Future<void> showCustomMenu(
  BuildContext context, {
  required List<Widget> items,
  double? width = 128,
}) async =>
    showPopover(
      context: context,
      bodyBuilder: (context) => SingleChildScrollView(
        child: Column(children: items),
      ),
      width: width,
      height: min(MediaQuery.of(context).size.height * 0.8,
          items.length * kMinInteractiveDimension),
      radius: 16,
      arrowHeight: 0,
      arrowWidth: 0,
      backgroundColor:
          Theme.of(context).colorScheme.surfaceDim.withValues(alpha: 0.9),
      barrierColor: Colors.transparent,
    );
