import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/health_repository.dart';

part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final HealthRepository _healthRepository = Get.find<HealthRepository>();

  HealthBloc() : super(HealthState.initial()) {
    on<LoadHealthDataEvent>(_onLoadHealthData);
    on<AddHealthMetricEvent>(_onAddHealthMetric);
    on<UpdateHealthMetricEvent>(_onUpdateHealthMetric);
    on<DeleteHealthMetricEvent>(_onDeleteHealthMetric);

    // Инициализация блока (без автоматической загрузки данных)
    Logger.i('HealthBloc: Инициализация блока');
  }

  Future<void> _onLoadHealthData(
    LoadHealthDataEvent event,
    Emitter<HealthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _healthRepository.loadHealthDataFromLocal();
      emit(
        state.copyWith(
          healthData: _healthRepository.healthData,
          isLoading: false,
        ),
      );
      Logger.i(
        'Загружено метрик здоровья: ${_healthRepository.healthData.metrics.length}',
      );
    } catch (e) {
      Logger.e('Ошибка загрузки данных о здоровье: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Ошибка загрузки данных о здоровье',
        ),
      );
    }
  }

  Future<void> _onAddHealthMetric(
    AddHealthMetricEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      final updatedMetrics = List<HealthMetric>.from(state.healthData.metrics)
        ..add(event.metric);

      final updatedHealthData = state.healthData.copyWith(
        metrics: updatedMetrics,
      );

      _healthRepository.healthData = updatedHealthData;
      await _healthRepository.saveHealthDataToLocal();

      emit(state.copyWith(healthData: updatedHealthData));
      Logger.i('Добавлена метрика здоровья: ${event.metric.type.name}');
    } catch (e) {
      Logger.e('Ошибка добавления метрики здоровья: $e');
      emit(state.copyWith(error: 'Ошибка добавления показателя здоровья'));
    }
  }

  Future<void> _onUpdateHealthMetric(
    UpdateHealthMetricEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      final updatedMetrics = state.healthData.metrics.map((metric) {
        return metric.id == event.metric.id ? event.metric : metric;
      }).toList();

      final updatedHealthData = state.healthData.copyWith(
        metrics: updatedMetrics,
      );

      _healthRepository.healthData = updatedHealthData;
      await _healthRepository.saveHealthDataToLocal();

      emit(state.copyWith(healthData: updatedHealthData));
      Logger.i('Обновлена метрика здоровья: ${event.metric.id}');
    } catch (e) {
      Logger.e('Ошибка обновления метрики здоровья: $e');
      emit(state.copyWith(error: 'Ошибка обновления показателя здоровья'));
    }
  }

  /// Сброс состояния блока (без emit)
  void reset() {
    Logger.i('HealthBloc: состояние сброшено');
  }

  Future<void> _onDeleteHealthMetric(
    DeleteHealthMetricEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      final updatedMetrics = state.healthData.metrics
          .where((metric) => metric.id != event.metricId)
          .toList();

      final updatedHealthData = state.healthData.copyWith(
        metrics: updatedMetrics,
      );

      _healthRepository.healthData = updatedHealthData;
      await _healthRepository.saveHealthDataToLocal();

      emit(state.copyWith(healthData: updatedHealthData));
      Logger.i('Удалена метрика здоровья: ${event.metricId}');
    } catch (e) {
      Logger.e('Ошибка удаления метрики здоровья: $e');
      emit(state.copyWith(error: 'Ошибка удаления показателя здоровья'));
    }
  }
}
