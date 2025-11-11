import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_meta.dart';

class CalendarDayBox extends StatelessWidget {
  final int day;
  final bool isPast;
  final bool isSelected;
  final bool isToday;
  final DateTime date;
  final void Function(DateTime) onTap;
  final List<CalendarEvent> events;
  final TextStyle? dayNumberStyle;

  const CalendarDayBox({
    Key? key,
    required this.day,
    required this.isPast,
    required this.isSelected,
    required this.isToday,
    required this.date,
    required this.onTap,
    required this.events,
    this.dayNumberStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<CalendarEvent>.from(events)
      ..sort((a, b) => CalendarCategoryMeta.priorityByLabel(a.category)
          .compareTo(CalendarCategoryMeta.priorityByLabel(b.category)));

    final isSpecialDate = date.month == 12 && date.day == 25;
    final numberColor = isSpecialDate
        ? AppColors.mainRed
        : isPast
            ? AppColors.G_07.withOpacity(0.6)
            : AppColors.G_07;

    final boxBg = isPast ? const Color(0xFFDBB586) : Colors.white;

    return GestureDetector(
      onTap: () => onTap(date),
      child: Container(
        width: 34.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: boxBg,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Stack(
          children: [
            if (isSelected)
              _topBar(AppColors.mainRed)
            else if (isToday)
              _topBar(AppColors.G_04),
            Align(
              alignment: const Alignment(0, -0.4),
              child: Text(
                '$day',
                style: (dayNumberStyle ?? FontStyles.C1_bold_14)
                    .copyWith(color: numberColor),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 5.5.h,
              child: Padding(
                padding: sortedEvents.length <= 3
                    ? EdgeInsets.zero
                    : EdgeInsets.only(left: 3.w, right: 1.w),
                child: _eventDots(sortedEvents, isPast: isPast, boxBg: boxBg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(Color color) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 7.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
          ),
        ),
      );

  /// 이벤트 점(최대 3개 + 오버플로) - 지난날이면 점 투명도 낮춤
  Widget _eventDots(List<CalendarEvent> events,
      {required bool isPast, required Color boxBg}) {
    final double spacing = events.length <= 3 ? 4.w : 3.w;

    Color _dotColor(String category) {
      final base = CalendarCategoryMeta.colorByLabel(category);
      return base.withOpacity(isPast ? 0.4 : 1.0);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...events.take(3).toList().asMap().entries.map((entry) {
          final idx = entry.key;
          final event = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: idx == 0 ? 0 : spacing),
            child: Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: _dotColor(event.category),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
        if (events.length > 3)
          _overflowDot(
            events[3].category,
            isPast: isPast,
            boxBg: boxBg,
          ),
      ],
    );
  }

  /// 4개 이상일 때 마지막 점 + 오른쪽 페이드.
  /// 지난날이면 점도 흐리고, 페이드 배경도 dayBox 배경색을 사용.
  Widget _overflowDot(String category,
      {required bool isPast, required Color boxBg}) {
    final dotColor = CalendarCategoryMeta.colorByLabel(category)
        .withOpacity(isPast ? 0.4 : 1.0);

    return Padding(
      padding: EdgeInsets.only(left: 3.w),
      child: SizedBox(
        width: 5.w,
        height: 5.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5.5.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      boxBg.withOpacity(0.0),
                      boxBg.withOpacity(1.0),
                    ],
                  ),
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(2.5.w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
