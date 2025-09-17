import 'package:iris/models/file.dart';
import 'package:path/path.dart' as path;

Map<String, List<Subtitle>> getSubtitleMap<T>({
  required List<T> files,
  required String Function(T) getName,
  required String Function(T) getUri,
}) {
  final subtitleExtensions = {'ass', 'srt', 'vtt', 'sub'};
  final Map<String, List<Subtitle>> subtitleMap = {};

  for (final file in files) {
    final fileName = getName(file);
    final fileExt =
        path.extension(fileName).replaceFirst('.', '').toLowerCase();
    if (subtitleExtensions.contains(fileExt)) {
      final mediaBaseName =
          path.basenameWithoutExtension(fileName).split('.').first;

      final subBaseName = path.basenameWithoutExtension(fileName);
      final regex = RegExp(r'^' + RegExp.escape(mediaBaseName) + r'\.(.+?)$',
          caseSensitive: false);
      final match = regex.firstMatch(subBaseName);
      final subTitleName = match?.group(1) ?? subBaseName;

      final subtitle = Subtitle(
        name: subTitleName,
        uri: getUri(file),
      );
      subtitleMap.putIfAbsent(mediaBaseName, () => []).add(subtitle);
    }
  }
  return subtitleMap;
}
