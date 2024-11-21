class FileItem {
  final String? name;
  final String? path;
  final bool? isDir;
  final int? size;
  final String? type;
  final String? auth;

  FileItem(this.name, this.path, this.isDir, this.size, this.type, this.auth);
}
