class FileItem {
  final String? name;
  final String? path;
  final bool? isDir;
  final int? size;
  final String? type;
  final String? auth;
  final List<SubTitle>? subTitles;

  FileItem(
    this.name,
    this.path,
    this.isDir,
    this.size,
    this.type,
    this.auth,
    this.subTitles,
  );
}

class SubTitle {
  final String? name;
  final String? path;

  SubTitle(this.name, this.path);
}
