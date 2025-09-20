import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/health/daily_calories_record.dart';
import 'package:tochka_balansa/data/models/health/daily_event.dart';
import 'package:tochka_balansa/data/repositories/daily_events_repository.dart';

class DailyDiaryWidget extends StatelessWidget {
  final DailyCaloriesRecord record;

  const DailyDiaryWidget({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final events = _buildEventsList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с кнопкой "Подробнее"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Дневник дня',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Переход на страницу подробного дневника
                      print('Переход на подробный дневник');
                    },
                    child: Text(
                      'Подробнее',
                      style: TextStyle(fontSize: 16, color: AppColor.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Черта под заголовком
              Container(height: 1, color: AppColor.greyLine),
            ],
          ),
        ),
        // Список событий
        SizedBox(
          height: 120, // Компактная высота
          child: events.isEmpty
              ? const Center(
                  child: Text(
                    'Нет событий за день',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: events[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Widget> _buildEventsList() {
    final events = <Widget>[];

    try {
      final eventsRepo = Get.find<DailyEventsRepository>();
      final dailyEvents = eventsRepo.getEventsForDate(record.date);

      // Сортируем события по времени (новые сверху)
      dailyEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      for (final event in dailyEvents) {
        if (event is ConsumedEvent) {
          events.add(_buildConsumedEventItem(event));
        } else if (event is BurnedEvent) {
          events.add(_buildBurnedEventItem(event));
        }
      }
    } catch (e) {
      print('Ошибка загрузки событий: $e');
    }

    return events;
  }

  /// Построить виджет события съедено
  Widget _buildConsumedEventItem(ConsumedEvent event) {
    final timeText = _formatTime(event.timestamp);
    final caloriesText = '-${event.calories}'; // Съедено с минусом

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(_getEventIcon(event.type), color: AppColor.vesselBlue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${event.type.displayName} ($timeText)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.darkBlue,
              ),
            ),
          ),
          Text(
            caloriesText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.vesselBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// Построить виджет события сожжено
  Widget _buildBurnedEventItem(BurnedEvent event) {
    final timeText = _formatTime(event.timestamp);
    final caloriesText = '+${event.calories}'; // Сожжено с плюсом

    String displayText = event.type.displayName;
    if (event.quantity != null && event.unit != null) {
      displayText = '${event.type.displayName} ${event.quantity}${event.unit}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(_getEventIcon(event.type), color: AppColor.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$displayText ($timeText)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.darkBlue,
              ),
            ),
          ),
          Text(
            caloriesText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.green,
            ),
          ),
        ],
      ),
    );
  }

  /// Получить иконку для типа события
  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.breakfast:
        return Icons.breakfast_dining;
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

  /// Форматировать время в HH:MM
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
