import 'package:audiotags/audiotags.dart';
import 'package:flutter/foundation.dart';
import 'package:halcyon/models/track_metadata.dart';

final class MetadataService {
  MetadataService._();

  static Future<TrackMetadata> read(String path) async {
    Tag? tag;
    try {
      tag = await AudioTags.read(path);
    } catch (e) {
      debugPrint('MetadataService: failed to read tags from $path – $e');
    }
    if (tag == null) {
      return TrackMetadata(filePath: path);
    }
    Picture? bestPicture;
    if (tag.pictures.isNotEmpty) {
      bestPicture = tag.pictures.cast<Picture?>().firstWhere(
        (p) {
          return p!.pictureType == PictureType.coverFront;
        },
        orElse: () {
          return tag!.pictures.first;
        },
      );
    }
    return TrackMetadata(
      filePath: path,
      title: tag.title,
      artist: tag.trackArtist,
      album: tag.album,
      albumArtist: tag.albumArtist,
      genre: tag.genre,
      year: tag.year,
      trackNumber: tag.trackNumber,
      trackTotal: tag.trackTotal,
      discNumber: tag.discNumber,
      discTotal: tag.discTotal,
      bpm: tag.bpm,
      albumArt: bestPicture?.bytes,
    );
  }
}
