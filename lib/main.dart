import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:halcyon/router/app_router.dart';
import 'package:halcyon/services/album_art_fit_service.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/services/settings_service.dart';
import 'package:halcyon/theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await AudioEngine.instance.init();
  await AlbumArtFitService.init();
  await SettingsService.init();
  runApp(const HalcyonApp());
  await Window.setEffect(effect: WindowEffect.acrylic);
  doWhenWindowReady(() {
    appWindow.minSize = const Size(720, 400);
    appWindow.size = const Size(900, 520);
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Halcyon';
    appWindow.show();
  });
}

class HalcyonApp extends StatelessWidget {
  const HalcyonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Halcyon',
      theme: buildDraculaTheme(),
      routerConfig: AppRouter.router,
    );
  }
}
