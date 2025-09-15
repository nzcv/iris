import 'package:iris/utils/platform.dart';

String buildFileUri(String baseUri, String fileName) {
  if (baseUri.startsWith('ftp?')) {
    final separator = baseUri.endsWith('/') ? '' : '/';
    return Uri.encodeFull('$baseUri$separator$fileName');
  }

  if (isAndroid && baseUri.startsWith('content://')) {
    return '$baseUri/${Uri.encodeComponent(fileName)}';
  }

  try {
    final dirUri = Uri.parse(baseUri.endsWith('/') ? baseUri : '$baseUri/');
    return dirUri.resolve(fileName).toString();
  } catch (e) {
    final separator = baseUri.endsWith('/') ? '' : '/';
    return '$baseUri$separator$fileName';
  }
}
