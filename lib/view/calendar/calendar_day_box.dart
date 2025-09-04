import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';

class CalendarDayBox extends StatelessWidget {
  final int day;
  final bool isPast;
  final bool isToday;
  final DateTime date;
  final void Function(DateTime) onTap;

  const CalendarDayBox({
    super.key,
    required this.day,
    required this.isPast,
    required this.isToday,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            if (isToday)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: AppColors.mainRed,
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
                  color:
                      isPast ? AppColors.G_07.withOpacity(0.6) : AppColors.G_07,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
