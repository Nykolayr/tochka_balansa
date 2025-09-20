import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedDate;
  final bool canGoToPrevious;
  final bool canGoToNext;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;

  const HomeAppBar({
    super.key,
    required this.selectedDate,
    required this.canGoToPrevious,
    required this.canGoToNext,
    this.onPreviousDay,
    this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      backgroundColor: AppColor.darkBlue,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Кнопка "Назад" (вчера) - слева
          canGoToPrevious
              ? IconButton(
                  onPressed: onPreviousDay,
                  icon: const Icon(Icons.chevron_left, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: const CircleBorder(),
                  ),
                )
              : const SizedBox(width: 48),

          // Дата посередине
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDate(selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.white,
                ),
              ),
              Text(
                _formatWeekday(selectedDate),
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),

          // Кнопка "Вперед" (завтра) - справа
          canGoToNext
              ? IconButton(
                  onPressed: onNextDay,
                  icon: const Icon(Icons.chevron_right, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: const CircleBorder(),
                  ),
                )
              : const SizedBox(width: 48),
        ],
      ),
      elevation: 0,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate.isAtSameMomentAs(today)) {
      return 'Сегодня';
    } else if (targetDate.isAtSameMomentAs(yesterday)) {
      return 'Вчера';
    } else if (targetDate.isAtSameMomentAs(dayBeforeYesterday)) {
      return 'Позавчера';
    } else {
      // Для дат дальше - формат "1 сентября"
      const months = [
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
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  String _formatWeekday(DateTime date) {
    const weekdays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate.isAtSameMomentAs(today)) {
      return '${date.day} ${_getMonthName(date.month)} - ${weekdays[date.weekday - 1]}';
    } else if (targetDate.isAtSameMomentAs(yesterday)) {
      return '${date.day} ${_getMonthName(date.month)} - ${weekdays[date.weekday - 1]}';
    } else if (targetDate.isAtSameMomentAs(dayBeforeYesterday)) {
      return '${date.day} ${_getMonthName(date.month)} - ${weekdays[date.weekday - 1]}';
    } else {
      // Для дат дальше - только день недели
      return weekdays[date.weekday - 1];
    }
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
