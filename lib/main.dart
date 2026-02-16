import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:halcyon/router/app_router.dart';
import 'package:halcyon/services/album_art_fit_service.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/services/color_palette_service.dart';
import 'package:halcyon/services/playlist_service.dart';
import 'package:halcyon/services/settings_service.dart';
import 'package:halcyon/theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await AudioEngine.instance.init();
  await AlbumArtFitService.init();
  await SettingsService.init();
  await ColorPaletteService.init();
  await PlaylistService.init();
  runApp(const HalcyonApp());
  if (Platform.isWindows || Platform.isMacOS) {
    await Window.setEffect(effect: WindowEffect.acrylic);
  } else {
    await Window.setEffect(effect: WindowEffect.transparent);
  }
  doWhenWindowReady(() {
    appWindow.minSize = const Size(720, 400);
    appWindow.size = const Size(900, 520);
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Halcyon';
    appWindow.show();
  });
}

class HalcyonApp extends StatefulWidget {
  const HalcyonApp({super.key});

  @override
  State<HalcyonApp> createState() => _HalcyonAppState();
}

class _HalcyonAppState extends State<HalcyonApp>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _paletteController;
  PaletteColors? _fromPalette;
  PaletteColors? _toPalette;
  VoidCallback? _paletteListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _paletteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(_onPaletteTick);
    _paletteListener = () {
      _onPaletteChange(ColorPaletteService.palette.value);
    };
    ColorPaletteService.palette.addListener(_paletteListener!);
    _onPaletteChange(ColorPaletteService.palette.value, jump: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _paletteController
      ..removeListener(_onPaletteTick)
      ..dispose();
    if (_paletteListener != null) {
      ColorPaletteService.palette.removeListener(_paletteListener!);
      _paletteListener = null;
    }
    AudioEngine.instance.dispose();
    ColorPaletteService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      AudioEngine.instance.stopPlayback();
    }
    super.didChangeAppLifecycleState(state);
  }

  void _onPaletteChange(PaletteColors? next, {bool jump = false}) {
    if (jump) {
      _fromPalette = next;
      _toPalette = next;
      ColorPaletteService.currentPalette.value = next;
      return;
    }
    final current = ColorPaletteService.currentPalette.value;
    if (current == null && next == null) {
      return;
    }
    _fromPalette = current ?? next;
    _toPalette = next ?? current;
    if (_fromPalette == null || _toPalette == null) {
      ColorPaletteService.currentPalette.value = next;
      return;
    }
    _paletteController
      ..stop()
      ..value = 0
      ..forward();
  }

  void _onPaletteTick() {
    if (_fromPalette == null || _toPalette == null) {
      return;
    }
    final t = Curves.easeInOutCubic.transform(_paletteController.value);
    ColorPaletteService.currentPalette.value = PaletteColors.lerp(
      _fromPalette!,
      _toPalette!,
      t,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaletteColors?>(
      valueListenable: ColorPaletteService.currentPalette,
      builder: (_, __, ___) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Halcyon',
          theme: buildDraculaTheme(),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
