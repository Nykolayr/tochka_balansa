part of 'health_bloc.dart';

sealed class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object> get props => [];
}

/// Загрузка данных о здоровье
class LoadHealthDataEvent extends HealthEvent {}

/// Добавление новой метрики здоровья
class AddHealthMetricEvent extends HealthEvent {
  final HealthMetric metric;

  const AddHealthMetricEvent(this.metric);

  @override
  List<Object> get props => [metric];
}

/// Обновление существующей метрики здоровья
class UpdateHealthMetricEvent extends HealthEvent {
  final HealthMetric metric;

  const UpdateHealthMetricEvent(this.metric);

  @override
  List<Object> get props => [metric];
}

/// Удаление метрики здоровья
class DeleteHealthMetricEvent extends HealthEvent {
  final String metricId;

  const DeleteHealthMetricEvent(this.metricId);

  @override
  List<Object> get props => [metricId];
}
