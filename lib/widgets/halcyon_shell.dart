import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halcyon/shared.dart';
import 'package:halcyon/theme/app_theme.dart';
import 'package:halcyon/widgets/now_playing_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HalcyonShell extends StatelessWidget {
  final Widget child;

  const HalcyonShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
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
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return ColoredBox(
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
                      child: Container(color: AppColors.surface),
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
            return const PhosphorIcon(
              PhosphorIconsRegular.gear,
              color: Colors.white,
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
            return const PhosphorIcon(
              PhosphorIconsRegular.minus,
              color: Colors.white,
              size: 16,
            );
          },
          builder: (context, child) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(bottomLeft: Shared.radius),
              ),
              child: child,
            );
          },
          onPressed: appWindow.minimize,
        ),
        WindowButton(
          iconBuilder: (context) {
            return const PhosphorIcon(
              PhosphorIconsRegular.square,
              color: Colors.white,
              size: 16,
            );
          },
          builder: (context, child) {
            return ColoredBox(color: AppColors.surface, child: child);
          },
          onPressed: appWindow.maximizeOrRestore,
        ),
        WindowButton(
          builder: (context, child) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(bottomRight: Shared.radius),
              ),
              child: child,
            );
          },
          onPressed: appWindow.close,
          iconBuilder: (context) {
            return const PhosphorIcon(
              PhosphorIconsRegular.x,
              color: Colors.white,
              size: 16,
            );
          },
        ),
      ],
    );
  }
}
