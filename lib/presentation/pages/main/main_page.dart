import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/pages/main/enum_main_page.dart';
import 'package:tochka_balansa/presentation/pages/main/widgets/navigation_buttons.dart';
import 'package:tochka_balansa/presentation/pages/main/widgets/oval_bottom_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  MainBloc bloc = Get.find<MainBloc>();
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
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: BlocBuilder<MainBloc, MainState>(
        bloc: bloc,
        builder: (context, state) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: AppColor.white,
            resizeToAvoidBottomInset: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: MainPages.values[selectedIndex].appBar,
            ),
            bottomNavigationBar: Stack(
              children: [
                // Овальный фон
                const OvalBottomBar(),
                // Кнопки навигации поверх
                NavigationButtons(
                  selectedIndex: selectedIndex,
                  onItemTapped: onItemTapped,
                ),
              ],
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 90),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
