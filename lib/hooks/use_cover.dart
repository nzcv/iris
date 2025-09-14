import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/models/file.dart';
import 'package:iris/models/player.dart';
import 'package:iris/models/storages/local.dart';
import 'package:iris/models/storages/storage.dart';
import 'package:iris/store/use_play_queue_store.dart';
import 'package:iris/store/use_storage_store.dart';
import 'package:iris/utils/files_filter.dart';
import 'package:provider/provider.dart';

FileItem? useCover() {
  final context = useContext();
  final isPlaying =
      context.select<MediaPlayer, bool>((player) => player.isPlaying);

  final playQueue =
      usePlayQueueStore().select(context, (state) => state.playQueue);
  final currentIndex =
      usePlayQueueStore().select(context, (state) => state.currentIndex);

  final int currentPlayIndex = useMemoized(
      () => playQueue.indexWhere((element) => element.index == currentIndex),
      [playQueue, currentIndex]);

  final PlayQueueItem? currentPlay = useMemoized(
      () => playQueue.isEmpty || currentPlayIndex < 0
          ? null
          : playQueue[currentPlayIndex],
      [playQueue, currentPlayIndex]);

  final localStoragesFuture =
      useMemoized(() async => await getLocalStorages(context), []);
  final localStorages = useFuture(localStoragesFuture).data ?? [];

  final storages = useStorageStore().select(context, (state) => state.storages);

  final Storage? storage = useMemoized(
      () => currentPlay?.file == null
          ? null
          : [...localStorages, ...storages].firstWhereOrNull(
              (storage) => storage.id == currentPlay?.file.storageId),
      [currentPlay?.file, localStorages, storages]);

  final cover = useState<FileItem?>(null);

  useEffect(() {
    () async {
      final dir = currentPlay?.file == null || currentPlay!.file.path.isEmpty
          ? <String>[]
          : ([...currentPlay.file.path]..removeLast());

      if (storage == null || currentPlay?.file.type != ContentType.audio) {
        cover.value = null;
        return;
      }

      final files = await storage.getFiles(dir);

      final images = filesFilter(files, [ContentType.image]);

      cover.value = images.firstWhereOrNull((image) =>
              image.name.split('.').first.toLowerCase() == 'cover') ??
          images.firstWhereOrNull((image) =>
              image.name.toLowerCase().startsWith('cover') ||
              image.name.toLowerCase().startsWith('folder')) ??
          images.firstOrNull;
    }();
    return null;
  }, [storage, isPlaying]);

  return cover.value;
}
