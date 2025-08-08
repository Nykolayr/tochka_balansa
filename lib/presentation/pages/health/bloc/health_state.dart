part of 'health_bloc.dart';

class HealthState extends Equatable {
  final HealthData healthData;
  final bool isLoading;
  final String? error;

  const HealthState({
    required this.healthData,
    required this.isLoading,
    this.error,
  });

  factory HealthState.initial() =>
      HealthState(healthData: HealthData.initial(), isLoading: false);

  HealthState copyWith({
    HealthData? healthData,
    bool? isLoading,
    String? error,
  }) {
    return HealthState(
      healthData: healthData ?? this.healthData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [healthData, isLoading, error];
}
