import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'video_editor_configurable.dart';

class VideoEditorTrimBar extends StatefulWidget {
  final double videoDuration;
  final ValueChanged<Duration> onTrimStartChanged;
  final ValueChanged<Duration> onTrimEndChanged;
  final List<ImageProvider> thumbnails;

  const VideoEditorTrimBar({
    super.key,
    required this.videoDuration,
    required this.onTrimStartChanged,
    required this.onTrimEndChanged,
    required this.thumbnails,
  });

  @override
  _VideoEditorTrimBarState createState() => _VideoEditorTrimBarState();
}

class _VideoEditorTrimBarState extends State<VideoEditorTrimBar> {
  double trimStart = 0;
  double trimEnd = 1;
  double _scale = 1.0;
  double _baseScale = 1.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 3.0;

  double get minTrimPercentage =>
      VideoEditorConfigurable.of(context).configs.minTrimDuration.inSeconds /
      widget.videoDuration;

  void _updateTrimStart(double value) {
    setState(() {
      double minEnd = value + minTrimPercentage;
      trimStart = value;
      trimEnd = max(trimEnd, minEnd);

      if (trimEnd > 1) {
        trimStart = 1 - minTrimPercentage;
        trimEnd = 1;
      }

      widget.onTrimStartChanged(
          Duration(seconds: (trimStart * widget.videoDuration).toInt()));
    });
  }

  void _updateTrimEnd(double value) {
    setState(() {
      double minStart = value - minTrimPercentage;
      trimEnd = value;
      trimStart = min(trimStart, minStart);

      if (trimStart < 0) {
        trimStart = 0;
        trimEnd = minTrimPercentage;
      }

      widget.onTrimEndChanged(
          Duration(seconds: (trimEnd * widget.videoDuration).toInt()));
    });
  }

  String _formatTime(double value) {
    int totalSeconds = (value * widget.videoDuration).toInt();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  double get _minInteractiveDimension =>
      Theme.of(context).materialTapTargetSize == MaterialTapTargetSize.padded
          ? kMinInteractiveDimension
          : 0;

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    return player.widgets.trimBar ??
        RepaintBoundary(
          child: LayoutBuilder(builder: (_, constraints) {
            double editorWidth = constraints.maxWidth;
            double scaledWidth = editorWidth * _scale;
            double trimWidth = (trimEnd - trimStart) * scaledWidth;
            double offsetLeftHandler = trimStart * scaledWidth;
            double offsetRightHandler = trimEnd * scaledWidth -
                max(_minInteractiveDimension, player.style.trimBarHandlerWidth);

            return Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  double scaleChange = -event.scrollDelta.dy * 0.1;
                  setState(() {
                    _scale = (_scale + scaleChange).clamp(_minScale, _maxScale);
                  });
                }
              },
              child: GestureDetector(
                onScaleStart: (ScaleStartDetails details) {
                  _baseScale = _scale;
                },
                onScaleUpdate: (ScaleUpdateDetails details) {
                  setState(() {
                    _scale = (_baseScale * details.scale)
                        .clamp(_minScale, _maxScale);
                  });
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: scaledWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Stack(
                            children: [
                              Container(
                                height: player.style.trimBarHeight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 51, 51, 51),
                                  borderRadius: BorderRadius.circular(
                                      player.style.trimBarHandlerRadius),
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.thumbnails.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 50 * _scale,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: widget.thumbnails[index],
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            player.style.trimBarHandlerRadius),
                                      ),
                                    );
                                  },
                                  physics: const NeverScrollableScrollPhysics(),
                                ),
                              ),
                              Positioned(
                                left: offsetLeftHandler,
                                child: Container(
                                  width: trimWidth,
                                  height: player.style.trimBarHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: player.style.trimBarBackground,
                                        width: 3),
                                    borderRadius: BorderRadius.circular(
                                        player.style.trimBarHandlerRadius),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: offsetLeftHandler,
                                width: offsetRightHandler - offsetLeftHandler,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onHorizontalDragUpdate: (details) {
                                    double factor =
                                        details.primaryDelta! / scaledWidth;
                                    double newValueStart = trimStart + factor;
                                    double newValueEnd = trimEnd + factor;
                                    if (newValueStart >= 0 &&
                                        newValueEnd <= 1) {
                                      _updateTrimStart(newValueStart);
                                      _updateTrimEnd(newValueEnd);
                                    } else if (newValueEnd > 1) {
                                      double diff = 1 - trimEnd;
                                      _updateTrimStart(trimStart + diff);
                                      _updateTrimEnd(trimEnd + diff);
                                    } else if (newValueStart < 0) {
                                      _updateTrimStart(0);
                                      _updateTrimEnd(trimEnd - trimStart);
                                    }
                                  },
                                  child: _buildTrimHandle(player, true),
                                ),
                              ),
                              Positioned(
                                left: offsetLeftHandler,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onHorizontalDragUpdate: (details) {
                                    double newValue = trimStart +
                                        details.primaryDelta! / scaledWidth;
                                    _updateTrimStart(max(0, newValue));
                                  },
                                  child: _buildTrimHandle(player, true),
                                ),
                              ),
                              Positioned(
                                left: offsetRightHandler,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onHorizontalDragUpdate: (details) {
                                    double newValue = trimEnd +
                                        details.primaryDelta! / scaledWidth;
                                    _updateTrimEnd(min(1, newValue));
                                  },
                                  child: _buildTrimHandle(player, false),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTimeText(player, trimStart),
                              _buildTimeText(player, trimEnd),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
  }

  Widget _buildTimeText(VideoEditorConfigurable player, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: player.style.trimBarTextBackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          _formatTime(value),
          style: TextStyle(color: player.style.trimBarTextColor),
        ),
      ),
    );
  }

  Widget _buildTrimHandle(VideoEditorConfigurable player, bool isLeft) {
    return SizedBox(
      width: max(_minInteractiveDimension, player.style.trimBarHandlerWidth),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          width: player.style.trimBarHandlerWidth,
          height: player.style.trimBarHeight,
          decoration: BoxDecoration(
            color: player.style.trimBarBackground,
            borderRadius: BorderRadius.horizontal(
              left: isLeft
                  ? Radius.circular(player.style.trimBarHandlerRadius)
                  : Radius.zero,
              right: isLeft
                  ? Radius.zero
                  : Radius.circular(player.style.trimBarHandlerRadius),
            ),
          ),
          child: Center(
            child: Icon(
              isLeft ? player.icons.trimLeft : player.icons.trimRight,
              color: player.style.trimBarColor,
              size: player.style.trimBarHandlerIconSize,
            ),
          ),
        ),
      ),
    );
  }
}
