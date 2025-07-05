import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tochka_balansa/data/models/slide_model.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

/// Виджет слайда
class SlideWidget extends StatelessWidget {
  final SlideModel slide;
  final bool isActive;

  const SlideWidget({super.key, required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(100),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                slide.image,
                width: MediaQuery.of(context).size.width - 40,
                height: (MediaQuery.of(context).size.width - 40) * 0.8,
                fit: BoxFit.cover,
              ),
            ),
            const Gap(20),
            Text(
              textLang(slide.title),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(20),
            Text(
              textLang(slide.description),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
