import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarBlankBox extends StatelessWidget {
  const CalendarBlankBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFDBB586),
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
