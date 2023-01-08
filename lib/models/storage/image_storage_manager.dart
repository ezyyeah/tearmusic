import 'package:flutter/foundation.dart';
import 'package:tearmusic/models/storage/storage.dart';

class ImageStorage {
  BoxManager manager;

  ImageStorage() : manager = StorageManager.instance.getBox("images")!;

  Uint8List? getImageBytes(String url) {
    final res = manager.getBytes(url);
    return res;
  }

  void storeImageBytes(String url, Uint8List bytes) {
    manager.storeBytes(url, bytes);
  }
}
