const List<String> audioFormats = [
  'wav',
  'mp3',
  'aac',
  'ogg',
  'flac',
  'm4a',
  'opus',
  'wma',
  'aiff',
  'alac',
  'dsd',
  'cda',
  'midi',
  'mka',
];

const List<String> videoFormats = [
  'mp4',
  'mkv',
  'avi',
  'mov',
  'rmvb',
  'webm',
  'flv',
  'f4v',
  'wmv',
  'mpeg',
  'mpg',
  '3gp',
  'hevc',
  'vob',
  'ts',
];

const List<String> pictureFormats = [
  'jpg',
  'jpeg',
  'png',
  'bmp',
  'webp',
  'avif',
  'tiff',
  'gif',
  'svg',
  'ico',
  'raw',
  'heif',
  'exif',
  'dng',
  'pbm',
  'pgm',
  'ppm',
];

String checkFileType(String name) {
  bool isAudio(String name) {
    return audioFormats
        .any((format) => name.toLowerCase().endsWith('.$format'));
  }

  bool isVideo(String name) {
    return videoFormats
        .any((format) => name.toLowerCase().endsWith('.$format'));
  }

  bool isPicture(String name) {
    return pictureFormats
        .any((format) => name.toLowerCase().endsWith('.$format'));
  }

  if (isAudio(name)) {
    return 'audio';
  }
  if (isVideo(name)) {
    return 'video';
  }
  if (isPicture(name)) {
    return 'picture';
  }
  return 'other';
}
