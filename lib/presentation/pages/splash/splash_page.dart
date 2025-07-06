import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/di/locator.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/data/repositories/main_repository.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/widgets/app_title.dart';
import 'loading_widget.dart';
import 'slide_widget.dart';
import 'package:tochka_balansa/presentation/widgets/buttons.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final PageController _pageController = PageController();
  late final MainRepository _repository;
  late final UserRepository _userRepository;
  int _currentPage = 0;
  bool _userInteracted = false;
  Timer? _autoSlideTimer;
  bool _isMainInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Инициализация основного функционала
      await initMain();

      // Получаем репозитории после инициализации
      _repository = Get.find<MainRepository>();
      _userRepository = Get.find<UserRepository>();

      if (mounted) {
        setState(() {
          _isMainInitialized = true;
        });

        // Проверяем, заполнены ли данные пользователя
        final user = _userRepository.user;
        final hasUserData = user.name.isEmpty;

        // Если данные не заполнены, загружаем слайды
        if (hasUserData) {
          await _initializeSlides();
        } else {
          // Если данные заполнены, сразу переходим на главный экран
          if (mounted) {
            context.go('/main');
          }
        }
      }
    } catch (e) {
      Logger.e('Error initializing main: $e');
    }
  }

  /// Инициализируем слайды
  Future<void> _initializeSlides() async {
    try {
      await _repository.getSlides();
      if (mounted) {
        setState(() {
          _currentPage = 0;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(0);
        });
        if (!_userInteracted) {
          _startAutoSlide();
        }
      }
    } catch (e) {
      Logger.e('Error initializing slides: $e');
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_userInteracted && mounted) {
        // Проверяем, не достигли ли мы последнего слайда
        if (_currentPage < _repository.slides.length - 1) {
          final nextPage = _currentPage + 1;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          // Достигли последнего слайда - останавливаем таймер
          timer.cancel();
          _autoSlideTimer = null; // Очищаем ссылку на таймер
        }
      } else {
        // Пользователь взаимодействовал или виджет размонтирован - останавливаем таймер
        timer.cancel();
        _autoSlideTimer = null;
      }
    });
  }

  void _handleUserInteraction() {
    if (!_userInteracted) {
      setState(() {
        _userInteracted = true;
      });
      _autoSlideTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Показываем экран загрузки, пока не инициализирован основной функционал
    if (!_isMainInitialized) {
      return const LoadingWidget();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Основной контент
          GestureDetector(
            onPanUpdate: (details) {
              _handleUserInteraction();
              if (details.delta.dx > 0) {
                // Свайп вправо - назад
                if (_currentPage > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } else if (details.delta.dx < 0) {
                // Свайп влево - вперед
                if (_currentPage < _repository.slides.length - 1) {
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
                        _currentPage = index;
                      });
                      // Останавливаем автопрокрутку если достигли последнего слайда
                      if (index >= _repository.slides.length - 1) {
                        _autoSlideTimer?.cancel();
                      }
                    },
                    itemCount: _repository.slides.length,
                    itemBuilder: (context, index) {
                      return SlideWidget(
                        slide: _repository.slides[index],
                        isActive: _currentPage == index,
                      );
                    },
                  ),
                ),
                // Индикаторы слайдов
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _repository.slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColor.darkBlue
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ),
                // Кнопки управления
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RoundedWideButton(
                          text: textLang('Назад'),
                          onPressed: _currentPage > 0
                              ? () {
                                  _handleUserInteraction();
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : () {},
                          enabled: _currentPage > 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RoundedWideButton(
                          text: _currentPage < _repository.slides.length - 1
                              ? textLang('Далее')
                              : textLang('Начать'),
                          onPressed:
                              _currentPage < _repository.slides.length - 1
                              ? () {
                                  _handleUserInteraction();
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : () {
                                  context.goNamed('данные пользователя');
                                },
                          enabled: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Заголовок поверх контента
          Positioned(
            top: MediaQuery.of(context).padding.top + 30,
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
