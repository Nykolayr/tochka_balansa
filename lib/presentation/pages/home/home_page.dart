import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/set_first_goal_widget.dart';
import 'package:tochka_balansa/presentation/pages/home/widgets/body_outline_widget.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Загружаем цели при инициализации страницы
    Get.find<GoalBloc>().add(const LoadGoalsEvent());

    // Инициализируем дневную запись калорий и обновляем MainBloc
    _initializeDailyCalories();
  }

  Future<void> _initializeDailyCalories() async {
    final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
    final todayRecord = dailyCaloriesRepo.getOrCreateTodayRecord();

    // Обновляем MainBloc
    final mainBloc = Get.find<MainBloc>();
    mainBloc.add(
      UpdateCaloriesEvent(
        consumedCalories: todayRecord.consumedCalories,
        burnedCalories: todayRecord.burnedCalories,
        maxCalories: todayRecord.maxCalories,
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

          // Если есть главная цель, показываем основную страницу
          return _buildMainContent(state);
        },
      ),
    );
  }

  Widget _buildMainContent(GoalState state) {
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
