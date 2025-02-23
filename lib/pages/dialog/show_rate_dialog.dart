import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:iris/utils/get_localizations.dart';

Future<void> showRateDialog(BuildContext context) async =>
    await showDialog<void>(
      context: context,
      builder: (context) => const RateDialog(),
    );

class RateDialog extends HookWidget {
  const RateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final t = getLocalizations(context);
    final rate = useAppStore().select(context, (state) => state.rate);

    void updateRate(double rate) {
      useAppStore().updateRate(rate);
      Navigator.pop(context);
    }

    return AlertDialog(
      title: Text(t.playback_speed),
      content: SingleChildScrollView(
        child: Column(
          children: [
            0.25,
            0.5,
            0.75,
            1.0,
            1.25,
            1.5,
            1.75,
            2.0,
            3.0,
            4.0,
            5.0,
          ]
              .map(
                (item) => ListTile(
                  title: Text('${item}X'),
                  leading: Radio(
                    value: item,
                    groupValue: rate,
                    onChanged: (_) => updateRate(item),
                  ),
                  onTap: () => updateRate(item),
                ),
              )
              .toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(t.cancel),
        ),
      ],
    );
  }
}
