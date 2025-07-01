import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/pages/main/enum/enum_main_page.dart';

class NavigationButtons extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavigationButtons({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < MainPages.values.length; i++)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onItemTapped(i),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: AppColor.darkBlue.withValues(alpha: 0.05),
                    highlightColor: AppColor.darkBlue.withValues(alpha: 0.02),
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MainPages.values[i].icon,
                            size: 24,
                            color: selectedIndex == i
                                ? AppColor.white
                                : AppColor.noactive,
                          ),

                          const Gap(7),
                          Text(
                            MainPages.values[i].title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selectedIndex == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selectedIndex == i
                                  ? AppColor.white
                                  : AppColor.noactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
