import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/services/playlist_service.dart';
import 'package:halcyon/theme/app_theme.dart';
import 'package:halcyon/widgets/halcyon_controls.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  static final _engine = AudioEngine.instance;

  @override
  Widget build(BuildContext context) {
    return ColorAwareBuilder(
      builder: (context) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<List<PlaylistEntry>>(
              valueListenable: PlaylistService.playlist,
              builder: (_, entries, __) {
                return HalcyonIconButton(
                  icon: PhosphorIconsBold.skipBack,
                  tooltip: 'Previous',
                  onPressed: entries.isEmpty ? null : _engine.playPrevious,
                );
              },
            ),
            const SizedBox(width: 2),
            ValueListenableBuilder<bool>(
              valueListenable: _engine.isPlaying,
              builder: (_, playing, _) {
                return HalcyonPrimaryButton(
                  icon: playing
                      ? PhosphorIconsFill.pause
                      : PhosphorIconsFill.play,
                  tooltip: playing ? 'Pause' : 'Play',
                  onPressed: _engine.togglePlayPause,
                );
              },
            ),
            const SizedBox(width: 2),
            ValueListenableBuilder<List<PlaylistEntry>>(
              valueListenable: PlaylistService.playlist,
              builder: (_, entries, __) {
                return HalcyonIconButton(
                  icon: PhosphorIconsBold.skipForward,
                  tooltip: 'Next',
                  onPressed: entries.isEmpty ? null : _engine.playNext,
                );
              },
            ),
            const SizedBox(width: 2),
            HalcyonIconButton(
              icon: PhosphorIconsBold.stop,
              tooltip: 'Stop',
              onPressed: _engine.stopPlayback,
            ),
            _verticalDivider(),
            _addTrackAction(context),
            _verticalDivider(),
            ValueListenableBuilder<bool>(
              valueListenable: _engine.shuffle,
              builder: (_, active, _) {
                return HalcyonIconButton(
                  icon: PhosphorIconsBold.shuffle,
                  tooltip: 'Shuffle',
                  isActive: active,
                  onPressed: _engine.toggleShuffle,
                );
              },
            ),
            const SizedBox(width: 2),
            ValueListenableBuilder<LoopState>(
              valueListenable: _engine.loopState,
              builder: (_, loopState, _) {
                return _buildLoopButton(loopState);
              },
            ),
            _verticalDivider(),
            ValueListenableBuilder<double>(
              valueListenable: _engine.volume,
              builder: (_, vol, _) {
                return HalcyonIconButton(
                  icon: vol == 0
                      ? PhosphorIconsBold.speakerSlash
                      : vol < 0.5
                      ? PhosphorIconsBold.speakerLow
                      : PhosphorIconsBold.speakerHigh,
                  tooltip: 'Volume',
                  onPressed: () {
                    _engine.setVolume(vol > 0 ? 0 : 0.75);
                  },
                );
              },
            ),
            SizedBox(
              width: 90,
              child: ValueListenableBuilder<double>(
                valueListenable: _engine.volume,
                builder: (_, vol, _) {
                  return HalcyonSlider(
                    value: vol,
                    onChanged: _engine.setVolume,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _addTrackAction(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _pickAndAddTrack(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsBold.plus, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: HalcyonTextStyles.trackTitle.copyWith(
                color: AppColors.accent,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndAddTrack(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'ogg', 'aac', 'm4a', 'opus'],
      dialogTitle: 'Add track to playlist',
    );
    if (result == null || result.files.single.path == null) {
      return;
    }
    final path = result.files.single.path!;
    await _engine.loadFile(path);
    await _engine.play();
    await PlaylistService.addEntry(path, _engine.duration.value);
    if (context.mounted) {
      context.go('/');
    }
  }

  static Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        width: 1,
        height: 22,
        color: AppColors.border.withAlpha(150),
      ),
    );
  }

  Widget _buildLoopButton(LoopState loopState) {
    final isActive = loopState != LoopState.off;

    return Stack(
      alignment: Alignment.center,
      children: [
        HalcyonIconButton(
          icon: PhosphorIconsBold.repeat,
          tooltip: _getLoopTooltip(loopState),
          isActive: isActive,
          onPressed: _engine.toggleLoop,
        ),
        // Show "1" badge when in loop playlist mode
        if (loopState == LoopState.playlist)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: AppColors.background,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getLoopTooltip(LoopState loopState) {
    return switch (loopState) {
      LoopState.off => 'Loop (Click to loop playlist)',
      LoopState.playlist => 'Loop Playlist (Click to loop song)',
      LoopState.song => 'Loop Song (Click to turn off)',
    };
  }
}
