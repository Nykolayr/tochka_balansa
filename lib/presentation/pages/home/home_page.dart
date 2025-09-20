import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/set_first_goal_widget.dart';
import 'package:tochka_balansa/presentation/pages/home/widgets/body_outline_widget.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/pages/home/date_navigation_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateNavigationController dateController;

  @override
  void initState() {
    super.initState();
    dateController = Get.find<DateNavigationController>();
    _initializeDailyCalories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeDailyCalories() async {
    // Загружаем калории для выбранной даты
    if (dateController.availableDates.isNotEmpty) {
      await _loadCaloriesForDate(dateController.selectedDate);
    }
  }

  Future<void> _loadCaloriesForDate(DateTime date) async {
    final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
    final userRepository = Get.find<UserRepository>();
    final user = userRepository.user;

    // Проверяем, зарегистрирован ли пользователь
    if (!user.isReg) {
      Logger.i('Пользователь не зарегистрирован, не создаем запись на сегодня');
      return;
    }

    final record = dailyCaloriesRepo.getTodayRecord(date);

    // Обновляем MainBloc
    final mainBloc = Get.find<MainBloc>();
    mainBloc.add(
      UpdateCaloriesEvent(
        consumedCalories: record.consumedCalories,
        burnedCalories: record.burnedCalories,
        maxCalories: record.maxCalories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GoalBloc, GoalState>(
        bloc: Get.find<GoalBloc>(),
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Если нет главной цели, показываем предложение установить цель
          if (!state.mainGoal.hasMainGoal) {
            return const SetFirstGoalWidget();
          }

          // Если есть главная цель, показываем основную страницу с PageView
          return GetBuilder<DateNavigationController>(
            builder: (controller) {
              return controller.availableDates.isEmpty
                  ? const Center(child: Text('Нет доступных записей'))
                  : PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: controller.availableDates.length,
                      physics: controller.availableDates.isEmpty
                          ? const NeverScrollableScrollPhysics()
                          : const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Дополнительная защита - проверяем индекс
                        if (index < 0 ||
                            index >= controller.availableDates.length) {
                          return const Center(child: Text('Ошибка навигации'));
                        }
                        final date = controller.availableDates[index];
                        return _buildPageForDate(date);
                      },
                    );
            },
          );
        },
      ),
    );
  }

  Widget _buildPageForDate(DateTime date) {
    // Загружаем данные для конкретной даты
    _loadCaloriesForDate(date);
    return const Center(child: BodyOutlineWidget());
  }

  Widget buildGoalInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColor.greyText),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
