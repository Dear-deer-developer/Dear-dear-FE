import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';

class CalendarWeekdayHeader extends StatelessWidget {
  final TextStyle? textStyle;
  const CalendarWeekdayHeader({Key? key, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const labels = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final w in labels)
          SizedBox(
            width: 34.w,
            child: Center(
              child: Text(
                w,
                style: (textStyle ?? Theme.of(context).textTheme.labelMedium)
                    ?.copyWith(color: AppColors.White),
              ),
            ),
          ),
      ],
    );
  }
}
