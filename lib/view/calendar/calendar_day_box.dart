import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'calendar_event.dart';

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

  static const Map<String, Color> categoryColors = {
    '약속': Colors.red,
    '팝업': Colors.green,
    '티켓팅&예약': Colors.yellow,
    '기타': Colors.black,
  };

  static const Map<String, int> categoryPriority = {
    '약속': 1,
    '팝업': 2,
    '티켓팅&예약': 3,
    '기타': 4,
  };

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<CalendarEvent>.from(events)
      ..sort((a, b) => (categoryPriority[a.category] ?? 100)
          .compareTo(categoryPriority[b.category] ?? 100));

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
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...sortedEvents.take(3).toList().asMap().entries.map((entry) {
                    int idx = entry.key;
                    CalendarEvent event = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: idx == 0 ? 0 : 2.w,
                        right: idx == 2 ? 0 : 1.5.w,
                      ),
                      child: Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          color: categoryColors[event.category] ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                  if (sortedEvents.length > 3)
                    Padding(
                      padding: EdgeInsets.only(left: 3.w, right: 0),
                      child: SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                color:
                                    categoryColors[sortedEvents[3].category] ??
                                        Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 3.w,
                                height: 5.w,
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
