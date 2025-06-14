import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/data/repositories/main_repository.dart';
import 'slide_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final PageController _pageController = PageController();
  final MainRepository repo = Get.find<MainRepository>();
  int currentPage = 0;
  bool _userInteracted = false;
  Timer? autoSlideTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!_userInteracted) {
        _startAutoSlide();
      }
    });
  }

  void _startAutoSlide() {
    autoSlideTimer?.cancel();
    autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_userInteracted && mounted) {
        final nextPage = (currentPage + 1) % repo.slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleUserInteraction() {
    if (!_userInteracted) {
      setState(() {
        _userInteracted = true;
      });
      autoSlideTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (repo.slides.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Точка Баланса: умный помощник для поддержания физического равновесия и веса',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          _handleUserInteraction();
          if (details.delta.dx > 0) {
            // Свайп вправо - назад
            if (currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          } else if (details.delta.dx < 0) {
            // Свайп влево - вперед
            if (currentPage < repo.slides.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        },
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemCount: repo.slides.length,
                itemBuilder: (context, index) {
                  return SlideWidget(
                    slide: repo.slides[index],
                    isActive: currentPage == index,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка "Назад"
                  if (currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _handleUserInteraction();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Назад'),
                    )
                  else
                    const SizedBox(width: 80),

                  // Индикаторы слайдов
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      repo.slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),

                  // Кнопка "Далее" или "Начать"
                  SizedBox(
                    width: 80,
                    child: currentPage < repo.slides.length - 1
                        ? TextButton(
                            onPressed: () {
                              _handleUserInteraction();
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Далее'),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              context.go('/auth');
                            },
                            child: const Text('Начать'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
