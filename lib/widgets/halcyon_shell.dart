import 'dart:typed_data';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halcyon/services/audio_engine.dart';
import 'package:halcyon/services/color_palette_service.dart';
import 'package:halcyon/shared.dart';
import 'package:halcyon/theme/app_theme.dart';
import 'package:halcyon/widgets/now_playing_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HalcyonShell extends StatelessWidget {
  final Widget child;

  const HalcyonShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaletteColors?>(
      valueListenable: ColorPaletteService.currentPalette,
      builder: (_, _, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              _shellGlow(),
              Column(
                children: [
                  _buildTitleBar(context),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          const NowPlayingBar(),
                          Expanded(child: child),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shellGlow() {
    return Positioned.fill(
      child: ValueListenableBuilder<Uint8List?>(
        valueListenable: AudioEngine.instance.albumArt,
        builder: (_, art, _) {
          if (art == null || art.isEmpty) {
            return const SizedBox.shrink();
          }
          return ValueListenableBuilder<bool>(
            valueListenable: AudioEngine.instance.isPlaying,
            builder: (_, playing, _) {
              final glowOpacity = playing ? 0.38 : 0.24;
              final overlayOpacity = playing ? 0.2 : 0.12;
              return IgnorePointer(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
                  child: Opacity(
                    opacity: glowOpacity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          art,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.accent.withAlpha(
                                  (overlayOpacity * 255).round(),
                                ),
                                AppColors.background.withAlpha(
                                  (overlayOpacity * 255).round(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: 32,
            child: WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(
                    child: MoveWindow(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  _CustomWindowButtons(context: context),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border.withAlpha(80)),
        ],
      ),
    );
  }
}

class _CustomWindowButtons extends StatelessWidget {
  final BuildContext context;

  const _CustomWindowButtons({required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WindowButton(
          iconBuilder: (context) {
            return PhosphorIcon(
              PhosphorIconsRegular.gear,
              color: AppColors.foreground,
              size: 16,
            );
          },
          builder: (context, child) {
            return child;
          },
          onPressed: () {
            context.go('/settings');
          },
        ),
        WindowButton(
          iconBuilder: (context) {
            return PhosphorIcon(
              PhosphorIconsRegular.minus,
              color: AppColors.foreground,
              size: 16,
            );
          },
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Shared.radius,
                ),
              ),
              child: child,
            );
          },
          onPressed: appWindow.minimize,
        ),
        WindowButton(
          iconBuilder: (context) {
            return PhosphorIcon(
              PhosphorIconsRegular.square,
              color: AppColors.foreground,
              size: 16,
            );
          },
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              color: AppColors.surface,
              child: child,
            );
          },
          onPressed: appWindow.maximizeOrRestore,
        ),
        WindowButton(
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  bottomRight: Shared.radius,
                ),
              ),
              child: child,
            );
          },
          onPressed: appWindow.close,
          iconBuilder: (context) {
            return PhosphorIcon(
              PhosphorIconsRegular.x,
              color: AppColors.foreground,
              size: 16,
            );
          },
        ),
      ],
    );
  }
}
