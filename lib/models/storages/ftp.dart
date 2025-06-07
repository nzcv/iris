import 'dart:convert';

import 'package:iris/models/file.dart';
import 'package:iris/models/storages/storage.dart';
import 'package:iris/utils/check_content_type.dart';
import 'package:iris/utils/find_subtitle.dart';
import 'package:iris/utils/logger.dart';
import 'package:pure_ftp/pure_ftp.dart';

Future<List<FileItem>> getFTPFiles(
    FTPStorage storage, List<String> path) async {
  final username = storage.username.isEmpty ? 'anonymous' : storage.username;

  final client = FtpClient(
    socketInitOptions: FtpSocketInitOptions(
      host: storage.host,
      port: int.tryParse(storage.port),
    ),
    authOptions: FtpAuthOptions(
      username: username,
      password: storage.password,
      account: '',
    ),
    logCallback: null,
  );

  try {
    await client.connect();
    await client.fs.changeDirectory(path.join('/').replaceFirst('//', '/'));

    final files = await client.fs.listDirectory();

    await client.disconnect();

    final baseUri =
        'http://localhost:8760/ftp?host=${storage.host}&port=${storage.port}&path=${path.join('/').replaceFirst('//', '/')}';

    return await Future.wait(files.map(
      (file) async => FileItem(
        storageId: storage.id,
        storageType: StorageType.ftp,
        name: file.name,
        uri: '$baseUri/${file.name}',
        path: [...path, file.name],
        isDir: file.isDirectory,
        size: file.isDirectory ? 0 : file.info?.size ?? 0,
        lastModified: file.info?.modifyTime != null
            ? DateTime.tryParse(file.info!.modifyTime!)
            : null,
        type: file.isDirectory ? ContentType.dir : checkContentType(file.name),
        subtitles: await findSubtitle(
          files.map((file) => file.name).toList(),
          file.name,
          baseUri,
        ),
      ),
    ));
  } catch (error) {
    logger('Error testing FTP: $error');
    return [];
  }
}

Future<bool> testFTP(FTPStorage storage) async {
  final client = FtpClient(
    socketInitOptions: FtpSocketInitOptions(
      host: storage.host,
      port: int.tryParse(storage.port),
    ),
    authOptions: FtpAuthOptions(
      username: storage.username.isEmpty ? 'anonymous' : storage.username,
      password: storage.password,
      account: '',
    ),
    logCallback: null,
  );

  try {
    await client.connect();
    await client.fs.listDirectory();
    await client.disconnect();
    return true;
  } catch (error) {
    logger('Error testing FTP: $error');
    return false;
  }
}

String getFTPAuth(FTPStorage storage) =>
    'Basic ${base64Encode(utf8.encode('${storage.username.isEmpty ? 'anonymous' : storage.username}:${storage.password}'))}';
