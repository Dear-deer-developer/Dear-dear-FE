import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainCategoryTab extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainCategoryTab({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['콘텐츠 추천', '행사 알림', '즐겨찾기'];
    final indicatorWidth = 90.w;
    final indicatorHeight = 2.h;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (i) {
        final selected = i == currentIndex;

        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              // ✅ 모든 탭의 기준선 동일 (1px G_01)
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.G_01, width: 1.h),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final left = (constraints.maxWidth - indicatorWidth) / 2;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 텍스트
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
                          child: Text(
                            labels[i],
                            style: FontStyles.H3_bold_16.copyWith(
                              color:
                                  selected ? AppColors.Black : AppColors.G_04,
                            ),
                          ),
                        ),
                      ),

                      // ✅ 인디케이터: 기준선과 완전히 겹치게 offset = -1
                      if (selected)
                        Positioned(
                          bottom: -1.h, // ← 보더 라인 위로 겹치기
                          left: left,
                          child: Container(
                            width: indicatorWidth,
                            height: indicatorHeight,
                            color: AppColors.Black,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
