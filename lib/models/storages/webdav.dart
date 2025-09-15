import 'dart:convert';
import 'package:iris/models/storages/storage.dart';
import 'package:iris/utils/build_file_uri.dart';
import 'package:iris/utils/check_content_type.dart';
import 'package:iris/utils/find_subtitle.dart';
import 'package:iris/utils/logger.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:iris/models/file.dart';

Future<bool> testWebDAV(WebDAVStorage storage) async {
  final host = storage.host;
  final port = storage.port;
  final username = storage.username;
  final password = storage.password;
  final https = storage.https;
  final basePath = storage.basePath;

  try {
    var client = webdav.newClient(
      "http${https ? 's' : ''}://$host:$port",
      user: username,
      password: password,
      debug: false,
    );

    client.setHeaders({'accept-charset': 'utf-8'});
    client.setConnectTimeout(4000);
    client.setSendTimeout(4000);
    client.setReceiveTimeout(4000);

    // await client.ping();
    await client.readDir(basePath.join('/'));
    return true;
  } catch (e) {
    logger(e.toString());
    return false;
  }
}

Future<List<FileItem>> getWebDAVFiles(
  WebDAVStorage storage,
  List<String> path,
) async {
  final id = storage.id;
  final host = storage.host;
  final port = storage.port;
  final username = storage.username;
  final password = storage.password;
  final https = storage.https;

  var client = webdav.newClient(
    "http${https ? 's' : ''}://$host:$port",
    user: username,
    password: password,
    debug: false,
  );

  client.setHeaders({'accept-charset': 'utf-8'});
  client.setConnectTimeout(8000);
  client.setSendTimeout(8000);
  client.setReceiveTimeout(8000);

  var files = await client.readDir(path.join('/'));
  final allFileNames = files.map((f) => f.name as String).toList();

  final cleanPathSegments = path.map((e) => e.replaceAll('/', '')).toList();
  final baseUri = Uri(
    scheme: storage.https ? 'https' : 'http',
    host: storage.host,
    port: int.tryParse(storage.port),
    pathSegments: cleanPathSegments,
  );
  final baseUriString = baseUri.toString();

  return await Future.wait(
    files.map((file) async {
      return FileItem(
        storageId: id,
        storageType: StorageType.webdav,
        name: '${file.name}',
        uri: buildFileUri(baseUriString, file.name!),
        path: [...path, '${file.name}'],
        isDir: file.isDir ?? false,
        size: file.size ?? 0,
        lastModified: file.mTime,
        type: file.isDir ?? false
            ? ContentType.dir
            : checkContentType(file.name!),
        subtitles: await findSubtitle(
          allFileNames,
          file.name as String,
          baseUriString,
        ),
      );
    }),
  );
}

String getWebDAVAuth(WebDAVStorage storage) =>
    'Basic ${base64Encode(utf8.encode('${storage.username}:${storage.password}'))}';
