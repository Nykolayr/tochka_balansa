import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'tape_slider_painter.dart';

class CustomTapeSlider extends StatefulWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final Function(double) onValueChanged;
  final Axis orientation;
  final double itemExtent;
  final Color activeColor;
  final Color inactiveColor;
  final double trackHeight;
  final double trackWidth;
  final TextStyle majorTickLabelStyle;
  final TextStyle minorTickLabelStyle;
  final bool showLabels;
  final double indicatorThickness;
  final Color indicatorColor;
  final int tickInterval;
  final int labelInterval;
  final double slidingAreaExtent;

  const CustomTapeSlider({
    super.key,
    this.initialValue = 50.0,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    required this.onValueChanged,
    this.orientation = Axis.horizontal,
    this.itemExtent = 15.0,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.trackHeight = 100.0,
    this.trackWidth = double.infinity,
    this.majorTickLabelStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.minorTickLabelStyle = const TextStyle(
      fontSize: 12,
      color: Colors.white70,
    ),
    this.showLabels = true,
    this.indicatorThickness = 2.0,
    this.indicatorColor = Colors.white,
    this.tickInterval = 1,
    this.labelInterval = 5,
    this.slidingAreaExtent = 250.0,
  });

  @override
  State<CustomTapeSlider> createState() => _CustomTapeSliderState();
}

class _CustomTapeSliderState extends State<CustomTapeSlider> {
  late double currentValue;
  ScrollController? _scrollController;
  bool _isAnimating = false;
  double? _padding;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isHorizontal = widget.orientation == Axis.horizontal;
    final screenSize = MediaQuery.of(context).size;
    final newPadding = isHorizontal
        ? screenSize.width / 2
        : screenSize.height / 2;
    if (_padding != newPadding) {
      _padding = newPadding;
      _initOrUpdateScrollController();
    }
  }

  void _initOrUpdateScrollController() {
    if (_scrollController != null) {
      _scrollController!.removeListener(_updateCurrentValue);
      _scrollController!.dispose();
    }
    final initialValueInt = currentValue.roundToDouble();
    final initialOffset =
        (initialValueInt - widget.minValue) * widget.itemExtent;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController!.addListener(_updateCurrentValue);
  }

  void _updateCurrentValue() {
    if (!(_scrollController?.hasClients ?? false)) return;
    final offset = _scrollController!.offset;
    final newValue = widget.minValue + (offset / widget.itemExtent);
    final snappedValue = newValue.round().toDouble();
    final clampedValue = math.max(
      widget.minValue,
      math.min(widget.maxValue, snappedValue),
    );
    if (clampedValue != currentValue) {
      setState(() {
        currentValue = clampedValue;
        widget.onValueChanged(currentValue);
      });
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_updateCurrentValue);
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHorizontal = widget.orientation == Axis.horizontal;
    final screenSize = MediaQuery.of(context).size;
    final _ = isHorizontal ? screenSize.width / 2 : screenSize.height / 2;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isHorizontal ? double.infinity : widget.trackHeight,
        maxHeight: isHorizontal ? widget.trackHeight : double.infinity,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification && !_isAnimating) {
                _isAnimating = true;
                final snappedValue = currentValue.roundToDouble();
                final targetOffset =
                    (snappedValue - widget.minValue) * widget.itemExtent;
                _scrollController
                    ?.animateTo(
                      targetOffset,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    )
                    .then((_) {
                      _isAnimating = false;
                    });
              }
              return true;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: widget.orientation,
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: isHorizontal
                    ? (widget.maxValue - widget.minValue) * widget.itemExtent +
                          screenSize.width
                    : widget.trackHeight,
                height: isHorizontal
                    ? widget.trackHeight
                    : (widget.maxValue - widget.minValue) * widget.itemExtent +
                          screenSize.height,
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? screenSize.width / 2 : 0,
                  vertical: isHorizontal ? 0 : screenSize.height / 2,
                ),
                child: CustomPaint(
                  painter: TapeScalePainter(
                    min: widget.minValue,
                    max: widget.maxValue,
                    itemExtent: widget.itemExtent,
                    orientation: widget.orientation,
                    activeColor: widget.activeColor,
                    inactiveColor: widget.inactiveColor,
                    majorTickLabelStyle: widget.majorTickLabelStyle,
                    minorTickLabelStyle: widget.minorTickLabelStyle,
                    showLabels: widget.showLabels,
                    tickInterval: widget.tickInterval,
                    labelInterval: widget.labelInterval,
                  ),
                  size: Size(
                    isHorizontal
                        ? (widget.maxValue - widget.minValue) *
                              widget.itemExtent
                        : widget.trackHeight,
                    isHorizontal
                        ? widget.trackHeight
                        : (widget.maxValue - widget.minValue) *
                              widget.itemExtent,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: isHorizontal
                ? widget.indicatorThickness
                : widget.slidingAreaExtent,
            height: isHorizontal ? 70 : widget.indicatorThickness,
            decoration: BoxDecoration(
              color: widget.indicatorColor,
              border: Border.all(
                color: widget.indicatorColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
