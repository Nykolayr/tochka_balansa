import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class CustomAnimatedWeightPicker extends StatefulWidget {
  final double min;
  final double max;
  final double division;
  final double squeeze;
  final double dialHeight;
  final double dialThickness;
  final Color dialColor;
  final int majorIntervalAt;
  final double majorIntervalHeight;
  final double majorIntervalThickness;
  final Color majorIntervalColor;
  final bool showMajorIntervalText;
  final double majorIntervalTextSize;
  final Color majorIntervalTextColor;
  final int subIntervalAt;
  final double subIntervalHeight;
  final double subIntervalThickness;
  final Color subIntervalColor;
  final bool showSubIntervalText;
  final double subIntervalTextSize;
  final Color subIntervalTextColor;
  final double minorIntervalHeight;
  final double minorIntervalThickness;
  final Color minorIntervalColor;
  final bool showMinorIntervalText;
  final double minorIntervalTextSize;
  final Color minorIntervalTextColor;
  final bool showSelectedValue;
  final Color selectedValueColor;
  final TextStyle? selectedValueStyle;
  final bool showSuffix;
  final String suffixText;
  final Color suffixTextColor;
  final Widget? suffix;
  final Function(String newValue)? onChange;
  final double initialValue;

  const CustomAnimatedWeightPicker({
    super.key,
    required this.min,
    required this.max,
    this.division = 0.5,
    this.squeeze = 2.5,
    this.dialHeight = 50,
    this.dialThickness = 1.5,
    this.dialColor = Colors.green,
    this.majorIntervalAt = 10,
    this.majorIntervalHeight = 18,
    this.majorIntervalThickness = 1,
    this.majorIntervalColor = Colors.grey,
    this.showMajorIntervalText = true,
    this.majorIntervalTextSize = 15,
    this.majorIntervalTextColor = Colors.grey,
    this.minorIntervalHeight = 10,
    this.minorIntervalThickness = 1,
    this.minorIntervalColor = Colors.grey,
    this.showMinorIntervalText = false,
    this.minorIntervalTextSize = 15,
    this.minorIntervalTextColor = Colors.grey,
    this.subIntervalAt = 5,
    this.subIntervalHeight = 15,
    this.subIntervalThickness = 1,
    this.subIntervalColor = Colors.grey,
    this.showSubIntervalText = false,
    this.subIntervalTextSize = 5,
    this.subIntervalTextColor = Colors.grey,
    this.showSelectedValue = true,
    this.selectedValueColor = Colors.green,
    this.selectedValueStyle,
    this.showSuffix = true,
    this.suffixText = 'Kg',
    this.suffixTextColor = Colors.green,
    this.suffix,
    this.onChange,
    required this.initialValue,
  }) : assert(!(max < min)),
       assert(!(min == max)),
       assert(!(max < 1)),
       assert(!(min < 0)),
       assert(!(max > 1000)),
       assert(!(dialHeight > 110 || dialHeight < 3)),
       assert(!(dialThickness > 5 || dialThickness < 0.5)),
       assert(!(majorIntervalHeight > 110 || majorIntervalHeight < 3)),
       assert(!(majorIntervalAt > max || majorIntervalAt < 1)),
       assert(!(majorIntervalThickness > 5 || majorIntervalThickness < 0.5)),
       assert(!(minorIntervalHeight > 110 || minorIntervalHeight < 3)),
       assert(!(minorIntervalThickness > 5 || minorIntervalThickness < 0.5)),
       assert(!(subIntervalAt > max || subIntervalAt < 1)),
       assert(!(subIntervalHeight > 110 || subIntervalHeight < 3)),
       assert(!(subIntervalThickness > 5 || subIntervalThickness < 0.5)),
       assert(!(majorIntervalTextSize > 20 || majorIntervalTextSize < 1)),
       assert(!(minorIntervalTextSize > 20 || minorIntervalTextSize < 1)),
       assert(!(subIntervalTextSize > 20 || subIntervalTextSize < 1)),
       assert(!(division < 0.1 || division > 1)),
       assert(squeeze > 0);

  @override
  State<CustomAnimatedWeightPicker> createState() =>
      _CustomAnimatedWeightPickerState();
}

class _CustomAnimatedWeightPickerState
    extends State<CustomAnimatedWeightPicker> {
  final int _divisionPrecision = 1;
  final int _valuePrecision = 1;

  final List<WheelModel> _valueList = [];
  int _selectedIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    createWeightList(onInit: true);

    int initialIndex = 0;
    for (int i = 0; i < _valueList.length; i++) {
      if (double.parse(_valueList[i].value) >= widget.initialValue) {
        initialIndex = i;
        break;
      }
    }
    _selectedIndex = initialIndex;

    _scrollController = ScrollController(
      initialScrollOffset: initialIndex * 30.0,
    );

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        int currentIndex = (_scrollController.offset / 30.0).round();
        if (currentIndex != _selectedIndex &&
            currentIndex < _valueList.length) {
          print(
            'ScrollController listener: $currentIndex, value: ${_valueList[currentIndex].value}',
          );
          setState(() {
            _selectedIndex = currentIndex;
          });
          if (widget.onChange != null) {
            widget.onChange!(_valueList[currentIndex].value);
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onChange != null) {
        widget.onChange!(_valueList[_selectedIndex].value);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void createWeightList({required bool onInit}) {
    _valueList.clear();
    double current = widget.min;
    double interval = widget.division.toPrecision(_divisionPrecision);

    int mjInterval = 0;
    int subInterval = widget.subIntervalAt;
    int mnInterval = 1;
    int currentIndex = 0;

    do {
      _valueList.add(
        WheelModel(
          current.toPrecision(_valuePrecision).toString().trimTrallingZero(),
          currentIndex == 0
              ? INTERVAL_TYPE.MINOR
              : mjInterval == currentIndex
              ? INTERVAL_TYPE.MAJOR
              : subInterval == currentIndex
              ? INTERVAL_TYPE.SUB
              : mnInterval == currentIndex
              ? INTERVAL_TYPE.MINOR
              : INTERVAL_TYPE.NONE,
        ),
      );
      if (currentIndex == mjInterval) mjInterval += widget.majorIntervalAt;
      if (currentIndex == subInterval) subInterval += widget.subIntervalAt * 2;
      if (currentIndex == mnInterval) mnInterval += 1;

      currentIndex++;
      current += interval;
    } while (current.toPrecision(2) <= widget.max);
    if (!onInit) setState(() {});
  }

  @override
  void didUpdateWidget(covariant CustomAnimatedWeightPicker old) {
    super.didUpdateWidget(old);
    if (old.max == widget.max &&
        old.min == widget.min &&
        old.division.toPrecision(_divisionPrecision) ==
            widget.division.toPrecision(_divisionPrecision))
      return;
    createWeightList(onInit: false);
  }

  @override
  Widget build(BuildContext context) {
    print(
      'Build: _selectedIndex = $_selectedIndex, value = ${_valueList.isNotEmpty ? _valueList[_selectedIndex].value : "empty"}',
    );
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 110,
          width: double.infinity,
          child: RotatedBox(
            quarterTurns: -45,
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              offAxisFraction: 2,
              perspective: 0.003,
              itemExtent: 30,
              squeeze: widget.squeeze,
              overAndUnderCenterOpacity: 1,
              clipBehavior: Clip.none,
              onSelectedItemChanged: (index) {
                print(
                  'onSelectedItemChanged: $index, value: ${_valueList[index].value}',
                );
                setState(() => _selectedIndex = index);
                if (widget.onChange == null) return;
                widget.onChange!(_valueList[index].value);
              },
              renderChildrenOutsideViewport: true,
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List<Widget>.generate(
                  _valueList.length,
                  growable: false,
                  (index) {
                    bool isSelected = _selectedIndex == index;
                    bool isMajorInterval =
                        !isSelected &&
                        _valueList[index].interval == INTERVAL_TYPE.MAJOR &&
                        (_selectedIndex != 0 || _valueList.length - 1 != index);
                    bool isSubInterval =
                        !isSelected &&
                        !isMajorInterval &&
                        _valueList[index].interval == INTERVAL_TYPE.SUB &&
                        index != _valueList.length - 1;
                    bool isMinorInterval =
                        !isSelected &&
                        !isMajorInterval &&
                        !isSubInterval &&
                        (_valueList[index].interval == INTERVAL_TYPE.MINOR ||
                            index == _valueList.length - 1);

                    return RotatedBox(
                      quarterTurns: 45,
                      child: Container(
                        height: double.infinity,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: isSelected
                                  ? widget.dialHeight
                                  : isMajorInterval
                                  ? widget.majorIntervalHeight
                                  : isSubInterval
                                  ? widget.subIntervalHeight
                                  : isMinorInterval
                                  ? widget.minorIntervalHeight
                                  : widget.minorIntervalHeight,
                              child: VerticalDivider(
                                thickness: isSelected
                                    ? 1.0
                                    : isMajorInterval
                                    ? widget.majorIntervalThickness
                                    : isSubInterval
                                    ? widget.subIntervalThickness
                                    : isMinorInterval
                                    ? widget.minorIntervalThickness
                                    : widget.minorIntervalThickness,
                                color: isSelected
                                    ? AppColor.red
                                    : isMajorInterval
                                    ? widget.majorIntervalColor
                                    : isSubInterval
                                    ? widget.subIntervalColor
                                    : isMinorInterval
                                    ? widget.minorIntervalColor
                                    : widget.minorIntervalColor,
                                endIndent: 0,
                                indent: 0,
                              ),
                            ),
                            if ((widget.showMajorIntervalText &&
                                    isMajorInterval) ||
                                (widget.showMinorIntervalText &&
                                    isMinorInterval) ||
                                (widget.showSubIntervalText && isSubInterval))
                              Text(
                                _valueList[index].value,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontSize: _valueList[index].value.length >= 4
                                      ? 12
                                      : isMajorInterval
                                      ? widget.majorIntervalTextSize
                                      : isSubInterval
                                      ? widget.subIntervalTextSize
                                      : widget.minorIntervalTextSize,
                                  color: isMajorInterval
                                      ? widget.majorIntervalTextColor
                                      : isSubInterval
                                      ? widget.subIntervalTextColor
                                      : widget.minorIntervalTextColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (widget.showSelectedValue)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _valueList[_selectedIndex].value,
                style:
                    widget.selectedValueStyle ??
                    TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      height: 1,
                      color: widget.selectedValueColor,
                    ),
              ),
              if (widget.showSuffix && widget.suffix == null)
                Text(
                  widget.suffixText,
                  style: TextStyle(color: widget.suffixTextColor),
                )
              else if (widget.showSuffix && widget.suffix != null)
                widget.suffix!,
            ],
          ),
      ],
    );
  }
}

class WheelModel {
  final String value;
  final INTERVAL_TYPE interval;

  WheelModel(this.value, this.interval);
}

enum INTERVAL_TYPE { MAJOR, SUB, MINOR, NONE }

extension DoubleExtension on double {
  double toPrecision(int precision) {
    return double.parse(toStringAsFixed(precision));
  }
}

extension StringExtension on String {
  String trimTrallingZero() {
    if (contains('.')) {
      return replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return this;
  }
}
