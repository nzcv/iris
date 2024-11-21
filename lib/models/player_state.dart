import 'package:iris/models/storages/local_storage.dart';
import 'package:iris/models/storages/storage.dart';
import 'package:iris/models/storages/webdav_storage.dart';

class AppState {
  AppState({
    this.storages = const [],
    this.autoPlay = true,
    this.loop = false,
    this.volume = 100,
    this.isMuted = false,
    this.playbackProgress = const {},
    this.theme = 'auto',
    this.subtitleLanguage = 'auto',
    this.autoCheckUpdates = true,
  });

  List<Storage> storages;
  bool autoPlay;
  bool loop;
  int volume;
  bool isMuted;
  Map<String, double> playbackProgress;
  String theme;
  String subtitleLanguage;
  bool autoCheckUpdates;

  AppState copyWith({
    List<Storage>? storages,
    bool? autoPlay,
    bool? loop,
    int? volume,
    bool? isMuted,
    Map<String, double>? playbackProgress,
    String? theme,
    String? subtitleLanguage,
    bool? autoCheckUpdates,
  }) =>
      AppState(
        storages: storages ?? this.storages,
        autoPlay: autoPlay ?? this.autoPlay,
        loop: loop ?? this.loop,
        volume: volume ?? this.volume,
        isMuted: isMuted ?? this.isMuted,
        playbackProgress: playbackProgress ?? this.playbackProgress,
        theme: theme ?? this.theme,
        subtitleLanguage: subtitleLanguage ?? this.subtitleLanguage,
        autoCheckUpdates: autoCheckUpdates ?? this.autoCheckUpdates,
      );

  Map<String, dynamic> toJson() {
    return {
      'storages': storages.map((s) => s.toJson()).toList(),
      'autoPlay': autoPlay,
      'loop': loop,
      'volume': volume,
      'isMuted': isMuted,
      'playbackProgress': playbackProgress,
      'theme': theme,
      'subtitleLanguage': subtitleLanguage,
      'autoCheckUpdates': autoCheckUpdates,
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      storages: (json['storages'] as List)
          .map((storageJson) {
            if (storageJson['type'] == 'webdav') {
              return WebdavStorage.fromJson(storageJson);
            } else if (storageJson['type'] == 'local') {
              return LocalStorage.fromJson(storageJson);
            } else {
              throw Exception('Unknown storage type');
            }
          })
          .toList()
          .cast<Storage>(),
      autoPlay: json['autoPlay'],
      loop: json['loop'],
      volume: json['volume'],
      isMuted: json['isMuted'],
      playbackProgress: Map<String, double>.from(json['playbackProgress']),
      theme: json['theme'],
      subtitleLanguage: json['subtitleLanguage'],
      autoCheckUpdates: json['autoCheckUpdates'],
    );
  }
}
