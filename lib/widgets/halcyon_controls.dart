import 'package:flutter/material.dart';
import 'package:halcyon/shared.dart';
import 'package:halcyon/theme/app_theme.dart';

class HalcyonIconButton extends StatefulWidget {
  const HalcyonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 18,
    this.padding = const EdgeInsets.all(6),
    this.tooltip,
    this.color,
    this.hoverColor,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final EdgeInsets padding;
  final String? tooltip;
  final Color? color;
  final Color? hoverColor;
  final bool isActive;

  @override
  State<HalcyonIconButton> createState() {
    return _HalcyonIconButtonState();
  }
}

class _HalcyonIconButtonState extends State<HalcyonIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor =
        widget.color ??
        (widget.isActive ? AppColors.accent : AppColors.foreground);
    final effectiveColor = _hovered
        ? (widget.hoverColor ?? AppColors.accentHover)
        : baseColor;

    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _hovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Padding(
            padding: widget.padding,
            child: Icon(widget.icon, size: widget.size, color: effectiveColor),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

class HalcyonPrimaryButton extends StatefulWidget {
  const HalcyonPrimaryButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 30,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  State<HalcyonPrimaryButton> createState() {
    return _HalcyonPrimaryButtonState();
  }
}

class _HalcyonPrimaryButtonState extends State<HalcyonPrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _hovered ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: _hovered ? AppColors.accentHover : AppColors.accent,
            ),
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

class HalcyonSlider extends StatelessWidget {
  const HalcyonSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: Theme.of(context).sliderTheme.copyWith(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.surfaceLight,
        thumbColor: AppColors.accent,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: Shared.radiusValue,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
      ),
      child: Slider(value: value, min: min, max: max, onChanged: onChanged),
    );
  }
}

class HalcyonPanel extends StatelessWidget {
  const HalcyonPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.border = true,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: Shared.borderRadius,
      ),
      child: child,
    );
  }
}
