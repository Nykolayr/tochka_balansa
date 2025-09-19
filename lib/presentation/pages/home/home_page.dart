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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  DateTime _selectedDate = DateTime.now();
  int _currentPage = 0;
  List<DateTime> _availableDates = [];

  @override
  void initState() {
    super.initState();
    // Цели уже загружены в MainPage.initState(), не загружаем повторно

    // Инициализируем дневную запись калорий и обновляем MainBloc
    _initializeDailyCalories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadAvailableDates() {
    final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
    final today = DateTime.now();
    _availableDates = [];

    print('📅 Загружаем доступные даты, проверяем последние 7 дней...');

    // Проверяем последние 7 дней (включая сегодня)
    for (int i = 0; i <= 7; i++) {
      final date = today.subtract(Duration(days: i));
      final record = dailyCaloriesRepo.getTodayRecord(date);

      // Добавляем дату только если есть данные
      if (record.consumedCalories > 0 || record.burnedCalories > 0) {
        _availableDates.add(date);
        print(
          '✅ Найдена запись для ${date.toString().split(' ')[0]}: consumed=${record.consumedCalories}, burned=${record.burnedCalories}',
        );
      } else {
        print(
          '❌ Нет данных для ${date.toString().split(' ')[0]}: consumed=${record.consumedCalories}, burned=${record.burnedCalories}',
        );
      }
    }

    // Сортируем по убыванию (сегодня первым)
    _availableDates.sort((a, b) => b.compareTo(a));

    print('📊 Итого доступных дат: ${_availableDates.length}');
    for (int i = 0; i < _availableDates.length; i++) {
      print('  $i: ${_availableDates[i].toString().split(' ')[0]}');
    }

    // Инициализируем PageController с правильным количеством страниц
    _pageController = PageController(initialPage: 0);
    _currentPage = 0;

    if (_availableDates.isNotEmpty) {
      _selectedDate = _availableDates[0];
      print(
        '🎯 Установлена начальная дата: ${_selectedDate.toString().split(' ')[0]}',
      );
    }
  }

  Future<void> _initializeDailyCalories() async {
    // Сначала загружаем доступные даты
    _loadAvailableDates();

    // Затем загружаем калории для выбранной даты
    if (_availableDates.isNotEmpty) {
      await _loadCaloriesForDate(_selectedDate);
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

  void _onPageChanged(int page) {
    print(
      '🔄 _onPageChanged: page=$page, availableDates.length=${_availableDates.length}',
    );

    // СТРОГАЯ проверка - только существующие страницы
    if (page >= 0 && page < _availableDates.length) {
      print('✅ Переход к странице $page, дата: ${_availableDates[page]}');
      setState(() {
        _currentPage = page;
        _selectedDate = _availableDates[page];
      });
    } else {
      print(
        '❌ ОШИБКА: Попытка перехода к несуществующей странице $page! Возвращаемся к $_currentPage',
      );
      // Если страница не существует, НЕМЕДЛЕННО возвращаемся к текущей позиции
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    }
  }

  void _goToPreviousDay() {
    if (_pageController.hasClients && _canGoToPrevious()) {
      _pageController.previousPage(
        // Левая кнопка = назад (вчера) = previousPage
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextDay() {
    if (_pageController.hasClients && _canGoToNext()) {
      _pageController.nextPage(
        // Правая кнопка = вперед (завтра) = nextPage
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canGoToPrevious() {
    // Можно идти назад, если есть предыдущая страница
    return _currentPage > 0;
  }

  bool _canGoToNext() {
    // Можно идти вперед, если есть следующая страница
    return _currentPage < _availableDates.length - 1;
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

          // Если есть главная цель, показываем основную страницу с навигацией по датам
          return _buildMainContentWithNavigation(state);
        },
      ),
    );
  }

  Widget _buildMainContentWithNavigation(GoalState state) {
    return Column(
      children: [
        // Навигация по датам
        _buildDateNavigation(),
        // Основной контент с PageView
        Expanded(
          child: _availableDates.isEmpty
              ? const Center(child: Text('Нет доступных записей'))
              : PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _availableDates.length,
                  physics: _availableDates.isEmpty
                      ? const NeverScrollableScrollPhysics()
                      : const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    // Дополнительная защита - проверяем индекс
                    if (index < 0 || index >= _availableDates.length) {
                      return const Center(child: Text('Ошибка навигации'));
                    }
                    final date = _availableDates[index];
                    return _buildPageForDate(date);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDateNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Кнопка "Назад" (вчера) - слева
          _canGoToPrevious()
              ? IconButton(
                  onPressed: _goToPreviousDay,
                  icon: const Icon(Icons.chevron_left, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: const CircleBorder(),
                  ),
                )
              : const SizedBox(width: 48), // Заглушка для выравнивания
          // Дата посередине
          Column(
            children: [
              Text(
                _formatDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatWeekday(_selectedDate),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          // Кнопка "Вперед" (завтра) - справа
          _canGoToNext()
              ? IconButton(
                  onPressed: _goToNextDay,
                  icon: const Icon(Icons.chevron_right, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: const CircleBorder(),
                  ),
                )
              : const SizedBox(width: 48), // Заглушка для выравнивания
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Сегодня';
    } else if (targetDate == yesterday) {
      return 'Вчера';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  String _formatWeekday(DateTime date) {
    const weekdays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return weekdays[date.weekday - 1];
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
