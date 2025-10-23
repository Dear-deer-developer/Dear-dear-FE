import 'package:dear_deer_demo/data/today_ex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'calendar_day_box.dart';
import 'calendar_blank_box.dart';
import 'calendar_weekday_header.dart';
import 'calendar_event.dart';

class CalendarView extends StatelessWidget {
  final DateTime monthDate;
  final Function(DateTime) onDayTap;
  final DateTime? selectedDate;
  final DateTime today;
  final List<CalendarEvent> Function(DateTime) getEventsForDate;

  const CalendarView({
    Key? key,
    required this.monthDate,
    required this.onDayTap,
    this.selectedDate,
    required this.today,
    required this.getEventsForDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final year = monthDate.year;
    final month = monthDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    List<Widget> boxWidgets = [];

    for (int i = 0; i < startWeekday; i++) {
      boxWidgets.add(const CalendarBlankBox());
    }

    for (int day = 1; day <= lastDay; day++) {
      final thisDay = DateTime(year, month, day);
      final isPast =
          thisDay.isBefore(DateTime(today.year, today.month, today.day));
      final isToday = _isSameDate(thisDay, today);
      final isSelected =
          selectedDate != null && _isSameDate(thisDay, selectedDate!);
      final dayEvents = getEventsForDate(thisDay);

      boxWidgets.add(CalendarDayBox(
        day: day,
        isPast: isPast,
        isSelected: isSelected,
        isToday: isToday,
        date: thisDay,
        onTap: onDayTap,
        events: dayEvents,
      ));
    }

    return Padding(
      padding: EdgeInsets.only(left: 33.w, right: 58.5.w),
      child: Column(
        children: [
          SizedBox(height: 115.h),
          Text(
            DateFormat('yyyy.MM').format(monthDate),
            style: FontStyles.C2_reg_24.copyWith(color: AppColors.White),
          ),
          SizedBox(height: 20.h),
          const CalendarWeekdayHeader(),
          SizedBox(
            width: (34.w * 7) + (5.w * 6),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: boxWidgets.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 11.h,
                crossAxisSpacing: 5.w,
                childAspectRatio: 34 / 48,
              ),
              itemBuilder: (context, index) => boxWidgets[index],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
