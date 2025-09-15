import 'package:iris/utils/build_file_uri.dart';
import 'package:iris/models/file.dart';
import 'package:iris/utils/check_content_type.dart';
import 'package:path/path.dart' as path;

Future<List<Subtitle>> findSubtitle(
  List<String> fileNames,
  String videoName,
  String baseUri,
) async {
  if (checkContentType(videoName) != ContentType.video) {
    return [];
  }

  final baseName = path.basenameWithoutExtension(videoName);

  final subtitleExtensions = {'ass', 'srt', 'vtt', 'sub'};

  final regex = RegExp(
    r'^' +
        RegExp.escape(baseName) +
        r'\.(.+?)\.(' +
        subtitleExtensions.join('|') +
        r')$',
    caseSensitive: false,
  );

  return fileNames.where((fileName) {
    final fileExt = path.extension(fileName).replaceFirst('.', '');
    return fileName.startsWith(baseName) &&
        subtitleExtensions.contains(fileExt);
  }).map((fileName) {
    String subTitleName = fileName;
    final match = regex.firstMatch(fileName);

    if (match != null && match.groupCount >= 1) {
      subTitleName = match.group(1) ?? fileName;
    }

    return Subtitle(
      name: subTitleName,
      uri: buildFileUri(baseUri, fileName),
    );
  }).toList();
}
