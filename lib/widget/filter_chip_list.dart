import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterChipList extends StatelessWidget {
  final List<String> filters; // ✅ 값만 받음
  final int selected; // ✅ 선택 인덱스
  final ValueChanged<int> onTap; // ✅ 칩 터치 콜백

  const FilterChipList({
    super.key,
    required this.filters,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        physics: const BouncingScrollPhysics(), // ✅ iOS스럽게
        padding: EdgeInsets.symmetric(horizontal: 24.w), // ✅ 좌우 24
        itemBuilder: (context, i) {
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.Red01 : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? AppColors.mainRed : AppColors.G_02,
                  width: 1.5.w,
                ),
              ),
              child: Text(
                filters[i],
                style: FontStyles.B3_reg_15.copyWith(color: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}
