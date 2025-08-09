import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_metric_dialog.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_weight_dialog.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/weight_block_widget.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/blood_pressure_block_widget.dart'
    hide Get, Navigator;
import 'package:tochka_balansa/presentation/pages/health/weight_page.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final UserRepository userRepository = Get.find<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          // Получаем последнее измерение веса
          HealthMetric? latestWeight;
          if (state.healthData.metrics.isNotEmpty) {
            final weightMetrics = state.healthData.metrics
                .where((m) => m.type == HealthMetricType.weight)
                .toList();
            if (weightMetrics.isNotEmpty) {
              weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              latestWeight = weightMetrics.first;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Блок о весе
                WeightBlockWidget(
                  latestWeight: latestWeight,
                  onAddWeightPressed: () => AddWeightDialog.show(context),
                  onViewWeightPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const WeightPage()),
                  ),
                ),

                // Блок давления и пульса (показывается при наличии данных)
                const BloodPressureBlockWidget(),

                // Отступ снизу для FAB
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddMetricDialog.show(context),
        backgroundColor: AppColor.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
