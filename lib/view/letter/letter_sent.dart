import 'package:dear_deer_demo/controller/post/letter_preview_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LetterSent extends StatelessWidget {
  const LetterSent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LetterPreviewController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _AppBar(),
      body: _Body(controller),
    );
  }

  AppBar _AppBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            '보낸 편지함',
            style: FontStyles.H2_bold_17,
          ),
        ),
      );

  // ✅ 수정된 Body: Stack 레이아웃 정렬 개선
  // ✅ 수정된 Body: 편지를 위로 올림
  Widget _Body(LetterPreviewController controller) => Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ✅ 하단 봉투 이미지
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              ImagePath.imageOpenLetter,
              width: double.infinity,
              height: 300.h,
              fit: BoxFit.contain,
            ),
          ),

          // ✅ 편지와 인디케이터를 약간 위로 올림
          Positioned(
            bottom: 140.h, // 🔥 기존보다 위로 올리기 (숫자 키워서 조정)
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LetterView(controller),
                const SizedBox(height: 30),
                _PageIndicator(controller),
              ],
            ),
          ),
        ],
      );

  // ✅ 수정: Expanded 제거 (Stack 안에서 불필요)
  Widget _LetterView(LetterPreviewController controller) => SizedBox(
        height: 460.h, // ✅ 원하는 높이로 고정 (시안 비율 맞춰 조정 가능)
        child: Obx(() => PageView.builder(
              controller: controller.pageController,
              itemCount: controller.pagedTexts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
                  child: _LetterCard(index, controller),
                );
              },
            )),
      );

  // ✅ 수정된 편지 카드: 그림자, 여백, 비율 보정
  Widget _LetterCard(int index, LetterPreviewController controller) {
    return Container(
      width: 312.w,
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.G_01,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dear 문구
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Text(
                "Dear. 닉네임 이용",
                style: FontStyles.L1_reg_20,
              ),
            ),
          ),

          // 본문
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Text(controller.pagedTexts[index],
                  style: FontStyles.L3_reg_16.merge(
                    const TextStyle(fontFamily: 'LeeSeoyun'),
                  )),
            ),
          ),

          // 날짜 & From
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Text(
                "2025년 12월 20일\nFrom. OOO",
                textAlign: TextAlign.right,
                style: FontStyles.L3_reg_16.merge(
                  const TextStyle(fontFamily: 'LeeSeoyun'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _PageIndicator(LetterPreviewController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SmoothPageIndicator(
          controller: controller.pageController,
          count: controller.pagedTexts.length,
          effect: const SlideEffect(
            dotWidth: 6,
            dotHeight: 6,
            activeDotColor: AppColors.mainRed,
            dotColor: AppColors.G_03,
          ),
        ),
      );
}
