import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/store/use_app_store.dart';

class VolumeSlider extends HookWidget {
  const VolumeSlider({super.key, required this.showControl});

  final void Function() showControl;

  @override
  Widget build(BuildContext context) {
    final volume = useAppStore().select(context, (state) => state.volume);
    final isMuted = useAppStore().select(context, (state) => state.isMuted);

    return SizedBox(
      width: 128,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbColor: Theme.of(context).colorScheme.onSurfaceVariant,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 5.6,
          ),
          disabledThumbColor:
              Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(222),
          overlayShape: const RoundSliderOverlayShape(
            overlayRadius: 4,
          ),
          activeTrackColor: Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveTrackColor:
              Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(99),
          trackHeight: 3.6,
        ),
        child: Slider(
          value: isMuted ? 0 : volume.toDouble(),
          onChanged: (value) {
            showControl();
            useAppStore().updateMute(false);
            useAppStore().updateVolume((value).toInt());
          },
          min: 0,
          max: 100,
          activeColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
