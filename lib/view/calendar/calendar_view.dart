import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/view/calendar/calendar_day_box.dart';
import 'package:dear_deer_demo/view/calendar/calendar_blank_box.dart';
import 'package:dear_deer_demo/view/calendar/calendar_weekday_header.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';

class CalendarView extends StatelessWidget {
  final DateTime monthDate;
  final Function(DateTime) onDayTap;
  final DateTime? selectedDate;
  final DateTime today;
  final List<CalendarEvent> Function(DateTime) getEventsForDate;
  final int dataVersion;

  final TextStyle titleStyle;
  final TextStyle weekdayStyle;
  final TextStyle dayNumberStyle;

  const CalendarView({
    Key? key,
    required this.monthDate,
    required this.onDayTap,
    this.selectedDate,
    required this.today,
    required this.getEventsForDate,
    required this.dataVersion,
    required this.titleStyle,
    required this.weekdayStyle,
    required this.dayNumberStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final year = monthDate.year;
    final month = monthDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    final boxWidgets = <Widget>[];
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

      boxWidgets.add(
        CalendarDayBox(
          key: ValueKey('day-$year-$month-$day-$dataVersion'),
          day: day,
          isPast: isPast,
          isSelected: isSelected,
          isToday: isToday,
          date: thisDay,
          onTap: onDayTap,
          events: dayEvents,
          dayNumberStyle: dayNumberStyle,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: 33.w, right: 58.5.w),
      child: Column(
        children: [
          SizedBox(height: 145.h),
          Text(DateFormat('yyyy.MM').format(monthDate), style: titleStyle),
          SizedBox(height: 28.h),
          CalendarWeekdayHeader(textStyle: weekdayStyle),
          SizedBox(height: 6.h),
          SizedBox(
            width: (34.w * 7) + (5.w * 6),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: boxWidgets.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 9.h,
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

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
