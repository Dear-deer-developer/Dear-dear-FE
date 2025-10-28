import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainCategoryTab extends StatelessWidget {
  final int currentIndex; // ✅ 기존 controller 대신 값만 받음
  final ValueChanged<int> onTap; // ✅ 탭 변경 콜백

  const MainCategoryTab({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['콘텐츠 추천', '행사 알림', '즐겨찾기'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (i) {
        final selected = i == currentIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? AppColors.mainGreen : AppColors.G_02,
                    width: selected ? 2.h : 1.h,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style:
                      (selected ? FontStyles.B1_bold_20 : FontStyles.B2_reg_16)
                          .copyWith(
                    color: selected ? AppColors.mainGreen : AppColors.G_05,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
