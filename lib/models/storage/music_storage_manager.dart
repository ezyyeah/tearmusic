import 'dart:convert';
import 'dart:developer';

import 'package:tearmusic/models/batch.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/search.dart';
import 'package:tearmusic/models/storage/storage.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/storage/user_storage_manager.dart';
import 'package:tearmusic/providers/user_provider.dart';

class MusicStorage {
  BoxManager manager;
  UserStorage userSM;

  MusicStorage({required this.userSM}) : manager = StorageManager.instance.getBox("music")!;

  BatchLibrary? getLibraryBatch() {
    print("FETCHING LIB --------");
    final res = userSM.getLibrary();
    if (res != null) {
      try {
        return BatchLibrary.decode({
          "tracks": res.liked_tracks.map((e) => getTrack(e)?.encode()).where((e) => e != null).toList(),
          "artists": res.liked_artists.map((e) => getArtist(e)?.encode()).where((e) => e != null).toList(),
          "albums": res.liked_albums.map((e) => getAlbum(e)?.encode()).where((e) => e != null).toList(),
          "playlists": res.liked_playlists.map((e) => getPlaylist(e)?.encode()).where((e) => e != null).toList(),
          "track_history": [],
        });
      } catch (e, s) {
        print("batchlib decode error $s");
        userSM.deleteField("library");
      }
    }
    return null;
  }

  void storeLibraryBatch(BatchLibrary library) {
    for (var element in library.tracks) {
      storeTrack(element);
    }
    for (var element in library.albums) {
      storeAlbum(element);
    }
    for (var element in library.artists) {
      storeArtist(element);
    }
    for (var element in library.playlists) {
      storePlaylist(element);
    }
    for (var element in library.track_history) {
      storeTrack(element.track);
    }
  }

  MusicTrack? getTrack(String id) {
    final key = "tracks_$id";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        return MusicTrack.decode(res);
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeTrack(MusicTrack track) {
    manager.storeMap("tracks_$track", track.encode());
  }

  MusicAlbum? getAlbum(String id) {
    final key = "albums_$id";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        return MusicAlbum.decode(res);
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeAlbum(MusicAlbum album) {
    manager.storeMap("albums_$album", album.encode());
  }

  ArtistDetails? artistDetails(String id) {
    final key = "artist_details_$id";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        return ArtistDetails.decode(res);
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeArtistDetails(ArtistDetails details) {
    manager.storeMap("artist_details_${details.artist.id}", details.encode());
  }

  MusicArtist? getArtist(String id) {
    final key = "artists_$id";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        return MusicArtist.decode(res);
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeArtist(MusicArtist artist) {
    manager.storeMap("artists_$artist", artist.encode());
  }

  MusicPlaylist? getPlaylist(String id) {
    final key = "playlists_$id";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        return MusicPlaylist.decode(res);
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storePlaylist(MusicPlaylist playlist) {
    manager.storeMap("playlists_$playlist", playlist.encode());
  }

  PlaylistDetails? getPlaylistDetails(String id) {
    final key = "playlist_details_$id";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        List<Map> tracks = (res["tracks"] as List).map((id) => getTrack(id)?.encode()).toList().cast();
        return PlaylistDetails.decode({"tracks": tracks, "followers": res["followers"]}, id);
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storePlaylistDetails(PlaylistDetails details) {
    manager.storeMap("playlist_details_$details", {
      "tracks": Model.encodeIdList(details.tracks),
      "followers": details.followers,
    });

    for (final track in details.tracks) {
      storeTrack(track);
    }
  }

  List<MusicTrack>? albumTracks(String albumId) {
    final key = "album_tracks_$albumId";
    final res = manager.getList(key);
    if (res != null) {
      try {
        return MusicTrack.decodeList(res.map((id) => manager.getMap("tracks_$id")).toList().cast()).toSet().toList();
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeAlbumTracks(String albumId, List<MusicTrack> tracks) {
    manager.storeList("album_tracks_$albumId", Model.encodeIdList(tracks));

    for (final track in tracks) {
      storeTrack(track);
    }
  }

  List<MusicAlbum>? artistAlbums(String artistId) {
    final key = "artist_albums_$artistId";
    final res = manager.getList(key);
    if (res != null) {
      try {
        return MusicAlbum.decodeList(res.map((id) => manager.getMap("albums_$id")).toList().cast()).toSet().toList();
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeArtistAlbums(String artistId, List<MusicAlbum> albums) {
    manager.storeList("artist_albums_$artistId", Model.encodeIdList(albums));

    for (final album in albums) {
      storeAlbum(album);
    }
  }

  List<MusicAlbum>? newReleases() {
    const key = "new_releases";
    final res = manager.getList(key);
    if (res != null) {
      try {
        return MusicAlbum.decodeList(res.map((id) => manager.getMap("albums_$id")).toList().cast()).toSet().toList();
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeNewReleases(List<MusicAlbum> albums) {
    manager.storeList("new_releases", Model.encodeIdList(albums));

    for (final album in albums) {
      storeAlbum(album);
    }
  }

  List<MusicTrack>? artistTracks(String artistId) {
    final key = "artist_tracks_$artistId";
    final res = manager.getList(key);
    if (res != null) {
      try {
        return MusicTrack.decodeList(res.map((id) => manager.getMap("tracks_$id")).toList().cast()).toSet().toList();
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeArtistTracks(String artistId, List<MusicTrack> tracks) {
    manager.storeList("artist_tracks_$artistId", Model.encodeIdList(tracks));

    for (final track in tracks) {
      storeTrack(track);
    }
  }

  List<MusicArtist>? artistRelated(String artistId) {
    final key = "artist_related_$artistId";
    final res = manager.getList(key);
    if (res != null) {
      try {
        return MusicArtist.decodeList(res.map((id) => manager.getMap("artists_$id")).toList().cast()).toSet().toList();
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeArtistRelated(String artistId, List<MusicArtist> related) {
    manager.storeList("artist_related_$artistId", Model.encodeIdList(related));

    for (final artist in related) {
      storeArtist(artist);
    }
  }

  MusicLyrics? trackLyrics(String trackId) {
    final key = "track_lyrics_$trackId";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        return MusicLyrics.decode(res);
      } catch (e) {
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeTrackLyrics(String trackId, MusicLyrics lyrics) {
    manager.storeMap("track_lyrics_$trackId", lyrics.encode());
  }

  SearchResults? search(String query) {
    final key = "search_results_$query";
    final res = manager.getMap(key);
    if (res != null) {
      try {
        List<Map> tracks = [];
        List<Map> albums = [];
        List<Map> playlists = [];
        List<Map> artists = [];
        for (final id in res['tracks']) {
          tracks.add(manager.getMap("tracks_$id")!);
        }
        for (final id in res['albums']) {
          albums.add(manager.getMap("albums_$id")!);
        }
        for (final id in res['playlists']) {
          playlists.add(manager.getMap("playlists_$id")!);
        }
        for (final id in res['artists']) {
          artists.add(manager.getMap("artists_$id")!);
        }
        return SearchResults.decode({
          "tracks": tracks,
          "albums": albums,
          "playlists": playlists,
          "artists": artists,
        });
      } catch (e, s) {
        print("search error: $e $s");
        manager.deleteItem(key);
      }
    }
    return null;
  }

  void storeSearch(String query, SearchResults results) {
    print("storing search on key: " + "search_results_$query");
    print("value: ${results.tracks.toString()}");

    manager.storeMap("search_results_$query", {
      'tracks': Model.encodeIdList(results.tracks),
      'albums': Model.encodeIdList(results.albums),
      'playlists': Model.encodeIdList(results.playlists),
      'artists': Model.encodeIdList(results.artists),
    });

    for (final track in results.tracks) {
      storeTrack(track);
    }

    for (final album in results.albums) {
      storeAlbum(album);
    }

    for (final playlist in results.playlists) {
      storePlaylist(playlist);
    }

    for (final artists in results.artists) {
      storeArtist(artists);
    }
  }
}
