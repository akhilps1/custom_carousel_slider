import 'dart:async';
import 'dart:developer';
import 'package:custom_carousal_slider/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ChildBuilderParams {
  ChildBuilderParams(this.index, this.opacity);

  final int index;
  final int opacity;
}

class CustomCarouselSlider extends StatefulWidget {
  const CustomCarouselSlider({
    super.key,
    this.width,
    required this.height,
    required this.childBuilder,
    required this.length,
    this.borderRadius = 10,
    this.childClick,
    this.trailingChildWidth = 30,
    this.spacing = 5.0,
    this.autoSlide = true,
    this.autoPlayDelay = 5000,
    this.slideAnimationDuration = 800,
    this.titleFadeAnimationDuration = 500,
    this.titleTextSize = 16,
  });
  final int length;
  final Widget Function(int) childBuilder;
  final double? width;
  final double height;
  final void Function(int)? childClick;
  final double trailingChildWidth;
  final double borderRadius;
  final double spacing;
  final bool autoSlide;
  final int autoPlayDelay;
  final int slideAnimationDuration;
  final int titleFadeAnimationDuration;
  final double titleTextSize;

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  late double useWidth;
  late double useHeight;
  List<Map> builtChildren = [];
  int activeIndex = 1;
  Timer? runner;
  bool isDragging = false;

  void updateSlabs(bool isInit, int direction) {
    if (builtChildren.length == 1) {
      setState(() {
        builtChildren[0]['width'] = useWidth - widget.trailingChildWidth;
      });
      return;
    }

    for (int a = 0; a < builtChildren.length; a++) {
      builtChildren[a]['width'] = 0.0;
      builtChildren[a]['marginRight'] = 0.0;
      builtChildren[a]['opacity'] = 0.0;
    }

    double partialWidth = widget.trailingChildWidth;
    double fullWidth = useWidth - (partialWidth + widget.spacing);

    if (activeIndex == 0) {
      builtChildren[activeIndex]['width'] = fullWidth;
      builtChildren[activeIndex]['marginRight'] = widget.spacing;
      builtChildren[activeIndex]['opacity'] = 1.0;

      if (activeIndex + 1 < builtChildren.length) {
        builtChildren[activeIndex + 1]['width'] = partialWidth;
        builtChildren[activeIndex + 1]['marginRight'] = 0.0;
        builtChildren[activeIndex + 1]['opacity'] = 1.0;
        builtChildren[activeIndex + 1]['direction'] = 1;
      }
    } else if (activeIndex == builtChildren.length - 1) {
      if (activeIndex - 1 >= 0) {
        builtChildren[activeIndex - 1]['width'] = partialWidth;
        builtChildren[activeIndex - 1]['marginRight'] = widget.spacing;
        builtChildren[activeIndex - 1]['opacity'] = 1.0;
        builtChildren[activeIndex - 1]['direction'] = 0;
      }

      builtChildren[activeIndex]['width'] = fullWidth;
      builtChildren[activeIndex]['marginRight'] = 0.0;
      builtChildren[activeIndex]['opacity'] = 1.0;
    } else {
      if (activeIndex - 1 >= 0) {
        builtChildren[activeIndex - 1]['width'] = partialWidth;
        builtChildren[activeIndex - 1]['marginRight'] = widget.spacing;
        builtChildren[activeIndex - 1]['opacity'] = 1.0;
      }

      builtChildren[activeIndex]['width'] =
          fullWidth - widget.trailingChildWidth - widget.spacing;
      builtChildren[activeIndex]['marginRight'] = widget.spacing;
      builtChildren[activeIndex]['opacity'] = 1.0;

      if (activeIndex + 1 < builtChildren.length) {
        builtChildren[activeIndex + 1]['width'] = partialWidth;
        builtChildren[activeIndex + 1]['marginRight'] = 0.0;
        builtChildren[activeIndex + 1]['opacity'] = 1.0;
        builtChildren[activeIndex + 1]['direction'] = 1;
        builtChildren[activeIndex - 1]['direction'] = 0;
      }
    }

    return setState(() {});
  }

  @override
  void initState() {
    super.initState();
    for (int a = 0; a < widget.length; a++) {
      builtChildren.add({
        "width": 0.0,
        "marginRight": 0.0,
        "opacity": 0.0,
        "direction": 0,
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateSlabs(false, 0);

      // if (widget.autoSlide) {
      //   runner = Timer(Duration(seconds: 1), () {
      //     if (isDragging) return;
      //     if ((builtChildren.length < 2)) return;
      //     if ((activeIndex + 1) < builtChildren.length) {
      //       activeIndex++;
      //     } else {
      //       activeIndex = 0;
      //     }
      //     updateSlabs(false, 1);
      //   });
      // }
    });
  }

  @override
  void dispose() {
    if (runner != null) {
      runner?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        useWidth = constraints.maxWidth;
        useHeight = widget.height;
        return GestureDetector(
          // Your existing gesture detector code
          onHorizontalDragStart: (details) {
            isDragging = true;
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            isDragging = false;
            if (details.primaryVelocity! > (kIsWeb ? 0 : 300)) {
              // swipe left
              if ((builtChildren.length < 2)) return;
              if (activeIndex != 0) {
                activeIndex--;
                updateSlabs(false, 0);
              }
            } else if (details.primaryVelocity! < -(kIsWeb ? 0 : 300)) {
              // swipe right
              if ((builtChildren.length < 2)) return;
              if (activeIndex + 1 < builtChildren.length) {
                activeIndex++;
                updateSlabs(false, 1);
              }
            }
          },
          child: SizedBox(
            height: widget.height + 20,
            child: Stack(
              children: [
                CustomScrollView(
                  // Wrap your Row with a ListView
                  scrollDirection: Axis.horizontal,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: builtChildren.asMap().entries.length,
                        (ctx, index) {
                          final listItem =
                              builtChildren.asMap().entries.toList()[index];
                          log(listItem.toString());
                          return InkWell(
                            onTap: widget.childClick == null
                                ? null
                                : () {
                                    log(listItem.value['width'].toString());
                                    if (listItem.value['width'] ==
                                        widget.trailingChildWidth) {
                                      if (listItem.value['direction'] == 1 &&
                                          activeIndex + 1 <
                                              builtChildren.length) {
                                        activeIndex++;
                                        updateSlabs(false, 1);
                                      } else if (listItem.value['direction'] ==
                                              0 &&
                                          activeIndex > 0) {
                                        activeIndex--;
                                        updateSlabs(false, 0);
                                      }
                                      return;
                                    }
                                    widget.childClick!(listItem.key);
                                  },

                            // Your existing InkWell child
                            child: Container(
                              margin: EdgeInsets.only(
                                right: listItem.value['marginRight'],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(widget.borderRadius),
                                ),
                                child: AnimatedContainer(
                                  color: Colors.blue,
                                  duration: Duration(
                                    milliseconds: widget.slideAnimationDuration,
                                  ),
                                  width: listItem.value['width'],
                                  height: useHeight,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        images[index],
                                        fit: BoxFit.cover,
                                        width: double.maxFinite,
                                        height: double.maxFinite,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 10),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.5)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: AnimatedOpacity(
                                            opacity: double.parse(listItem
                                                .value['opacity']
                                                .toString()),
                                            duration: Duration(
                                              milliseconds: widget
                                                  .titleFadeAnimationDuration,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSmoothIndicator(
                        activeIndex: activeIndex,
                        count: widget.length,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.blue,
                          dotColor: Colors.grey.shade400,
                          paintStyle: PaintingStyle.fill,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
