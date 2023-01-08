import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:tearmusic/models/music/track.dart';

class StorageManager {
  StorageManager._internal();

  final Map<String, Box> _boxes = {};

  static final StorageManager _instance = StorageManager._internal();
  static StorageManager get instance => _instance;
  static const List<String> _boxIds = ["images", "music", "user"];

  Future<void> init() async {
    for (var boxId in _boxIds) {
      _boxes[boxId] = await Hive.openBox<void>(boxId);
    }
  }

  BoxManager? getBox(String id) => _boxes[id] != null ? BoxManager(_boxes[id]!) : null;
}

class BoxManager {
  final Box _store;

  BoxManager(Box box) : _store = box;

  Future<void> _storeAccessTime(String key) async {
    _store.put("access_$key", DateTime.now().millisecondsSinceEpoch);
  }

  DateTime? _getAccessTime(String key) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(_store.get(key));
    } catch (e) {
      deleteItem(key);
    }
  }

  Future<void> storeString(String key, String value) async {
    await _store.put("data_string_$key", value);
    await _storeAccessTime(key);
  }

  Future<void> storeList(String key, List value) async {
    await _store.put("data_list_$key", value);
    await _storeAccessTime(key);
  }

  Future<void> storeBytes(String key, Uint8List value) async {
    await _store.put("data_bytes_$key", value);
    await _storeAccessTime(key);
  }

  Future<void> storeMap(String key, Map value) async {
    await _store.put("data_map_$key", value);
    await _storeAccessTime(key);
  }

  bool _checkType(dynamic value, Type type) {
    return value.runtimeType == type;
  }

  String? getString(String key) {
    final res = _store.get("data_string_$key");
    if (res == null) return null;
    if (_checkType(res, String)) return res;

    //log("StorageManager for $boxId getString method got ${res.runtimeType}");
    return null;
  }

  List? getList(String key) {
    final res = _store.get("data_list_$key");
    //if (_checkType(res, List)) return res;
    if (res == null) return null;
    return res;

    //log("StorageManager for $boxId getList method got ${res.runtimeType}");
    //return null;
  }

  Uint8List? getBytes(String key) {
    final res = _store.get("data_bytes_$key");
    return res;
  }

  Map? getMap(String key) {
    final res = _store.get("data_map_$key");
    if (res == null) return null;
    //if (_checkType(res, Map)) return Map<String, dynamic>.from(res);
    return Map<String, dynamic>.from(res);

    //log("StorageManager for $boxId getMap method got ${res.runtimeType}");
    //return null;
  }

  void deleteItem(String key) {
    _store.delete("data_$key");
    _store.delete("access_$key");
  }
}
