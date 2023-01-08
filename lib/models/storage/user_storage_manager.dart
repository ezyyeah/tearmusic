import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/player_info.dart';
import 'package:tearmusic/models/storage/storage.dart';

class UserStorage {
  BoxManager manager;

  UserStorage() : manager = StorageManager.instance.getBox("user")!;

  String? getUserName() {
    return manager.getString("username");
  }

  String? getAvatar() {
    return manager.getString("avatar");
  }

  String? getId() {
    return manager.getString("id");
  }

  String? getAccessToken() {
    return manager.getString("access_token");
  }

  String? getRefreshToken() {
    return manager.getString("refresh_token");
  }

  void deleteField(String key) {
    manager.deleteItem(key);
  }

  void storeUserName(String value) {
    manager.storeString("username", value);
  }

  void storeAvatar(String value) {
    manager.storeString("avatar", value);
  }

  void storeId(String value) {
    manager.storeString("id", value);
  }

  void storeAccessToken(String value) {
    manager.storeString("access_token", value);
  }

  void storeRefreshToken(String value) {
    manager.storeString("refresh_token", value);
  }

  UserLibrary? getLibrary() {
    const key = "library";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        return UserLibrary.decode(res);
      } catch (e) {
        deleteField(key);
      }
    }
    return null;
  }

  void storeLibrary(UserLibrary library) {
    manager.storeMap("library", library.encode());
  }

  PlayerInfo? getPlayerInfo() {
    const key = "player_info";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        return PlayerInfo.decode(res);
      } catch (e) {
        deleteField(key);
      }
    }
    return null;
  }

  void storePlayerInfo(PlayerInfo playerInfo) {
    manager.storeMap("player_info", playerInfo.encode());
  }
}
