import 'package:iris/models/file.dart';
import 'package:iris/models/storages/storage.dart';

class LocalStorage implements Storage {
  @override
  String type;
  @override
  String name;
  @override
  String basePath;

  LocalStorage({
    required this.type,
    required this.name,
    required this.basePath,
  });

  @override
  Future<List<FileItem>> getFiles(String last) async {
    return [];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'basePath': basePath,
    };
  }

  factory LocalStorage.fromJson(Map<String, dynamic> json) {
    return LocalStorage(
      type: json['type'],
      name: json['name'],
      basePath: json['basePath'],
    );
  }
}
