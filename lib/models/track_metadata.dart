import 'dart:typed_data';

class TrackMetadata {
  const TrackMetadata({
    required this.filePath,
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    this.trackTotal,
    this.discNumber,
    this.discTotal,
    this.albumArt,
    this.bpm,
  });

  final String filePath;
  final String? title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int? trackTotal;
  final int? discNumber;
  final int? discTotal;
  final Uint8List? albumArt;
  final double? bpm;

  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    final name = filePath.split(RegExp(r'[/\\]')).last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  String get displayArtist {
    if (artist != null && artist!.isNotEmpty) {
      return artist!;
    }
    if (albumArtist != null && albumArtist!.isNotEmpty) {
      return albumArtist!;
    }
    return 'Unknown Artist';
  }

  String get displayAlbum {
    return album ?? 'Unknown Album';
  }

  String get metaLine {
    final parts = <String>[];
    if (album != null && album!.isNotEmpty) {
      parts.add(album!);
    }
    if (year != null) {
      parts.add('$year');
    }
    if (genre != null && genre!.isNotEmpty) {
      parts.add(genre!);
    }
    if (trackNumber != null) {
      parts.add(
        'Track ${trackTotal != null ? '$trackNumber/$trackTotal' : '$trackNumber'}',
      );
    }
    return parts.isEmpty ? 'Local file' : parts.join('  ·  ');
  }
}
