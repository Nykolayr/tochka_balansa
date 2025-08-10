import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/blood_sugar_chart_widget.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_blood_sugar_dialog.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class BloodSugarPage extends StatefulWidget {
  const BloodSugarPage({super.key});

  @override
  State<BloodSugarPage> createState() => _BloodSugarPageState();
}

class _BloodSugarPageState extends State<BloodSugarPage>
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

  void _showAddSugarDialog() {
    AddBloodSugarDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: textLang('Сахар в крови'),
        isBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSugarDialog,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/main/health/blood-sugar/history'),
          ),
        ],
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          final sugarMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.bloodSugar)
              .toList();

          sugarMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          String currentSugar = '--';
          if (sugarMetrics.isNotEmpty) {
            currentSugar = sugarMetrics.first.value;
          }

          DateTime startDate;
          String periodText = '';

          switch (_selectedTabIndex) {
            case 0: // 7 ДНЕЙ
              startDate = DateTime.now().subtract(const Duration(days: 7));
              periodText = textLang('За последние 7 дней');
              break;
            case 1: // ПО ДНЯМ
              startDate = DateTime.now().subtract(const Duration(days: 30));
              periodText = textLang('За последние 30 дней');
              break;
            case 2: // ПО НЕДЕЛЯМ
              startDate = DateTime.now().subtract(const Duration(days: 84));
              periodText = textLang('За последние 12 недель');
              break;
            case 3: // ПО МЕСЯЦАМ
              startDate = DateTime.now().subtract(const Duration(days: 180));
              periodText = textLang('За последние 6 месяцев');
              break;
            default:
              startDate = DateTime.now().subtract(const Duration(days: 7));
              periodText = textLang('За последние 7 дней');
          }

          final filteredMetrics = sugarMetrics
              .where((metric) => metric.timestamp.isAfter(startDate))
              .toList();

          filteredMetrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColor.darkBlue,
                  unselectedLabelColor: AppColor.greyText,
                  indicatorColor: AppColor.darkBlue,
                  labelStyle: const TextStyle(fontSize: 10),
                  unselectedLabelStyle: const TextStyle(fontSize: 10),
                  tabs: [
                    Tab(text: textLang('7 ДНЕЙ')),
                    Tab(text: textLang('ПО ДНЯМ')),
                    Tab(text: textLang('ПО НЕДЕЛЯМ')),
                    Tab(text: textLang('ПО МЕСЯЦАМ')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  periodText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textLang('Текущее значение'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentSugar,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ммоль/л',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.greyText.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        '${textLang('Среднее за период')} (${filteredMetrics.length} ${_getPluralForm(filteredMetrics.length)})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (filteredMetrics.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _calculateAverage(
                              filteredMetrics,
                            ).toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ммоль/л',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.greyText.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BloodSugarChartWidget(
                    metrics: filteredMetrics,
                    selectedTabIndex: _selectedTabIndex,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateAverage(List<HealthMetric> metrics) {
    double sum = 0;
    int count = 0;

    for (final metric in metrics) {
      final value = double.tryParse(metric.value);
      if (value != null) {
        sum += value;
        count++;
      }
    }

    return count > 0 ? sum / count : 0;
  }

  String _getPluralForm(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return textLang('измерение');
    } else if ((count % 10 >= 2 && count % 10 <= 4) &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return textLang('измерения');
    } else {
      return textLang('измерений');
    }
  }
}
