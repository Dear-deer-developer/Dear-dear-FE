// lib/view/calendar/calendar_day_box.dart
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

  const CalendarDayBox({
    Key? key,
    required this.day,
    required this.isPast,
    required this.isSelected,
    required this.isToday,
    required this.date,
    required this.onTap,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<CalendarEvent>.from(events)
      ..sort((a, b) => CalendarCategoryMeta.priorityByLabel(a.category)
          .compareTo(CalendarCategoryMeta.priorityByLabel(b.category)));

    final isSpecialDate = date.month == 12 && date.day == 25;

    return GestureDetector(
      onTap: () => onTap(date),
      child: Container(
        width: 34.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: isPast ? const Color(0xFFDBB586) : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: AppColors.mainRed,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(6.r)),
                  ),
                ),
              )
            else if (isToday)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: AppColors.G_04,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(6.r)),
                  ),
                ),
              ),
            Align(
              alignment: const Alignment(0, -0.4),
              child: Text(
                '$day',
                style: FontStyles.C1_bold_14.copyWith(
                  color: isSpecialDate
                      ? AppColors.mainRed
                      : isPast
                          ? AppColors.G_07.withOpacity(0.6)
                          : AppColors.G_07,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 5.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...sortedEvents.take(3).toList().asMap().entries.map((entry) {
                    final idx = entry.key;
                    final event = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: idx == 0 ? 0 : 2.w,
                        right: idx == 2 ? 0 : 1.5.w,
                      ),
                      child: Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          color:
                              CalendarCategoryMeta.colorByLabel(event.category),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                  if (sortedEvents.length > 3)
                    Padding(
                      padding: EdgeInsets.only(left: 3.w),
                      child: SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: CalendarCategoryMeta.colorByLabel(
                                    sortedEvents[3].category),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 3.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.85),
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
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
