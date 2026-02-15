import 'package:flutter/material.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/shared.dart';
import 'package:halcyon/theme/app_theme.dart';
import 'package:halcyon/widgets/halcyon_controls.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  static final _engine = AudioEngine.instance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HalcyonIconButton(
          icon: PhosphorIconsBold.skipBack,
          tooltip: 'Previous',
          onPressed: doNothing,
        ),
        const SizedBox(width: 2),
        ValueListenableBuilder<bool>(
          valueListenable: _engine.isPlaying,
          builder: (_, playing, _) {
            return HalcyonPrimaryButton(
              icon: playing ? PhosphorIconsFill.pause : PhosphorIconsFill.play,
              tooltip: playing ? 'Pause' : 'Play',
              onPressed: _engine.togglePlayPause,
            );
          },
        ),
        const SizedBox(width: 2),
        const HalcyonIconButton(
          icon: PhosphorIconsBold.skipForward,
          tooltip: 'Next',
          onPressed: doNothing,
        ),
        const SizedBox(width: 2),
        HalcyonIconButton(
          icon: PhosphorIconsBold.stop,
          tooltip: 'Stop',
          onPressed: _engine.stopPlayback,
        ),
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
        ValueListenableBuilder<bool>(
          valueListenable: _engine.repeat,
          builder: (_, active, _) {
            return HalcyonIconButton(
              icon: PhosphorIconsBold.repeat,
              tooltip: 'Repeat',
              isActive: active,
              onPressed: _engine.toggleRepeat,
            );
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
              return HalcyonSlider(value: vol, onChanged: _engine.setVolume);
            },
          ),
        ),
      ],
    );
  }

  static Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 1,
        height: 22,
        color: AppColors.border.withAlpha(150),
      ),
    );
  }
}
