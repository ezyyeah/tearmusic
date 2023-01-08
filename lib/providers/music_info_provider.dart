import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/api/music_api.dart';
import 'package:tearmusic/models/batch.dart';
import 'package:tearmusic/models/storage/cached_item.dart';
import 'package:tearmusic/models/storage/music_storage_manager.dart';
import 'package:tearmusic/models/storage/storage.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/manual_match.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/search.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/playback.dart';
import 'package:tearmusic/models/storage/user_storage_manager.dart';

class MusicInfoProvider {
  MusicInfoProvider({required BaseApi base, required this.manager}) : _api = MusicApi(base: base);

  final MusicApi _api;

  late MusicStorage manager;

  late String userId;

  Future<List<SearchSuggestion>> searchSuggest(String query) async {
    return await _api.searchSuggest(query);
  }

  Stream<CachedItem<SearchResults?>> search(String query) async* {
    final soff = manager.search(query);
    yield CachedItem(soff);
    //log(soff.tracks.toString());
    if (soff == null)
      print("soff was empty");
    else
      print("soff: " + soff.tracks.toString());

    final data = await _api.search(query);
    manager.storeSearch(query, data);

    yield CachedItem(data, type: CacheType.remote);

    // Offline search
    // } else if (no internet connection) {
    //   final ids = _store.keys.where((k) => RegExp(r'^((:?tracks|albums|playlists|artists)_[a-zA-Z0-9:-]+)$').hasMatch(k)).cast<String>();
    //   List<Map> tracks = [];
    //   List<Map> albums = [];
    //   List<Map> playlists = [];
    //   List<Map> artists = [];
    //   for (final id in ids.where((k) => k.startsWith("tracks"))) {
    //     tracks.add(jsonDecode(_store.get(id)));
    //   }
    //   for (final id in ids.where((k) => k.startsWith("albums"))) {
    //     albums.add(jsonDecode(_store.get(id)));
    //   }
    //   for (final id in ids.where((k) => k.startsWith("playlists"))) {
    //     playlists.add(jsonDecode(_store.get(id)));
    //   }
    //   for (final id in ids.where((k) => k.startsWith("artists"))) {
    //     artists.add(jsonDecode(_store.get(id)));
    //   }
    //   data = SearchResults.decodeFilter({
    //     "tracks": tracks,
    //     "albums": albums,
    //     "playlists": playlists,
    //     "artists": artists,
    //   }, filter: query);
  }

  Stream<CachedItem<PlaylistDetails?>> playlistTracks(String playlistId, {bool head = false}) async* {
    yield CachedItem(manager.getPlaylistDetails(playlistId));

    final data = await _api.playlistDetails(playlistId);
    manager.storePlaylistDetails(data);

    yield CachedItem(data, type: CacheType.remote);
  }

  Stream<CachedItem<List<MusicTrack>?>> albumTracks(String albumId) async* {
    yield CachedItem(manager.albumTracks(albumId));

    final data = await _api.albumTracks(albumId);
    manager.storeAlbumTracks(albumId, data);

    yield CachedItem(data, type: CacheType.remote);
  }

  Stream<CachedItem<List<MusicAlbum>?>> newReleases() async* {
    yield CachedItem(manager.newReleases());

    final data = await _api.newReleases();
    manager.storeNewReleases(data);

    yield CachedItem(data, type: CacheType.remote);
  }

  Stream<CachedItem<ArtistDetails?>> artistDetails(MusicArtist artist) async* {
    yield CachedItem(manager.artistDetails(artist.id));

    final data = await _api.artistDetails(artist);
    manager.storeArtistDetails(data);

    yield CachedItem(data, type: CacheType.remote);
  }

  Stream<CachedItem<List<MusicAlbum>?>> artistAlbums(MusicArtist artist) async* {
    yield CachedItem(manager.artistAlbums(artist.id));

    final data = await _api.artistAlbums(artist);
    manager.storeArtistAlbums(artist.id, data);

    yield CachedItem(data, type: CacheType.remote);
  }

  Stream<CachedItem<List<MusicTrack>?>> artistTracks(MusicArtist artist) async* {
    yield CachedItem(manager.artistTracks(artist.id));

    final data = await _api.artistTracks(artist);
    manager.storeArtistTracks(artist.id, data);

    yield CachedItem(data, type: CacheType.remote);
  }

  Stream<CachedItem<List<MusicArtist>?>> artistRelated(MusicArtist artist) async* {
    yield CachedItem(manager.artistRelated(artist.id));

    final data = await _api.artistRelated(artist);
    manager.storeArtistRelated(artist.id, data);

    yield CachedItem(data, type: CacheType.remote);
  }

  Stream<CachedItem<MusicLyrics?>> lyrics(MusicTrack track) async* {
    yield CachedItem(manager.trackLyrics(track.name));

    final data = await _api.lyrics(track);
    manager.storeTrackLyrics(track.id, data);

    yield CachedItem(data, type: CacheType.remote);
  }

  Future<Playback> playback(MusicTrack track, {String? videoId}) async {
    return await _api.playback(track);
  }

  Future<PlaybackHead> playbackHead(MusicTrack track) async {
    return await _api.playbackHead(track);
  }

  Future<void> purgeCache(MusicTrack track) async {
    await _api.purgeCache(track);
  }

  Future<List<ManualMatch>> manualMatches(MusicTrack track) async {
    return await _api.manualMatches(track);
  }

  Future<void> matchManual(MusicTrack track, String videoId) async {
    await _api.matchManual(track, videoId);
  }

  Future<List<MusicTrack>> batchTracks(List<String> idList) async {
    List<MusicTrack> validTracks = idList.map((id) => manager.getTrack(id)).where((e) => e != null).map((e) => e!).toList();
    List<String> invalidTracks = idList.where((id) => validTracks.map((e) => e.id).contains(id)).toList();

    if (invalidTracks.isEmpty) return validTracks;

    final data = await _api.batchTracks(invalidTracks);

    for (final t in data) {
      validTracks.add(t);
      manager.storeTrack(t);
    }

    return validTracks;
  }

  Stream<CachedItem<List<MusicTrack>>> libraryLikedTracks({int limit = 10, int offset = 0}) async* {
    yield CachedItem(manager.getLibraryBatch()?.tracks.reversed.take(limit).toList() ?? []);

    try {
      BatchLibrary data = await _api.libraryBatch(LibraryType.liked_tracks, limit: limit, offset: offset);
      manager.storeLibraryBatch(data);
      yield CachedItem(data.tracks, type: CacheType.remote);
    } catch (e, s) {
      print("libraryLikedTracks throws: $e, $s");
    }
  }

  Stream<CachedItem<List<MusicArtist>>> libraryLikedArtists({int limit = 10, int offset = 0}) async* {
    yield CachedItem(manager.getLibraryBatch()?.artists.reversed.take(limit).toList() ?? []);

    try {
      BatchLibrary data = await _api.libraryBatch(LibraryType.liked_artists, limit: limit, offset: offset);
      manager.storeLibraryBatch(data);
      yield CachedItem(data.artists, type: CacheType.remote);
    } catch (e, s) {
      print("libraryLikedArtists throws: $e, $s");
    }
  }

  Stream<CachedItem<List<MusicPlaylist>>> libraryLikedPlaylists({int limit = 10, int offset = 0}) async* {
    print("fetched first");
    yield CachedItem(manager.getLibraryBatch()?.playlists.reversed.take(limit).toList() ?? []);

    try {
      BatchLibrary data = await _api.libraryBatch(LibraryType.liked_playlists, limit: limit, offset: offset);
      manager.storeLibraryBatch(data);
      yield CachedItem(data.playlists, type: CacheType.remote);
    } catch (e, s) {
      print("libraryLikedPlaylists throws: $e, $s");
    }
  }

  Stream<CachedItem<List<MusicAlbum>>> libraryLikedAlbums({int limit = 10, int offset = 0}) async* {
    yield CachedItem(manager.getLibraryBatch()?.albums.reversed.take(limit).toList() ?? []);

    try {
      BatchLibrary data = await _api.libraryBatch(LibraryType.liked_albums, limit: limit, offset: offset);
      manager.storeLibraryBatch(data);
      yield CachedItem(data.albums, type: CacheType.remote);
    } catch (e, s) {
      print("libraryLikedAlbums throws: $e, $s");
    }
  }

  Stream<CachedItem<List<MusicTrack>>> libraryTrackHistory({int limit = 10, int offset = 0}) async* {
    yield CachedItem(manager.getLibraryBatch()?.track_history.reversed.take(limit).map((e) => e.track).toList() ?? []);

    try {
      BatchLibrary data = await _api.libraryBatch(LibraryType.track_history, limit: limit, offset: offset);
      manager.storeLibraryBatch(data);
      yield CachedItem(data.track_history.map((e) => e.track).toList(), type: CacheType.remote);
    } catch (e, s) {
      print("libraryTrackHistory throws: $e, $s");
    }
  }
}
