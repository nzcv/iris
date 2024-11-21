import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/hooks/use_get.dart';
import 'package:iris/models/file.dart';
import 'package:iris/models/storages/storage.dart';
import 'package:iris/pages/video_page.dart';
import 'package:iris/utils/file_size_convert.dart';
import 'package:iris/widgets/title_bar.dart';

class FilesPageArguments {
  final Storage storage;

  FilesPageArguments(this.storage);
}

class FilesPage extends HookWidget {
  const FilesPage({super.key, required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    final basePath = storage.basePath;

    final currentPath = useState([basePath]);

    final currentPathString =
        useMemoized(() => currentPath.value.join('/'), [currentPath.value]);

    final title = storage.name;

    final result = useGet(currentPathString, storage.getFiles);
    final List<FileItem> fileList = result.data ?? [];
    final isLoading = result.isLoading;
    final error = result.error;

    final filteredFileList = useMemoized(
        () => fileList
            .where((file) => file.isDir! || file.type == 'video')
            .toList(),
        [fileList]);

    void play(List<FileItem> fileList, int index) {
      final clickedFile = fileList[index];
      final playqueue = fileList.where((file) => file.type == 'video').toList();
      final newIndex = playqueue.indexOf(clickedFile);

      Navigator.of(context).pushNamed('/video',
          arguments: VideoPageArguments(playqueue, newIndex));
    }

    return Scaffold(
      appBar: TitleBar(title: title),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: BreadCrumb.builder(
              itemCount: currentPath.value.length,
              builder: (index) {
                return BreadCrumbItem(
                  content: TextButton(
                    child: Text(['/', ...currentPath.value.sublist(1)][index]),
                    onPressed: () {
                      currentPath.value =
                          currentPath.value.sublist(0, index + 1);
                    },
                  ),
                );
              },
              divider: const Icon(Icons.chevron_right),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error
                    ? const Center(child: Text('Error fetching files.'))
                    : filteredFileList.isEmpty
                        ? const Center(child: Text('No files found.'))
                        : ListView.builder(
                            itemCount: filteredFileList.length,
                            itemBuilder: (context, index) => ListTile(
                              leading: filteredFileList[index].isDir == true
                                  ? const Icon(Icons.folder)
                                  : const Icon(Icons.video_file),
                              title: Text(filteredFileList[index].name ?? ''),
                              subtitle: filteredFileList[index].size != null &&
                                      filteredFileList[index].size != 0
                                  ? Text(
                                      "${fileSizeConvert(filteredFileList[index].size!)} MB")
                                  : null,
                              onTap: () {
                                if (filteredFileList[index].isDir == true &&
                                    filteredFileList[index].name!.isNotEmpty) {
                                  currentPath.value = [
                                    ...currentPath.value,
                                    filteredFileList[index].name!
                                  ];
                                } else {
                                  play(filteredFileList, index);
                                }
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
