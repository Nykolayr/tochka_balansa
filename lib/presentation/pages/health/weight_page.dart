import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_weight_dialog.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/weight_forecast_widget.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/weight_chart_widget.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/core/constants/test_data.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // ВРЕМЕННАЯ ФУНКЦИЯ ДЛЯ ТЕСТИРОВАНИЯ - УБРАТЬ ПОСЛЕ ПРОВЕРКИ!
  List<HealthMetric> generateTestWeightData() {
    final now = DateTime.now();

    // Создаем HealthMetric объекты
    final testMetrics = <HealthMetric>[];

    for (final data in TestData.weightData) {
      final date = now.subtract(
        Duration(days: data['daysOffset'] as int),
      ); // ИСПРАВЛЕНО: отнимаем дни
      final metric = HealthMetric(
        id: 'test_${date.millisecondsSinceEpoch}',
        type: HealthMetricType.weight,
        value: data['weight'].toString(),
        timestamp: date,
        note: 'Тестовые данные',
      );
      testMetrics.add(metric);
    }

    return testMetrics;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: textLang('Вес'),
        isBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AddWeightDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/main/health/weight/history'),
          ),
        ],
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          // Убираем тестовые данные, используем реальные
          final weightMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.weight)
              .toList();

          // Сортируем по дате (новые сверху для списка, старые сверху для графика)
          weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Получаем желаемый вес из главной цели пользователя
          final userRepository = Get.find<UserRepository>();
          final initialWeight = userRepository.user.initialWeight;
          final targetWeight = userRepository.user.mainGoal.targetWeight;

          // Получаем текущий вес (последнее измерение)
          final currentWeight = weightMetrics.isNotEmpty
              ? double.tryParse(weightMetrics.first.value) ?? initialWeight
              : initialWeight;

          // Разница между текущим и начальным весом
          final weightDifference = currentWeight - initialWeight;
          final weightDifferenceText = weightDifference >= 0
              ? '+${weightDifference.toStringAsFixed(1)}'
              : weightDifference.toStringAsFixed(1);

          // Определяем период для отображения (всегда фиксированный)
          DateTime startDate;
          String periodText = '';

          switch (_selectedTabIndex) {
            case 0: // ПО ДНЯМ
              startDate = DateTime.now().subtract(const Duration(days: 30));
              periodText = textLang('За последние 30 дней');
              break;
            case 1: // ПО НЕДЕЛЯМ
              startDate = DateTime.now().subtract(
                const Duration(days: 84),
              ); // 12 недель
              periodText = textLang('За последние 12 недель');
              break;
            case 2: // ПО МЕСЯЦАМ
              startDate = DateTime.now().subtract(
                const Duration(days: 180),
              ); // 6 месяцев
              periodText = textLang('За последние 6 месяцев');
              break;
            default:
              startDate = DateTime.now().subtract(const Duration(days: 30));
              periodText = textLang('За последние 30 дней');
          }

          // Фильтруем измерения по выбранному периоду
          final filteredMetrics = weightMetrics
              .where(
                (metric) => metric.timestamp.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ),
              )
              .toList();

          // Сортируем для графика (новые сначала для свайпа)
          filteredMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Табы для переключения периодов
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColor.darkBlue,
                  unselectedLabelColor: AppColor.greyText,
                  indicatorColor: AppColor.darkBlue,
                  tabs: [
                    Tab(text: textLang('ПО ДНЯМ')),
                    Tab(text: textLang('ПО НЕДЕЛЯМ')),
                    Tab(text: textLang('ПО МЕСЯЦАМ')),
                  ],
                ),
              ),

              // Заголовок периода
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  periodText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Информация о весе
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint(
                      textLang('Исходный вес'),
                      '$initialWeight кг',
                      Colors.black,
                    ),
                    _buildBulletPoint(
                      textLang('Желаемый вес'),
                      '$targetWeight кг',
                      AppColor.green,
                    ),
                    _buildBulletPoint(
                      textLang('Сейчас'),
                      '${currentWeight.toStringAsFixed(1)} кг',
                      Colors.black,
                    ),
                    _buildBulletPoint(
                      textLang('Разница'),
                      '$weightDifferenceText кг',
                      weightDifference <= 0 ? AppColor.green : Colors.red,
                    ),
                    // Прогноз - отдельный виджет
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: WeightForecastWidget(
                        weightMetrics: weightMetrics,
                        targetWeight: targetWeight,
                        initialWeight: initialWeight,
                      ),
                    ),
                  ],
                ),
              ),

              // График веса - отдельный виджет
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WeightChartWidget(
                    metrics: filteredMetrics,
                    targetWeight: targetWeight,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBulletPoint(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColor.darkBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.black)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}
