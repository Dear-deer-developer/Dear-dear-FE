import 'package:dear_deer_demo/data/today_ex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_day_box.dart';
import 'package:dear_deer_demo/view/calendar/calendar_blank_box.dart';
import 'package:dear_deer_demo/view/calendar/calendar_weekday_header.dart';

class CalendarView extends StatelessWidget {
  final DateTime monthDate;
  final void Function(DateTime) onDayTap;

  const CalendarView({
    super.key,
    required this.monthDate,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = fakeToday;
    final year = monthDate.year;
    final month = monthDate.month;

    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    List<Widget> boxWidgets = [];

    // 지난달 날짜 or 빈칸
    for (int i = 0; i < startWeekday; i++) {
      if (month == 12) {
        final prevMonthLastDay = DateTime(year, month, 0).day;
        final dayNumber = prevMonthLastDay - (startWeekday - i - 1);
        boxWidgets.add(CalendarDayBox(
          day: dayNumber,
          isPast: true,
          isToday: false,
          date: DateTime(year, month - 1, dayNumber),
          onTap: (_) {},
        ));
      } else {
        boxWidgets.add(const CalendarBlankBox());
      }
    }

    // 이번달 날짜
    for (int day = 1; day <= lastDay; day++) {
      final thisDay = DateTime(year, month, day);
      final isToday = _isSameDate(thisDay, today);
      final isPast =
          thisDay.isBefore(DateTime(today.year, today.month, today.day));

      boxWidgets.add(CalendarDayBox(
        day: day,
        isPast: isPast,
        isToday: isToday,
        date: thisDay,
        onTap: onDayTap,
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
          CalendarWeekdayHeader(),
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
