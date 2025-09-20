import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/health/daily_event.dart';
import 'package:tochka_balansa/data/repositories/daily_events_repository.dart';
import 'package:tochka_balansa/presentation/pages/home/date_navigation_controller.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class DetailedDiaryPage extends StatelessWidget {
  const DetailedDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: _getDiaryTitle(), isBack: true),
      body: GetBuilder<DateNavigationController>(
        builder: (controller) {
          final eventsRepo = Get.find<DailyEventsRepository>();
          final events = eventsRepo.getEventsForDate(controller.selectedDate);

          // Сортируем события по времени (новые сверху)
          events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: Colors.grey),
                  Gap(16),
                  Text(
                    'Нет событий за день',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEventCard(event),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(DailyEvent event) {
    if (event is ConsumedEvent) {
      return _buildConsumedEventCard(event);
    } else if (event is BurnedEvent) {
      return _buildBurnedEventCard(event);
    }
    return const SizedBox.shrink();
  }

  Widget _buildConsumedEventCard(ConsumedEvent event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с иконкой и временем
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getEventIcon(event.type),
                    color: AppColor.primary,
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.type.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      Text(
                        _formatTime(event.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Масса
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'масса',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    Text(
                      '${event.totalWeight} гр',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Gap(15),
                // Калории
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${event.calories} ккал',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                ),
              ],
            ),

            if (event.products.isNotEmpty) ...[
              const Gap(12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Продукты:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Gap(6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: event.products.map((product) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColor.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBurnedEventCard(BurnedEvent event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с иконкой и временем
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getEventIcon(event.type),
                    color: AppColor.green,
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.type.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      Text(
                        _formatTime(event.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Количество шагов
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${event.quantity ?? 0}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'шагов',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Gap(15),
                // Калории
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '+${event.calories} ккал',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.green,
                    ),
                  ),
                ),
              ],
            ),

            if (event.note != null && event.note!.isNotEmpty) ...[
              const Gap(8),
              Text(
                event.note!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.breakfast:
        return Icons.free_breakfast;
      case EventType.lunch:
        return Icons.lunch_dining;
      case EventType.dinner:
        return Icons.dinner_dining;
      case EventType.snacks:
        return Icons.cookie;
      case EventType.steps:
        return Icons.directions_walk;
      case EventType.exercise:
        return Icons.fitness_center;
      case EventType.bmr:
        return Icons.local_fire_department;
    }
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getDiaryTitle() {
    final controller = Get.find<DateNavigationController>();
    final date = controller.selectedDate;

    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];

    final day = date.day;
    final month = months[date.month - 1];

    return 'Дневник дня на $day $month';
  }
}
