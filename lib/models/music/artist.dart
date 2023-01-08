import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/music/track.dart';

class MusicArtist extends Model {
  final String name;
  final List<String> genres;
  final Images? images;
  final int followers;

  MusicArtist({
    required Map json,
    required String id,
    required this.name,
    required this.genres,
    required this.images,
    required this.followers,
  }) : super(id: id, json: json, key: name, type: "artist");

  factory MusicArtist.decode(Map json) {
    final images = json["images"] as List?;
    return MusicArtist(
      json: json,
      id: json["id"],
      name: json["name"],
      genres: ((json["genres"] as List?) ?? []).cast<String>(),
      images: images != null && images.isNotEmpty ? Images.decode(images.cast<Map>()) : null,
      followers: json["followers"] ?? 0,
    );
  }

  Map encode() => json ?? {};

  static List<MusicArtist> decodeList(List<Map> encoded) => encoded
      .where((e) => e["id"] != null && e["images"] != null && e["images"].isNotEmpty)
      .map((e) => MusicArtist.decode(e))
      .toList()
      .cast<MusicArtist>();
  static List<Map> encodeList(List<MusicArtist> models) => models.map((e) => e.encode()).toList().cast<Map>();
}

class ArtistDetails {
  final MusicArtist artist;
  final List<MusicTrack> tracks;
  final List<MusicAlbum> albums;
  final List<MusicArtist> related;
  final List<MusicAlbum> appearsOn;

  ArtistDetails({
    required this.artist,
    required this.tracks,
    required this.albums,
    required this.related,
    required this.appearsOn,
  });

  factory ArtistDetails.decode(Map json) {
    final artist = MusicArtist.decode(json['artist']);

    final related = (json['artists'] as List).cast<Map>();
    final tracks = (json['tracks'] as List).cast<Map>();
    final albumsJson = (json['albums'] as List).cast<Map>();

    List<MusicAlbum> albums = MusicAlbum.decodeList(albumsJson);
    albums.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));

    return ArtistDetails(
      artist: artist,
      tracks: MusicTrack.decodeList(tracks),
      albums: albums.where((e) => e.artists.first.id == artist.id).toList(),
      appearsOn: albums.where((e) => e.artists.first.id != artist.id).toList(),
      related: MusicArtist.decodeList(related),
    );
  }

  Map encode() {
    return {
      "artist": artist.encode(),
      "artists": related.map((e) => e.encode()).toList(),
      "albums": albums.map((e) => e.encode()).toList(),
      "tracks": tracks.map((e) => e.encode()).toList(),
    };
  }
}
