import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:tochka_balansa/presentation/widgets/app_title.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animations = List.generate(3, (index) {
      final delay = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.5, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = screenWidth * 0.6;

    return Scaffold(
      body: Stack(
        children: [
          // Основной контент
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(50),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SvgPicture.asset(
                    'assets/svg/logo.svg',
                    width: logoWidth,
                    height: logoWidth,
                    fit: BoxFit.cover,
                  ),
                ),
                const Gap(100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _animations[index],
                      builder: (context, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor.withAlpha(
                              (_animations[index].value * 255).toInt(),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          // Заголовок поверх контента
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppTitle(),
            ),
          ),
        ],
      ),
    );
  }
}
