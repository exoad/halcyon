import 'package:flutter/material.dart';
import 'package:halcyon/debug.dart';
import 'package:halcyon/extern/string.dart';
import 'package:halcyon/ui/h_timeseek_slider.dart';
import 'package:halcyon/ui/layout/h_audio_controller_btns.dart';
import 'package:halcyon/ui/layout/h_bbloc.dart';
import 'package:halcyon/ui/layout/vert_counselor.dart';
import 'package:halcyon/ux/laf_config/halcyon_laf_config.dart';
import 'package:multi_split_view/multi_split_view.dart';

class H_VerticalAppLayout extends StatefulWidget {
  const H_VerticalAppLayout({super.key});

  @override
  State<H_VerticalAppLayout> createState() =>
      _H_VerticalAppLayoutState();
}

class _H_VerticalAppLayoutState extends State<H_VerticalAppLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: MultiSplitViewTheme(
            data: MultiSplitViewThemeData(dividerThickness: 8),
            child: MultiSplitView(
                dividerBuilder: (Axis axis,
                    int index,
                    bool resizable,
                    bool dragging,
                    bool highlighted,
                    MultiSplitViewThemeData themeData) {
                  return Center(
                      child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: Colors.black),
                  ));
                },
                initialAreas: <Area>[
                  Area(
                      weight: H_VerticalAppLayoutCounselor
                          .TOP_LAYOUT_SIZE_INITIAL_WEIGHT_RATIO,
                      minimalSize:
                          MediaQuery.of(context).size.height *
                              H_VerticalAppLayoutCounselor
                                  .TOP_LAYOUT_SIZE_MIN_WEIGHT_RATIO)
                ],
                axis: Axis.vertical,
                children: const <Widget>[
                  H_VTopLayer(),
                  H_VBottomLayer(),
                ]),
          ),
        ),
        H_BBlocContainer(children: <H_BBlocItem>[
          H_BBlocItem(
              activeColor: HalcyonLaFConfig
                  .instance.bbloc_MenuActiveColor.coerceToColorObj,
              inactiveColor: HalcyonLaFConfig
                  .instance.bbloc_MenuInactiveColor.coerceToColorObj,
              childActiveColor: HalcyonLaFConfig.instance
                  .bbloc_MenuChildActiveColor.coerceToColorObj,
              childInactiveColor: HalcyonLaFConfig.instance
                  .bbloc_MenuChildInactiveColor.coerceToColorObj,
              onPressed: () {},
              child: Icons.menu_rounded),
          H_BBlocItem(
              activeColor: HalcyonLaFConfig
                  .instance.bbloc_ItemActiveColor.coerceToColorObj,
              inactiveColor: HalcyonLaFConfig
                  .instance.bbloc_ItemInactiveColor.coerceToColorObj,
              childActiveColor: HalcyonLaFConfig.instance
                  .bbloc_ItemChildActiveColor.coerceToColorObj,
              childInactiveColor: HalcyonLaFConfig.instance
                  .bbloc_ItemChildInactiveColor.coerceToColorObj,
              onPressed: () =>
                  Debugger.LOG.info("DEBUG BUTTON PRESSED"),
              child: Icons.bug_report_rounded)
        ])
      ],
    ));
  }
}

class H_VTopLayer extends StatelessWidget {
  const H_VTopLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            HalcyonLaFConfig.instance
                                .trackDisplay_ArtworkCornerRadius),
                        child: Image.network(
                            fit: HalcyonLaFConfig.instance
                                .trackDisplay_ArtworkFitStrategy.fit,
                            "https://picsum.photos/600",
                            width: MediaQuery.of(context).size.width,
                            height:
                                MediaQuery.of(context).size.height),
                      ),
                    )),
                Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Song Name",
                                      style: TextStyle(
                                          fontSize: HalcyonLaFConfig
                                              .instance
                                              .trackDisplay_TrackNameFontSize,
                                          fontWeight: FontWeight
                                              .values[HalcyonLaFConfig
                                                  .instance
                                                  .trackDisplay_TrackNameFontWeight ~/
                                              100])),
                                  Text("Artist Name",
                                      style: TextStyle(
                                          fontSize: HalcyonLaFConfig
                                              .instance
                                              .trackDisplay_TrackSecondaryInfoFontSize,
                                          fontWeight: FontWeight
                                              .values[HalcyonLaFConfig
                                                  .instance
                                                  .trackDisplay_TrackSecondaryInfoFontWeight ~/
                                              100])),
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  H_AudioSecondaryControllerButtons(
                                      icon:
                                          Icons.skip_previous_rounded,
                                      onPressed: () {}),
                                  H_AudioPrimaryControllerButtons(
                                      icon: Icons.play_arrow_rounded,
                                      onPressed: () {}),
                                  H_AudioSecondaryControllerButtons(
                                      icon: Icons.skip_next_rounded,
                                      onPressed: () {})
                                ])
                          ]),
                    )),
              ]),
        ),
        H_TimeseekSlider(
            onChanged: (double e) {},
            activeColor: HalcyonLaFConfig
                .instance.timeSeek_ActiveTrackColor.coerceToColorObj,
            inactiveColor: HalcyonLaFConfig.instance
                .timeSeek_InactiveTrackColor.coerceToColorObj,
            secondaryActiveColor: HalcyonLaFConfig.instance
                .timeSeek_SecondaryActiveColor.coerceToColorObj,
            thumbColor: HalcyonLaFConfig
                .instance.timeSeek_ThumbColor.coerceToColorObj)
      ],
    );
  }
}

class H_VBottomLayer extends StatelessWidget {
  const H_VBottomLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
