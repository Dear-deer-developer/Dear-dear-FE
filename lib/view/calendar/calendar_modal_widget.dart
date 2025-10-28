import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/today_ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomCalendarWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime focusedDay;

  final TextStyle _commonTextStyle = TextStyle(color: AppColors.G_06);

  @override
  void initState() {
    super.initState();
    focusedDay = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: focusedDay,
      firstDay: DateTime(fakeToday.year, 11, 1),
      lastDay: DateTime(fakeToday.year, 12, 31),
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(day, widget.selectedDate),
      onDaySelected: (selected, focused) {
        setState(() {
          focusedDay = focused;
        });
        widget.onDateSelected(selected);
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: const Icon(Icons.chevron_left),
        rightChevronIcon: const Icon(Icons.chevron_right),
        titleTextFormatter: (date, _) => '${date.year}년 ${date.month}월',
        titleTextStyle: FontStyles.B4_bold_14,
      ),
      daysOfWeekHeight: 20,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: FontStyles.S2_reg_12.copyWith(color: AppColors.G_06),
        weekdayStyle: FontStyles.S2_reg_12.copyWith(color: AppColors.G_06),
        dowTextFormatter: (date, locale) =>
            ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7],
      ),
      rowHeight: 35.h,
      calendarStyle: CalendarStyle(
        cellMargin: EdgeInsets.only(top: 5.h, bottom: 5.h),
        outsideDaysVisible: false,
        defaultTextStyle: _commonTextStyle,
        weekendTextStyle: _commonTextStyle,
        holidayTextStyle: _commonTextStyle,
        selectedDecoration: const BoxDecoration(
          color: AppColors.mainRed,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
