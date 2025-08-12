import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/exercise/exercise_record.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // TODO: загружать упражнения при инициализации
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Физические упражнения',
        isBack: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: показать диалог добавления упражнения
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.darkBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
      body: BlocBuilder<MainBloc, MainState>(
        bloc: Get.find<MainBloc>(),
        builder: (context, state) {
          return Column(
            children: [
              // Поиск
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: textLang('Поиск упражнений...'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Список упражнений
              Expanded(child: _buildExercisesList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExercisesList(MainState state) {
    // TODO: получать упражнения из репозитория
    final exercises = <ExerciseRecord>[];

    if (exercises.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? textLang('Нет добавленных упражнений')
              : textLang('Упражнения не найдены'),
          style: TextStyle(
            fontSize: 16,
            color: AppColor.greyText.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${exercise.displayAmount} • ${exercise.displayCalories}',
              style: TextStyle(color: AppColor.greyText.withValues(alpha: 0.7)),
            ),
            trailing: IconButton(
              onPressed: () {
                // TODO: показать диалог редактирования/удаления
              },
              icon: const Icon(Icons.more_vert),
            ),
          ),
        );
      },
    );
  }
}
