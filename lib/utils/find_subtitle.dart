import 'dart:io';
import 'package:iris/utils/platform.dart';
import 'package:path/path.dart' as p;
import 'package:iris/models/file.dart';
import 'package:iris/utils/check_content_type.dart';

Future<List<Subtitle>> findSubtitle(
  List<String> fileNames,
  String name,
  String baseUri,
) async {
  if (checkContentType(name) == ContentType.video) {
    List<Subtitle> foundSubTitles = [];

    String baseName =
        name.split('.').sublist(0, name.split('.').length - 1).join('.');

    List<String> subtitleExtensions = ['ass', 'srt', 'vtt', 'sub'];

    for (String fileName in fileNames) {
      if (fileName.startsWith(baseName) &&
          subtitleExtensions.any((ext) => fileName.endsWith(ext))) {
        String subTitleName = fileName
            .replaceAll(baseName, '')
            .split('.')
            .where((e) => e.isNotEmpty && !subtitleExtensions.contains(e))
            .join('.');

        foundSubTitles.add(Subtitle(
          name: subTitleName.isEmpty ? fileName : subTitleName,
          uri: isAndroid && baseUri.startsWith('content://')
              ? '$baseUri${Uri.encodeComponent('/$fileName')}'
              : '$baseUri/$fileName',
        ));
      }
    }
    return foundSubTitles;
  } else {
    return [];
  }
}

Future<List<Subtitle>> findLocalSubtitle(String uri) async {
  if (checkContentType(uri) == ContentType.video) {
    final baseUri =
        uri.split('.').sublist(0, uri.split('.').length - 1).join('.');

    final directory = Directory(p.dirname(uri));

    List<Subtitle> foundSubTitles = [];

    List<String> subtitleExtensions = ['ass', 'srt', 'vtt', 'sub'];

    final entities = directory.list();
    await for (final entity in entities) {
      if (entity.path.startsWith(baseUri) &&
          subtitleExtensions.any((ext) => entity.path.endsWith(ext))) {
        String subTitleName = entity.path
            .replaceAll(baseUri, '')
            .split('.')
            .where((e) => e.isNotEmpty && !subtitleExtensions.contains(e))
            .join('.');

        final fileName = p.basename(entity.path);

        foundSubTitles.add(Subtitle(
          name: subTitleName.isEmpty ? fileName : subTitleName,
          uri: entity.path,
        ));
      }
    }

    return foundSubTitles;
  } else {
    return [];
  }
}
