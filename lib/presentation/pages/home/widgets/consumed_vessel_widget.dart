import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class ConsumedVesselWidget extends StatefulWidget {
  final bool isVessel;
  final int value;
  final Function(int) onTap;
  final int maxValue; // НОВОЕ: максимальное значение для расчета процента

  const ConsumedVesselWidget({
    super.key,
    required this.isVessel,
    required this.value,
    required this.onTap,
    this.maxValue = 3500,
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
    // Защита от отрицательных значений
    final safeValue = widget.value < 0 ? 0 : widget.value;
    final safeMaxValue = widget.maxValue <= 0 ? 2000 : widget.maxValue;

    // Рассчитываем процент заполнения
    final percentage = safeMaxValue > 0 ? safeValue / safeMaxValue : 0.0;
    final clampedPercentage = percentage.clamp(0.0, 1.0);

    return Container(
      height: 370,
      margin: EdgeInsets.only(
        left: widget.isVessel ? 0 : 10,
        right: widget.isVessel ? 10 : 0,
      ),
      child: Column(
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
            safeValue.toString(), // Используем безопасное значение
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Gap(8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Высота рассчитывается на основе процента
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 250 * clampedPercentage, // Динамическая высота
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
                      child: GestureDetector(
                        // НОВОЕ: добавляю GestureDetector
                        onTap: () =>
                            widget.onTap(widget.value), // НОВОЕ: вызываю onTap
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            border: Border.all(color: color, width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, color: color, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
