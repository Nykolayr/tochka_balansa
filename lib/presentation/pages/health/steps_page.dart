import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/steps_chart_widget.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_steps_dialog.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  void _showAddStepsDialog() {
    AddStepsDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: textLang('Шаги'),
        isBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStepsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/main/health/steps/history'),
          ),
        ],
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          final stepsMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.steps)
              .toList();

          stepsMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          int currentSteps = 0;
          if (stepsMetrics.isNotEmpty) {
            currentSteps = int.tryParse(stepsMetrics.first.value) ?? 0;
          }

          DateTime startDate;
          String periodText = '';

          switch (_selectedTabIndex) {
            case 0: // 7 дней
              startDate = DateTime.now().subtract(const Duration(days: 6));
              periodText = textLang('За последние 7 дней');
              break;
            case 1: // По дням
              startDate = DateTime.now().subtract(const Duration(days: 29));
              periodText = textLang('По дням за месяц');
              break;
            case 2: // По неделям
              startDate = DateTime.now().subtract(const Duration(days: 89));
              periodText = textLang('По неделям за 3 месяца');
              break;
            case 3: // По месяцам
              startDate = DateTime.now().subtract(const Duration(days: 364));
              periodText = textLang('По месяцам за год');
              break;
            default:
              startDate = DateTime.now().subtract(const Duration(days: 6));
              periodText = textLang('За последние 7 дней');
          }

          final filteredMetrics = stepsMetrics
              .where((m) => m.timestamp.isAfter(startDate))
              .toList();

          // Вычисляем среднее количество шагов за период
          double averageSteps = 0;
          if (filteredMetrics.isNotEmpty) {
            final totalSteps = filteredMetrics
                .map((m) => int.tryParse(m.value) ?? 0)
                .reduce((a, b) => a + b);
            averageSteps = totalSteps / filteredMetrics.length;
          }

          return Column(
            children: [
              // Вкладки
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColor.darkBlue,
                  unselectedLabelColor: AppColor.greyText,
                  indicatorColor: AppColor.darkBlue,
                  tabs: [
                    Tab(text: textLang('7 дней')),
                    Tab(text: textLang('По дням')),
                    Tab(text: textLang('По неделям')),
                    Tab(text: textLang('По месяцам')),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Текущие значения
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      textLang('Текущие шаги'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.greyText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentSteps.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    Text(
                                      textLang('шагов'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      textLang('Среднее за период'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.greyText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      averageSteps.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    Text(
                                      textLang('шагов'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // График
                      if (filteredMetrics.isNotEmpty)
                        StepsChartWidget(
                          metrics: filteredMetrics,
                          selectedTabIndex: _selectedTabIndex,
                        ),

                      // Период
                      if (filteredMetrics.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            periodText,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.greyText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],

                      // Пустое состояние
                      if (filteredMetrics.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_walk,
                                size: 64,
                                color: AppColor.greyText.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                textLang(
                                  'Нет данных о шагах за выбранный период',
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColor.greyText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
