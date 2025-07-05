part of 'main_bloc.dart';

class MainState extends Equatable {
  final bool isLoading;
  final String error;
  final User user;
  final bool isListChange;
  final int selectedIndex;
  final bool shouldRefresh;

  bool get isReg => user.name.isNotEmpty;
  const MainState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isListChange,
    required this.selectedIndex,
    required this.shouldRefresh,
  });

  MainState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    int? selectedIndex,
    bool? shouldRefresh,
  }) {
    final shouldToggleList = user != null;

    return MainState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      isListChange: shouldToggleList ? !isListChange : isListChange,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      shouldRefresh: shouldRefresh ?? this.shouldRefresh,
    );
  }

  factory MainState.initial() => MainState(
    isLoading: false,
    error: '',
    user: Get.find<UserRepository>().user,
    isListChange: false,
    selectedIndex: 0,
    shouldRefresh: false,
  );

  @override
  List<Object?> get props => [
    isLoading,
    error,
    user,
    isListChange,
    selectedIndex,
    shouldRefresh,
  ];
}
