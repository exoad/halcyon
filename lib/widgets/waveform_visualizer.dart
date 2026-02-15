import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/shared.dart';
import 'package:halcyon/theme/app_theme.dart';

class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({super.key, this.height = 80, this.barCount = 64});

  final double height;

  final int barCount;

  @override
  State<WaveformVisualizer> createState() {
    return _WaveformVisualizerState();
  }
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  AudioData? _audioData;
  late Float32List _bars;
  late Float32List _prevBars;
  late Float32List _targetBars;
  final _painterNotifier = ValueNotifier<int>(0);
  static const double _smoothing = 0.08;
  static const double _decay = 0.92;

  @override
  void initState() {
    super.initState();
    _bars = Float32List(widget.barCount);
    _prevBars = Float32List(widget.barCount);
    _targetBars = Float32List(widget.barCount);
    try {
      _audioData = AudioData(GetSamplesKind.wave);
    } catch (_) {}
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioData?.dispose();
    _painterNotifier.dispose();
    super.dispose();
  }

  void _onTick(Duration _) {
    if (!mounted) {
      return;
    }
    final engine = AudioEngine.instance;
    Float32List? samples;
    if (engine.isPlaying.value && _audioData != null) {
      try {
        _audioData!.updateSamples();
        samples = _audioData!.getAudioData();
      } catch (_) {}
    }
    _updateBars(samples);
    _painterNotifier.value++;
  }

  void _updateBars(Float32List? samples) {
    final count = widget.barCount;
    if (samples != null && samples.isNotEmpty) {
      final sampleCount = samples.length;
      for (var i = 0; i < count; i++) {
        final progress = i / (count - 1).clamp(1, double.infinity);
        final startIdx = (progress * sampleCount * 0.05).toInt();
        final endIdx = (progress * sampleCount * 0.99).toInt().clamp(
          0,
          sampleCount - 1,
        );
        if (startIdx >= sampleCount) {
          _targetBars[i] = 0;
          continue;
        }
        double maxMagnitude = 0;
        final rangeSize = math.max(1, endIdx - startIdx);
        final step = math.max(1, rangeSize ~/ 20);
        for (var j = startIdx; j <= endIdx; j += step) {
          maxMagnitude = math.max(
            maxMagnitude,
            samples[j.clamp(0, sampleCount - 1)].abs(),
          );
        }
        _targetBars[i] = math.pow(maxMagnitude, 0.6).clamp(0.0, 1.0) as double;
      }
    } else {
      for (var i = 0; i < count; i++) {
        _targetBars[i] = 0;
      }
    }
    for (var i = 0; i < count; i++) {
      _bars[i] = _prevBars[i] + (_smoothing * (_targetBars[i] - _prevBars[i]));
      if (samples == null || samples.isEmpty) {
        _bars[i] = _prevBars[i] * _decay;
      }
      _bars[i] = _bars[i].clamp(0.0, 1.0);
      if (_bars[i] < 0.001) {
        _bars[i] = 0;
      }
    }
    _prevBars.setAll(0, _bars);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: ValueListenableBuilder<int>(
          valueListenable: _painterNotifier,
          builder: (_, _, _) {
            return CustomPaint(
              painter: _WaveformPainter(bars: _bars, barCount: widget.barCount),
            );
          },
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final Float32List bars;
  final int barCount;

  _WaveformPainter({required this.bars, required this.barCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (barCount <= 0) {
      return;
    }
    final barWidth = size.width / barCount;
    final gap = math.max(1, barWidth * 0.2);
    final effectiveBarWidth = barWidth - gap;
    if (effectiveBarWidth <= 0) {
      return;
    }
    final paint = Paint()..style = PaintingStyle.fill;
    final midY = size.height / 2;
    for (var i = 0; i < barCount; i++) {
      final value = bars[i].clamp(0.0, 1.0);
      final halfBar = math.max(2, value * size.height * 0.9) / 2;
      final x = i * barWidth + gap / 2;
      paint.color = Color.lerp(
        AppColors.surfaceLight,
        AppColors.accent,
        value,
      )!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            x,
            midY - halfBar,
            x + effectiveBarWidth,
            midY + halfBar,
          ),
          Shared.radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return true;
  }
}
