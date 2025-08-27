import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/pages/main/enum/enum_main_page.dart';
import 'package:tochka_balansa/presentation/pages/main/widgets/navigation_buttons.dart';
import 'package:tochka_balansa/presentation/pages/main/widgets/oval_bottom_bar.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  final MainBloc bloc = Get.find<MainBloc>();
  final PageController pageController = PageController();

  /// нажатие на таб
  void onItemTapped(int index) {
    if (selectedIndex == index) return;
    setState(() {
      selectedIndex = index;
    });

    // Обновляем состояние блока
    bloc.add(GoToPageEvent(index));
    // Используем анимацию только для соседних табов
    if ((index - selectedIndex).abs() == 1) {
      // Анимируем переход для соседних табов
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Мгновенный переход для дальних табов
      pageController.jumpToPage(index);
    }
  }

  @override
  void initState() {
    super.initState();

    // Загружаем данные при инициализации страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalBloc = Get.find<GoalBloc>();
      goalBloc.add(const LoadGoalsEvent()); // Загружаем все цели и типы целей

      final healthBloc = Get.find<HealthBloc>();
      healthBloc.add(LoadHealthDataEvent());
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: ScaffoldMessenger(
        child: BlocBuilder<MainBloc, MainState>(
          bloc: bloc,
          builder: (context, state) {
            // Обновляем selectedIndex, если он изменился в state
            if (state.selectedIndex != selectedIndex) {
              // Используем Future.microtask, чтобы избежать setState во время build
              Future.microtask(() {
                setState(() {
                  selectedIndex = state.selectedIndex;
                });
                // Переключаем страницу
                if ((state.selectedIndex - selectedIndex).abs() == 1) {
                  pageController.animateToPage(
                    state.selectedIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  pageController.jumpToPage(state.selectedIndex);
                }
              });
            }

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  return;
                }
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                extendBody: true, // Добавляем это чтобы контент шел под табами
                backgroundColor: AppColor.white,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: MainPages.values[selectedIndex].appBar,
                ),
                body: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 60,
                      ), // Добавляем отступ снизу
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: pageController,
                        onPageChanged: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        children: MainPages.values.map((e) => e.page).toList(),
                      ),
                    ),
                    if (state.isLoading) ...[
                      const Center(
                        child: CircularProgressIndicator(color: AppColor.white),
                      ),
                    ],
                    // Овал с табами поверх контента
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Stack(
                        children: [
                          const OvalBottomBar(),
                          NavigationButtons(
                            selectedIndex: selectedIndex,
                            onItemTapped: onItemTapped,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
