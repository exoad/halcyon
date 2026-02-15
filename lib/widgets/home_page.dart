import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:halcyon/services/album_art_fit_service.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/services/settings_service.dart';
import 'package:halcyon/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AudioEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = AudioEngine.instance;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _engine.isPlaying,
      builder: (context, isPlaying, _) {
        final hasTrack = _engine.hasTrack;
        return hasTrack ? _loadedView() : _emptyView();
      },
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.currentLine,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border.withAlpha(80)),
            ),
            child: const Center(
              child: Icon(
                PhosphorIconsBold.vinylRecord,
                size: 40,
                color: AppColors.comment,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Track Loaded',
            style: HalcyonTextStyles.trackTitle.copyWith(
              color: AppColors.foreground,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select an audio file to begin',
            style: HalcyonTextStyles.trackMeta,
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _openFiles(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(40),
                  border: Border.all(
                    color: AppColors.accent.withAlpha(120),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
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

  Widget _loadedView() {
    return ValueListenableBuilder<String>(
      valueListenable: _engine.trackTitle,
      builder: (_, title, _) {
        return ValueListenableBuilder<String>(
          valueListenable: _engine.trackArtist,
          builder: (_, artist, _) {
            return ValueListenableBuilder<String>(
              valueListenable: _engine.trackAlbum,
              builder: (_, album, _) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _largeAlbumArt(),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: HalcyonTextStyles.trackTitle.copyWith(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$artist  ·  $album',
                        style: HalcyonTextStyles.artistName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _largeAlbumArt() {
    return ValueListenableBuilder<AlbumArtFit>(
      valueListenable: AlbumArtFitService.currentFitNotifier,
      builder: (context, fit, _) {
        return ValueListenableBuilder<AlbumArtFitMode>(
          valueListenable: SettingsService.albumArtFitMode,
          builder: (context, fitMode, _) {
            return GestureDetector(
              onTap: fitMode == AlbumArtFitMode.clickToChange
                  ? AlbumArtFitService.cycleFit
                  : null,
              child: Tooltip(
                message: fitMode == AlbumArtFitMode.clickToChange
                    ? 'Double-click to change fit: ${fit.displayName}'
                    : 'Album art fit: ${fit.displayName}',
                child: ValueListenableBuilder<dynamic>(
                  valueListenable: _engine.albumArt,
                  builder: (_, art, _) {
                    return Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.currentLine,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border.withAlpha(80)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: art != null && (art as dynamic).isNotEmpty
                            ? Image.memory(
                                art,
                                width: 160,
                                height: 160,
                                fit: fit.boxFit,
                                gaplessPlayback: true,
                              )
                            : const Center(
                                child: Icon(
                                  PhosphorIconsBold.vinylRecord,
                                  size: 64,
                                  color: AppColors.comment,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
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
    await AudioEngine.instance.loadFile(result.files.single.path!);
    await AudioEngine.instance.play();
  }
}

