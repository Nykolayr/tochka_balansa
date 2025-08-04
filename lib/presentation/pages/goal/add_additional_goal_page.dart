import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class AddAdditionalGoalPage extends StatelessWidget {
  const AddAdditionalGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Добавить цель'), isBack: true),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          // Сначала шаблоны (goalTypes), потом пользовательские цели (additionalGoals)
          final templates = state.goalTypes;
          final userGoals = state.additionalGoals;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (templates.isNotEmpty) ...[
                Text(
                  textLang('Шаблоны целей'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                ...templates.map((goal) => _GoalTypeTile(goal: goal)),
                const SizedBox(height: 24),
              ],
              if (userGoals.isNotEmpty) ...[
                Text(
                  textLang('Ваши цели'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                ...userGoals.map((goal) => _UserGoalTile(goal: goal)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GoalTypeTile extends StatelessWidget {
  final AdditionalGoal goal;

  const _GoalTypeTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          goal.icon ?? Icons.flag,
          color: AppColor.darkBlue,
          size: 28,
        ),
        title: Text(
          goal.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.darkBlue,
          ),
        ),
        subtitle: Text(
          goal.description,
          style: const TextStyle(fontSize: 14, color: AppColor.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColor.grey,
          size: 16,
        ),
        onTap: () {
          // Переход к созданию цели на основе шаблона
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _GoalSetupPage(template: goal),
            ),
          );
        },
      ),
    );
  }
}

class _UserGoalTile extends StatelessWidget {
  final AdditionalGoal goal;

  const _UserGoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(goal.icon ?? Icons.flag, color: AppColor.grey, size: 28),
        title: Text(
          goal.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.grey,
          ),
        ),
        subtitle: Text(
          goal.description,
          style: const TextStyle(fontSize: 14, color: AppColor.grey),
        ),
        // Можно добавить onTap для редактирования или просмотра цели
        enabled: false, // чтобы нельзя было выбрать повторно
      ),
    );
  }
}

// Страница создания цели на основе шаблона
class _GoalSetupPage extends StatefulWidget {
  final AdditionalGoal template;

  const _GoalSetupPage({required this.template});

  @override
  State<_GoalSetupPage> createState() => _GoalSetupPageState();
}

class _GoalSetupPageState extends State<_GoalSetupPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _targetCount;
  late String _unit;
  late String _reminderText;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.template.title);
    _descriptionController = TextEditingController(
      text: widget.template.description,
    );
    _targetCount = widget.template.targetCount;
    _unit = widget.template.unit;
    _reminderText = widget.template.reminderText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: widget.template.title, isBack: true),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: textLang('Название цели'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return textLang('Введите название цели');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: textLang('Описание цели'),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _targetCount.toString(),
                decoration: InputDecoration(
                  labelText: textLang('Целевое количество'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _targetCount = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _unit,
                decoration: InputDecoration(
                  labelText: textLang('Единица измерения'),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => _unit = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _reminderText,
                decoration: InputDecoration(
                  labelText: textLang('Текст напоминания'),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => _reminderText = value,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.darkBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(textLang('Создать')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createGoal() {
    if (!_formKey.currentState!.validate()) return;

    final goal = widget.template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      targetCount: _targetCount,
      unit: _unit,
      reminderText: _reminderText,
      createdAt: DateTime.now(),
      isCompleted: false,
      currentCount: 0,
      // deadline, subGoals и т.д. можно добавить по необходимости
    );

    final goalBloc = Get.find<GoalBloc>();
    goalBloc.add(AddAdditionalGoalEvent(goal));

    Navigator.pop(context);
    Navigator.pop(context);
  }
}
