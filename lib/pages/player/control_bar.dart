import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/storages/local.dart';
import 'package:iris/models/store/app_state.dart';
import 'package:iris/pages/dialog/show_open_link_dialog.dart';
import 'package:iris/pages/dialog/show_rate_dialog.dart';
import 'package:iris/pages/player/control_bar_slider.dart';
import 'package:iris/pages/history.dart';
import 'package:iris/pages/show_open_link_bottom_sheet.dart';
import 'package:iris/pages/settings/settings.dart';
import 'package:iris/pages/player/volume_control.dart';
import 'package:iris/pages/subtitle_and_audio_track.dart';
import 'package:iris/store/use_app_store.dart';
import 'package:iris/store/use_play_queue_store.dart';
import 'package:iris/utils/get_localizations.dart';
import 'package:iris/pages/play_queue.dart';
import 'package:iris/utils/platform.dart';
import 'package:iris/utils/resize_window.dart';
import 'package:iris/widgets/dark_theme.dart';
import 'package:iris/widgets/popup.dart';
import 'package:iris/pages/storage/storages.dart';
import 'package:iris/widgets/custom_menu.dart';
import 'package:window_manager/window_manager.dart';

class ControlBar extends HookWidget {
  const ControlBar({
    super.key,
    required this.player,
    required this.showControl,
    required this.showControlForHover,
  });

  final MediaPlayer player;
  final void Function() showControl;
  final Future<void> Function(Future<void> callback) showControlForHover;

  @override
  Widget build(BuildContext context) {
    final t = getLocalizations(context);

    final rate = useAppStore().select(context, (state) => state.rate);
    final volume = useAppStore().select(context, (state) => state.volume);
    final isMuted = useAppStore().select(context, (state) => state.isMuted);
    final int playQueueLength =
        usePlayQueueStore().select(context, (state) => state.playQueue.length);
    final playQueue =
        usePlayQueueStore().select(context, (state) => state.playQueue);
    final currentIndex =
        usePlayQueueStore().select(context, (state) => state.currentIndex);
    final currentPlayIndex = useMemoized(
        () => playQueue.indexWhere((element) => element.index == currentIndex),
        [playQueue, currentIndex]);

    final bool shuffle =
        useAppStore().select(context, (state) => state.shuffle);
    final Repeat repeat =
        useAppStore().select(context, (state) => state.repeat);
    final BoxFit fit = useAppStore().select(context, (state) => state.fit);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black87.withValues(alpha: 0),
            Colors.black87.withValues(alpha: 0.3),
            Colors.black87.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible: MediaQuery.of(context).size.width < 1024 || !isDesktop,
              child: DarkTheme(
                child: ControlBarSlider(
                  player: player,
                  showControl: showControl,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                if (playQueueLength > 1)
                  DarkTheme(
                    child: IconButton(
                      tooltip: '${t.previous} ( Ctrl + ← )',
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        size: 28,
                      ),
                      onPressed: currentPlayIndex == 0
                          ? null
                          : () {
                              showControl();
                              usePlayQueueStore().previous();
                            },
                    ),
                  ),
                DarkTheme(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        tooltip:
                            '${player.isPlaying == true ? t.pause : t.play} ( Space )',
                        icon: Icon(
                          player.isPlaying == true
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 36,
                        ),
                        onPressed: () {
                          showControl();
                          if (player.isPlaying == true) {
                            player.pause();
                          } else {
                            player.play();
                          }
                        },
                      ),
                      if (player.isInitializing)
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                    ],
                  ),
                ),
                if (playQueueLength > 1)
                  DarkTheme(
                    child: IconButton(
                      tooltip: '${t.next} ( Ctrl + → )',
                      icon: Icon(
                        Icons.skip_next_rounded,
                        size: 28,
                      ),
                      onPressed: currentPlayIndex == playQueueLength - 1
                          ? null
                          : () {
                              showControl();
                              usePlayQueueStore().next();
                            },
                    ),
                  ),
                if (MediaQuery.of(context).size.width >= 768)
                  DarkTheme(
                    child: Builder(
                      builder: (context) => IconButton(
                        tooltip:
                            '${t.shuffle}: ${shuffle ? t.on : t.off} ( Ctrl + X )',
                        icon: Icon(
                          Icons.shuffle_rounded,
                          size: 20,
                          color: !shuffle
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          showControl();
                          shuffle
                              ? usePlayQueueStore().sort()
                              : usePlayQueueStore().shuffle();
                          useAppStore().updateShuffle(!shuffle);
                        },
                      ),
                    ),
                  ),
                if (MediaQuery.of(context).size.width >= 768)
                  DarkTheme(
                    child: Builder(
                      builder: (context) => IconButton(
                        tooltip:
                            '${repeat == Repeat.one ? t.repeat_one : repeat == Repeat.all ? t.repeat_all : t.repeat_none} ( Ctrl + R )',
                        icon: Icon(
                          repeat == Repeat.one
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          size: 20,
                          color: repeat == Repeat.none
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          showControl();
                          useAppStore().toggleRepeat();
                        },
                      ),
                    ),
                  ),
                if (MediaQuery.of(context).size.width >= 768)
                  DarkTheme(
                    child: IconButton(
                      tooltip:
                          '${t.video_zoom}: ${fit == BoxFit.contain ? t.fit : fit == BoxFit.fill ? t.stretch : fit == BoxFit.cover ? t.crop : '100%'} ( Ctrl + V )',
                      icon: Icon(
                        fit == BoxFit.contain
                            ? Icons.fit_screen_rounded
                            : fit == BoxFit.fill
                                ? Icons.aspect_ratio_rounded
                                : fit == BoxFit.cover
                                    ? Icons.crop_landscape_rounded
                                    : Icons.crop_free_rounded,
                        size: 20,
                      ),
                      onPressed: () {
                        showControl();
                        useAppStore().toggleFit();
                      },
                    ),
                  ),
                if (MediaQuery.of(context).size.width > 600)
                  Builder(
                    builder: (context) => DarkTheme(
                      child: Tooltip(
                        message: t.playback_speed,
                        child: TextButton(
                          child: Text(
                            '${rate}X',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          onPressed: () => showControlForHover(
                            showCustomMenu(
                              context,
                              items: [
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
                                    (item) => PopupMenuItem(
                                      child: Text(
                                        '${item}X',
                                        style: TextStyle(
                                          color: item == rate
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : null,
                                          fontWeight: item == rate
                                              ? FontWeight.bold
                                              : FontWeight.w100,
                                        ),
                                      ),
                                      onTap: () async {
                                        showControl();
                                        useAppStore().updateRate(item);
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (MediaQuery.of(context).size.width < 600)
                  Builder(
                    builder: (context) => DarkTheme(
                      child: IconButton(
                        tooltip: '${t.volume}: $volume',
                        icon: Icon(
                          isMuted || volume == 0
                              ? Icons.volume_off_rounded
                              : volume < 50
                                  ? Icons.volume_down_rounded
                                  : Icons.volume_up_rounded,
                          size: 20,
                        ),
                        onPressed: () => showControlForHover(
                          showVolumePopover(context, showControl),
                        ),
                      ),
                    ),
                  ),
                if (MediaQuery.of(context).size.width >= 600)
                  DarkTheme(
                    child: SizedBox(
                      width: 160,
                      child: VolumeControl(
                        showControl: showControl,
                        showVolumeText: false,
                      ),
                    ),
                  ),
                Expanded(
                  child: Visibility(
                    visible:
                        MediaQuery.of(context).size.width >= 1024 && isDesktop,
                    child: DarkTheme(
                      child: ControlBarSlider(
                        player: player,
                        showControl: showControl,
                      ),
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width >= 420)
                  DarkTheme(
                    child: IconButton(
                      tooltip: '${t.subtitle_and_audio_track} ( S )',
                      icon: const Icon(
                        Icons.subtitles_rounded,
                        size: 20,
                      ),
                      onPressed: () async {
                        showControlForHover(
                          showPopup(
                            context: context,
                            child: SubtitleAndAudioTrack(player: player),
                            direction: PopupDirection.right,
                          ),
                        );
                      },
                    ),
                  ),
                DarkTheme(
                  child: IconButton(
                    tooltip: '${t.play_queue} ( P )',
                    icon: Transform.translate(
                      offset: const Offset(0, 1.5),
                      child: const Icon(
                        Icons.playlist_play_rounded,
                        size: 28,
                      ),
                    ),
                    onPressed: () async {
                      showControlForHover(
                        showPopup(
                          context: context,
                          child: const PlayQueue(),
                          direction: PopupDirection.right,
                        ),
                      );
                    },
                  ),
                ),
                DarkTheme(
                  child: IconButton(
                    tooltip: '${t.storage} ( F )',
                    icon: const Icon(
                      Icons.storage_rounded,
                      size: 18,
                    ),
                    onPressed: () => showControlForHover(
                      showPopup(
                        context: context,
                        child: const Storages(),
                        direction: PopupDirection.right,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isDesktop,
                  child: DarkTheme(
                    child: FutureBuilder<bool>(
                      future: () async {
                        return (isDesktop &&
                            await windowManager.isFullScreen());
                      }(),
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        final isFullScreen = snapshot.data ?? false;
                        return IconButton(
                          tooltip: isFullScreen
                              ? '${t.exit_fullscreen} ( Escape, F11, Enter )'
                              : '${t.enter_fullscreen} ( F11, Enter )',
                          icon: Icon(
                            isFullScreen
                                ? Icons.close_fullscreen_rounded
                                : Icons.open_in_full_rounded,
                            size: 19,
                          ),
                          onPressed: () async {
                            showControl();
                            if (isFullScreen) {
                              await windowManager.setFullScreen(false);
                              await resizeWindow(player.aspect);
                            } else {
                              await windowManager.setFullScreen(true);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
                TooltipTheme(
                  data: TooltipThemeData(
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  child: PopupMenuButton(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                    ),
                    iconColor: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.surface,
                    clipBehavior: Clip.hardEdge,
                    constraints: const BoxConstraints(minWidth: 200),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: ListTile(
                          mouseCursor: SystemMouseCursors.click,
                          leading: const Icon(
                            Icons.file_open_rounded,
                            size: 16.5,
                          ),
                          title: Text(t.open_file),
                          trailing: Text(
                            'Ctrl + O',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        onTap: () async {
                          showControl();
                          if (isDesktop) {
                            await pickLocalFile();
                          }
                          if (Platform.isAndroid) {
                            await pickAndroidFile();
                          }
                          showControl();
                        },
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          mouseCursor: SystemMouseCursors.click,
                          leading: const Icon(
                            Icons.file_present_rounded,
                            size: 16.5,
                          ),
                          title: Text(t.open_link),
                          trailing: Text(
                            'Ctrl + L',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        onTap: () async {
                          isDesktop
                              ? await showOpenLinkDialog(context)
                              : await showOpenLinkBottomSheet(context);
                          showControl();
                        },
                      ),
                      if (MediaQuery.of(context).size.width < 768)
                        PopupMenuItem(
                          child: ListTile(
                            mouseCursor: SystemMouseCursors.click,
                            leading: Icon(
                              Icons.shuffle_rounded,
                              size: 20,
                              color: !shuffle
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            title:
                                Text('${t.shuffle}: ${shuffle ? t.on : t.off}'),
                            trailing: Text(
                              'Ctrl + X',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          onTap: () {
                            showControl();
                            shuffle
                                ? usePlayQueueStore().sort()
                                : usePlayQueueStore().shuffle();
                            useAppStore().updateShuffle(!shuffle);
                          },
                        ),
                      if (MediaQuery.of(context).size.width < 768)
                        PopupMenuItem(
                          child: ListTile(
                            mouseCursor: SystemMouseCursors.click,
                            leading: Icon(
                              repeat == Repeat.one
                                  ? Icons.repeat_one_rounded
                                  : Icons.repeat_rounded,
                              size: 20,
                              color: repeat == Repeat.none
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            title: Text(repeat == Repeat.one
                                ? t.repeat_one
                                : repeat == Repeat.all
                                    ? t.repeat_all
                                    : t.repeat_none),
                            trailing: Text(
                              'Ctrl + R',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          onTap: () {
                            showControl();
                            useAppStore().toggleRepeat();
                          },
                        ),
                      if (MediaQuery.of(context).size.width < 768)
                        PopupMenuItem(
                          child: ListTile(
                            mouseCursor: SystemMouseCursors.click,
                            leading: Icon(
                              fit == BoxFit.contain
                                  ? Icons.fit_screen_rounded
                                  : fit == BoxFit.fill
                                      ? Icons.aspect_ratio_rounded
                                      : fit == BoxFit.cover
                                          ? Icons.crop_landscape_rounded
                                          : Icons.crop_free_rounded,
                              size: 20,
                            ),
                            title: Text(
                                '${t.video_zoom}: ${fit == BoxFit.contain ? t.fit : fit == BoxFit.fill ? t.stretch : fit == BoxFit.cover ? t.crop : '100%'}'),
                            trailing: Text(
                              'Ctrl + V',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          onTap: () {
                            showControl();
                            useAppStore().toggleFit();
                          },
                        ),
                      if (MediaQuery.of(context).size.width <= 460)
                        PopupMenuItem(
                          child: ListTile(
                            mouseCursor: SystemMouseCursors.click,
                            leading: const Icon(
                              Icons.speed_rounded,
                              size: 20,
                            ),
                            title: Text('${t.playback_speed}: ${rate}X'),
                          ),
                          onTap: () =>
                              showControlForHover(showRateDialog(context)),
                        ),
                      if (MediaQuery.of(context).size.width < 420)
                        PopupMenuItem(
                          child: ListTile(
                            mouseCursor: SystemMouseCursors.click,
                            leading: const Icon(
                              Icons.subtitles_rounded,
                              size: 20,
                            ),
                            title: Text(t.subtitle_and_audio_track),
                            trailing: Text(
                              'S',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          onTap: () => showControlForHover(
                            showPopup(
                              context: context,
                              child: SubtitleAndAudioTrack(player: player),
                              direction: PopupDirection.right,
                            ),
                          ),
                        ),
                      PopupMenuItem(
                        child: ListTile(
                          mouseCursor: SystemMouseCursors.click,
                          leading: const Icon(
                            Icons.history_rounded,
                            size: 20,
                          ),
                          title: Text(t.history),
                          trailing: Text(
                            'Ctirl + H',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        onTap: () => showControlForHover(
                          showPopup(
                            context: context,
                            child: const History(),
                            direction: PopupDirection.right,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          mouseCursor: SystemMouseCursors.click,
                          leading: const Icon(
                            Icons.settings_rounded,
                            size: 20,
                          ),
                          title: Text(t.settings),
                          trailing: Text(
                            'Ctirl + P',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        onTap: () => showControlForHover(
                          showPopup(
                            context: context,
                            child: const Settings(),
                            direction: PopupDirection.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
