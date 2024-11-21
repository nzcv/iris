import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:iris/models/player_state.dart';
import 'package:iris/models/storages/storage.dart';
import 'package:iris/store/persistent_store.dart';
import 'package:iris/utils/path.dart';

class AppStore extends PersistentStore<AppState> {
  AppStore() : super(AppState());

  Future<void> addStorage(Storage storage) async {
    set(state.copyWith(storages: [...state.storages, storage]));
    save(state);
  }

  Future<void> updateStorage(int index, Storage storage) async {
    if (index < 0 || index >= state.storages.length) {
      return;
    }

    final updatedStorages = state.storages
      ..removeAt(index)
      ..insert(index, storage);

    set(state.copyWith(storages: updatedStorages));
    save(state);
  }

  Future<void> removeStorage(int index) async {
    if (index < 0 || index >= state.storages.length) {
      return;
    }

    final updatedStorages = state.storages..removeAt(index);

    set(state.copyWith(storages: updatedStorages));
    save(state);
  }

  @override
  Future<AppState?> load() async {
    try {
      final file = File(await getConfigPath());
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString);
        return AppState.fromJson(jsonData);
      }
    } catch (e) {
      log('Error loading AppState: $e');
    }
    return null;
  }

  @override
  Future<void> save(AppState state) async {
    try {
      final file = File(await getConfigPath());
      final jsonString = json.encode(state.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      log('Error saving AppState: $e');
    }
  }
}

AppStore useAppStore() => create(() => AppStore());
