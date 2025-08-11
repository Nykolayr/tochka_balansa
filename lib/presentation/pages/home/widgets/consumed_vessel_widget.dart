import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class ConsumedVesselWidget extends StatefulWidget {
  final bool isVessel;
  final int value;
  final Function(int) onTap;
  const ConsumedVesselWidget({
    super.key,
    required this.isVessel,
    required this.value,
    required this.onTap,
  });

  @override
  State<ConsumedVesselWidget> createState() => _ConsumedVesselWidgetState();
}

class _ConsumedVesselWidgetState extends State<ConsumedVesselWidget> {
  Color color = AppColor.vesselBlue;
  String text = textLang('съедено');

  @override
  void initState() {
    super.initState();
    if (!widget.isVessel) {
      color = AppColor.green;
      text = textLang('сожжено');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: EdgeInsets.only(
        left: widget.isVessel ? 0 : 10,
        right: widget.isVessel ? 10 : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const Gap(8),
          Text(
            widget.value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Gap(8),
          Container(
            width: double.infinity,

            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 250 * 0.6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: color, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
