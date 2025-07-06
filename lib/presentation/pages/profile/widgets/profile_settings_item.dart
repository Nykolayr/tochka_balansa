import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/colors.dart';

class ProfileSettingsItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool showArrow;

  const ProfileSettingsItem({
    super.key,
    required this.child,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Основной контент
                Expanded(child: child),

                // Стрелка (если нужна)
                if (showArrow)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColor.grey,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
