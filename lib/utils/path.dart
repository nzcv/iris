import 'dart:io';
import 'package:iris/info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getDataPath() async {
  final directory = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();

  final path = join(directory!.path, INFO.title);

  final fileDirectory = Directory(path);
  if (!await fileDirectory.exists()) {
    await fileDirectory.create(recursive: true);
  }

  return path;
}

Future<String> getConfigPath() async {
  final directory = join(await getDataPath(), 'config');

  final fileDirectory = Directory(directory);
  if (!await fileDirectory.exists()) {
    await fileDirectory.create(recursive: true);
  }

  return join(directory, 'config.json');
}
