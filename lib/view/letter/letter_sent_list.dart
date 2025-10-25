import 'package:flutter/material.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LetterSentList extends StatelessWidget {
  const LetterSentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: Column(
        children: [
          _warningMessage(),
          _letterList(),
        ],
      ),
    );
  }

  AppBar _appbar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "보낸 편지함",
          style: FontStyles.H2_bold_17,
        ),
      );

  Widget _warningMessage() => Align(
        alignment: const Alignment(0, -0.9),
        child: Container(
          width: 300.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.mainRed.withOpacity(0.3),
            borderRadius: BorderRadius.circular(7.r),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: Image.asset(
                  ImagePath.letterImage,
                  width: 34.w,
                  height: 34.h,
                ),
              ),
              Text(
                "보낸 편지는 수정할 수 없어요.",
                style: FontStyles.B4_reg_14.copyWith(
                  color: AppColors.Black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _letterList() => Padding(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        child: Center(
          child: Container(
            width: 312.w,
            height: 184.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge, // 🔒 모서리 자르기
            child: Image.asset(
              ImagePath.imageLetterEnvelope, // ✉️ 편지 봉투 이미지 경로
              fit: BoxFit.cover, // 📦 꽉 채우기 (비율 유지)
            ),
          ),
        ),
      );
}
