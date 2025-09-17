import 'package:iris/models/file.dart';

List<FileItem> filesFilter(
  List<FileItem> files, {
  List<ContentType>? types,
  bool? includeDirs = true,
}) {
  return files
      .where((file) =>
          (types == null ? true : types.contains(file.type)) ||
          (includeDirs == true && file.isDir))
      .toList();
}
