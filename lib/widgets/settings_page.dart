import 'package:flutter/material.dart';
import 'package:halcyon/services/album_art_fit_service.dart';
import 'package:halcyon/services/settings_service.dart';
import 'package:halcyon/theme/app_theme.dart';
import 'package:halcyon/widgets/halcyon_controls.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(String text) {
    if (_searchQuery.isEmpty) {
      return true;
    }
    return text.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return ColorAwareBuilder(
      builder: (context) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search settings...',
                    hintStyle: HalcyonTextStyles.trackMeta.copyWith(
                      color: AppColors.comment,
                    ),
                    prefixIcon: Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                      color: AppColors.comment,
                      size: 18,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(
                                PhosphorIconsRegular.x,
                                color: AppColors.comment,
                                size: 16,
                              ),
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.currentLine.withAlpha(60),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: AppColors.border.withAlpha(60),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: AppColors.border.withAlpha(60),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: AppColors.accent.withAlpha(120),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  style: HalcyonTextStyles.trackMeta.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.border.withAlpha(60)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_matchesSearch('Album Art Interaction'))
                        _buildSettingEntry(
                          'Album Art Interaction',
                          'Choose how to change the album art fit mode',
                          SettingType.stringSelect,
                          _buildAlbumArtInteractionSetting(),
                        ),
                      if (_matchesSearch('Album Art Fit Mode'))
                        _buildSettingEntry(
                          'Album Art Fit Mode',
                          'Select how the album art is displayed',
                          SettingType.stringSelect,
                          _buildAlbumArtFitSetting(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingEntry(
    String title,
    String description,
    SettingType type,
    Widget content,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: HalcyonTextStyles.trackTitle.copyWith(
                                  fontSize: 13,
                                  color: AppColors.foreground,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: HalcyonTextStyles.trackMeta.copyWith(
                            fontSize: 11,
                            color: AppColors.comment,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildTypeTag(type),
                ],
              ),
              const SizedBox(height: 12),
              content,
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.border.withAlpha(40)),
      ],
    );
  }

  Widget _buildTypeTag(SettingType type) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withAlpha(40),
        border: Border.all(color: _getTypeColor(type).withAlpha(100)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.displayName,
        style: HalcyonTextStyles.trackMeta.copyWith(
          fontSize: 9,
          color: _getTypeColor(type),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getTypeColor(SettingType type) {
    return switch (type) {
      .stringSelect => const Color.fromARGB(255, 189, 147, 249),
      .bool => const Color.fromARGB(255, 80, 250, 123),
      .numeric => const Color.fromARGB(255, 139, 233, 253),
      .string => const Color.fromARGB(255, 255, 121, 198),
    };
  }

  Widget _buildAlbumArtInteractionSetting() {
    return ValueListenableBuilder<AlbumArtFitMode>(
      valueListenable: SettingsService.albumArtFitMode,
      builder: (context, mode, _) {
        return Column(
          children: [
            for (final modeOption in AlbumArtFitMode.values)
              _buildRadioOption(
                modeOption.displayName,
                modeOption.description,
                modeOption == mode,
                () {
                  SettingsService.setAlbumArtFitMode(modeOption);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildAlbumArtFitSetting() {
    return ValueListenableBuilder<AlbumArtFit>(
      valueListenable: AlbumArtFitService.currentFitNotifier,
      builder: (context, fit, _) {
        return Column(
          children: [
            for (final fitOption in AlbumArtFit.values)
              _buildRadioOption(
                fitOption.displayName,
                _getFitDescription(fitOption),
                fitOption == fit,
                () async {
                  while (AlbumArtFitService.currentFit != fitOption) {
                    await AlbumArtFitService.cycleFit();
                  }
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildRadioOption(
    String title,
    String description,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.comment,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: HalcyonTextStyles.trackTitle.copyWith(
                        fontSize: 12,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: HalcyonTextStyles.trackMeta.copyWith(
                        fontSize: 10,
                        color: AppColors.comment,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFitDescription(AlbumArtFit fit) {
    return switch (fit) {
      .cover => 'Scale to fill, maintaining aspect ratio',
      .zoom => 'Scale to fill completely, may crop',
      .stretch => 'Stretch to fit without maintaining aspect ratio',
    };
  }
}
