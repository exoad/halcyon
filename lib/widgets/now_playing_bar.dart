import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:halcyon/services/album_art_fit_service.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/theme/app_theme.dart';
import 'package:halcyon/widgets/halcyon_controls.dart';
import 'package:halcyon/widgets/player_controls.dart';
import 'package:halcyon/widgets/waveform_visualizer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  static final _engine = AudioEngine.instance;

  @override
  Widget build(BuildContext context) {
    return HalcyonPanel(
      padding: EdgeInsets.zero,
      color: AppColors.surface.withAlpha(160),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                spacing: 12,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _albumArt(context),
                  Expanded(child: _trackInfo()),
                  _timeLabels(),
                  const PlayerControls(),
                ],
              ),
            ),
          ),
          _seekBar(context),
          const WaveformVisualizer(height: 70, barCount: 80),
        ],
      ),
    );
  }

  Widget _albumArt(BuildContext context) {
    return ValueListenableBuilder<AlbumArtFit>(
      valueListenable: AlbumArtFitService.currentFitNotifier,
      builder: (context, fit, _) {
        return GestureDetector(
          onTap: AlbumArtFitService.cycleFit,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: 'Tap to change fit: ${fit.displayName}',
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.currentLine,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.border.withAlpha(100)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: ValueListenableBuilder<Uint8List?>(
                    valueListenable: _engine.albumArt,
                    builder: (_, art, _) {
                      if (art != null && art.isNotEmpty) {
                        return Image.memory(
                          art,
                          width: 58,
                          height: 58,
                          fit: fit.boxFit,
                          gaplessPlayback: true,
                        );
                      }
                      return ValueListenableBuilder<String?>(
                        valueListenable: _engine.filePath,
                        builder: (_, path, _) {
                          return Center(
                            child: Icon(
                              path != null
                                  ? PhosphorIconsBold.musicNote
                                  : PhosphorIconsBold.folderOpen,
                              size: 24,
                              color: path != null ? AppColors.accent : AppColors.comment,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _trackInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<String>(
          valueListenable: _engine.trackTitle,
          builder: (_, title, _) {
            return Text(
              title,
              style: HalcyonTextStyles.trackTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            );
          },
        ),
        const SizedBox(height: 2),
        ValueListenableBuilder<String>(
          valueListenable: _engine.trackArtist,
          builder: (_, artist, _) {
            return Text(
              artist,
              style: HalcyonTextStyles.artistName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            );
          },
        ),
        const SizedBox(height: 2),
        ValueListenableBuilder<String>(
          valueListenable: _engine.trackMeta,
          builder: (_, meta, _) {
            return Text(
              meta.isEmpty ? '0:00  ·  — kbps  ·  — kHz' : meta,
              style: HalcyonTextStyles.trackMeta,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            );
          },
        ),
      ],
    );
  }

  Widget _timeLabels() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ValueListenableBuilder<Duration>(
          valueListenable: _engine.position,
          builder: (_, pos, _) {
            return Text(_formatDuration(pos), style: HalcyonTextStyles.timeLabel);
          },
        ),
        const SizedBox(height: 2),
        ValueListenableBuilder<Duration>(
          valueListenable: _engine.duration,
          builder: (_, dur, _) {
            return Text(_formatDuration(dur), style: HalcyonTextStyles.timeLabel);
          },
        ),
      ],
    );
  }

  Widget _seekBar(BuildContext context) {
    return SizedBox(
      height: 14,
      child: ValueListenableBuilder<Duration>(
        valueListenable: _engine.duration,
        builder: (_, dur, _) {
          return ValueListenableBuilder<Duration>(
            valueListenable: _engine.position,
            builder: (_, pos, _) {
              final totalMs = dur.inMilliseconds;
              return SliderTheme(
                data: Theme.of(context).sliderTheme.copyWith(
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: AppColors.surfaceLight,
                  thumbColor: AppColors.accent,
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                  trackShape: const RectangularSliderTrackShape(),
                ),
                child: Slider(
                  value: totalMs > 0 ? (pos.inMilliseconds / totalMs).clamp(0.0, 1.0) : 0.0,
                  onChanged: totalMs > 0
                      ? (v) {
                          _engine.seek(Duration(milliseconds: (v * totalMs).round()));
                        }
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
