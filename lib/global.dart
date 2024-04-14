import 'package:halcyon/snd/audio_engine.dart';

final class Halcyon {
  late HalcyonAudioEngine audioEngine;

  Halcyon._();

  Future<void> ensureInitialized() async {
    audioEngine = HalcyonAudioEngine();
  }

  static final Halcyon instance = Halcyon._();
}

final class HalcyonManager {
  HalcyonManager._();

  static const double kBorderRadius = 6;
}
