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
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mainGreen : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isSelected ? AppColors.mainGreen : AppColors.G_02,
                  width: 1.w,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filters[i],
                style:
                    (isSelected ? FontStyles.S1_reg_13 : FontStyles.S1_reg_13)
                        .copyWith(
                  color: isSelected ? Colors.white : AppColors.G_05,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
