import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';

class CalendarWeekdayHeader extends StatelessWidget {
  const CalendarWeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return SizedBox(
      width: (34.w * 7) + (5.w * 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (i) {
          return Container(
            width: 34.w,
            height: 48.h,
            margin: EdgeInsets.only(right: i != 6 ? 5.w : 0),
            alignment: Alignment.center,
            child: Text(
              days[i],
              style: FontStyles.S1_reg_12.copyWith(color: AppColors.White),
            ),
          );
        }),
      ),
    );
  }
}
