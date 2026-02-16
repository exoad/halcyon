import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:halcyon/models/track_metadata.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/services/metadata_service.dart';
import 'package:halcyon/services/playlist_service.dart';
import 'package:halcyon/theme/app_theme.dart';
import 'package:halcyon/widgets/halcyon_controls.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, Future<TrackMetadata>> _metadataCache = {};
  // Index of the row currently hovered (for showing drag handle)
  int _hoveringIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ColorAwareBuilder(
      builder: (context) {
        return ValueListenableBuilder<List<PlaylistEntry>>(
          valueListenable: PlaylistService.playlist,
          builder: (context, entries, _) {
            return entries.isEmpty ? _emptyView() : _loadedView(entries);
          },
        );
      },
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.currentLine,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border.withAlpha(80)),
            ),
            child: Center(
              child: Icon(
                PhosphorIconsBold.vinylRecord,
                size: 40,
                color: AppColors.comment,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Tracks in Playlist',
            style: HalcyonTextStyles.trackTitle.copyWith(
              color: AppColors.foreground,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a track with the + button or open an audio file',
            style: HalcyonTextStyles.trackMeta,
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _openFiles(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(40),
                  border: Border.all(color: AppColors.accent.withAlpha(120)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.folderOpen,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Open Audio File',
                      style: HalcyonTextStyles.trackTitle.copyWith(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadedView(List<PlaylistEntry> entries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: AudioEngine.instance.filePath,
              builder: (_, activePath, _) {
                return ReorderableListView.builder(
                  padding: EdgeInsets.zero,
                  buildDefaultDragHandles: false,
                  itemCount: entries.length,
                  onReorder: (oldIndex, newIndex) async {
                    await PlaylistService.reorderEntries(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    return _playlistRow(
                      entries[index],
                      index: index,
                      isActive: entries[index].filePath == activePath,
                      key: ValueKey(entries[index].filePath),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _playlistRow(
    PlaylistEntry entry, {
    required int index,
    required bool isActive,
    required Key key,
  }) {
    return FutureBuilder<TrackMetadata>(
      key: key,
      future: _loadMetadata(entry.filePath),
      builder: (_, snapshot) {
        final meta = snapshot.data;
        final title = meta?.displayTitle ?? _fallbackTitle(entry.filePath);
        final artist = meta?.displayArtist ?? 'Unknown Artist';
        final album = meta?.displayAlbum ?? 'Unknown Album';
        final art = meta?.albumArt;
        final durationText = entry.durationMs > 0
            ? _formatDuration(entry.duration)
            : '--:--';
        final titleStyle = HalcyonTextStyles.trackTitle.copyWith(
          fontSize: 13,
          color: isActive ? AppColors.accent : null,
        );
        final artistStyle = HalcyonTextStyles.artistName.copyWith(
          fontSize: 12,
          color: isActive ? AppColors.accent : null,
        );
        final albumStyle = HalcyonTextStyles.trackMeta.copyWith(
          fontSize: 12,
          color: isActive ? AppColors.accent : null,
        );
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await AudioEngine.instance.loadFile(entry.filePath);
            },
            hoverColor: AppColors.surfaceLight.withAlpha(80),
            splashColor: Colors.transparent,
            highlightColor: AppColors.surfaceLight.withAlpha(120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.surfaceLight.withAlpha(90) : null,
                border: Border(
                  left: BorderSide(
                    color: isActive ? AppColors.accent : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Left gutter: show track number, cross-fade to drag handle on hover
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _hoveringIndex = index;
                      });
                    },
                    onExit: (_) {
                      if (_hoveringIndex == index) {
                        setState(() {
                          _hoveringIndex = -1;
                        });
                      }
                    },
                    child: SizedBox(
                      width: 28,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Track number (visible when not hovering)
                          AnimatedOpacity(
                            opacity: _hoveringIndex == index ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            child: Text(
                              '${index + 1}',
                              style: HalcyonTextStyles.trackMeta.copyWith(
                                fontSize: 12,
                                color: AppColors.comment,
                              ),
                            ),
                          ),
                          // Drag handle (appears on hover)
                          IgnorePointer(
                            ignoring: _hoveringIndex != index,
                            child: AnimatedOpacity(
                              opacity: _hoveringIndex == index ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 180),
                              child: ReorderableDragStartListener(
                                index: index,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.grab,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 6,
                                    ),
                                    child: Icon(
                                      PhosphorIconsBold.dotsSixVertical,
                                      size: 16,
                                      color: AppColors.comment,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _libraryAlbumArt(art),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Text(
                      title,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      artist,
                      style: artistStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      album,
                      style: albumStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    child: Text(
                      durationText,
                      style: HalcyonTextStyles.trackMeta.copyWith(fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<TrackMetadata> _loadMetadata(String path) {
    return _metadataCache.putIfAbsent(path, () => MetadataService.read(path));
  }

  static String _fallbackTitle(String path) {
    final name = path.split(RegExp(r'[/\\]')).last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  Widget _libraryAlbumArt(Uint8List? art) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.currentLine,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.border.withAlpha(90)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: art != null && art.isNotEmpty
            ? Image.memory(art, width: 34, height: 34, fit: BoxFit.cover)
            : Icon(
                PhosphorIconsBold.musicNote,
                size: 16,
                color: AppColors.comment,
              ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  static Future<void> _openFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'ogg', 'aac', 'm4a', 'opus'],
      dialogTitle: 'Open audio file',
    );
    if (result == null || result.files.single.path == null) {
      return;
    }
    final path = result.files.single.path!;
    await AudioEngine.instance.loadFile(path);
    await AudioEngine.instance.play();
    await PlaylistService.addEntry(path, AudioEngine.instance.duration.value);
  }
}
