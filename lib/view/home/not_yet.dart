import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';

class NotYet extends StatelessWidget {
  const NotYet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 또는 이미지
              Icon(
                Icons.hourglass_empty,
                size: 60.w,
                color: AppColors.G_05,
              ),
              SizedBox(height: 16.h),

              // 제목
              Text(
                '추후 기능 도입 예정',
                style: FontStyles.H1_bold_22.copyWith(
                  color: AppColors.G_01,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),

              // 설명
              Text(
                '더 나은 서비스를 위해 준비 중입니다.\n곧 멋진 기능으로 찾아올게요!',
                style: FontStyles.B4_reg_14.copyWith(
                  color: AppColors.G_04,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
