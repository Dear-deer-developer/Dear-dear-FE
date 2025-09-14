import 'package:dear_deer_demo/controller/post/letter_preview_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
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

  Widget _Body(LetterPreviewController controller) => Stack(
        children: [
          // 배경 이미지는 Stack의 맨 아래에 위치
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/letter_black.png',
                width: double.infinity,
                height: 400.h,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(child: _LetterView(controller)),
                _PageIndicator(controller),
              ],
            ),
          ),
        ],
      );

  Widget _LetterView(LetterPreviewController controller) => Expanded(
        child: Obx(() => PageView.builder(
              controller: controller.pageController,
              itemCount: controller.pagedTexts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 27, horizontal: 30),
                  child: _LetterCard(index, controller),
                );
              },
            )),
      );

  Widget _LetterCard(int index, LetterPreviewController controller) {
    return Container(
      width: 300.w,
      decoration: BoxDecoration(
        color: AppColors.G_01,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (index == 0)
            Padding(
              padding: const EdgeInsets.only(top: 99, bottom: 15),
              child: Text("Dear. 닉네임 이용", style: FontStyles.L1_reg_20),
            )
          else
            SizedBox(height: 80.h),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Text(
                  controller.pagedTexts[index],
                  style: FontStyles.L3_reg_16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 15, bottom: 15),
            child: Align(
              alignment: Alignment.bottomRight,
              child: index == controller.pagedTexts.length - 1
                  ? Text(
                      "2025년 12월 20일 \nFrom. OOO",
                      style: FontStyles.L3_reg_16,
                      textAlign: TextAlign.right,
                    )
                  : const SizedBox.shrink(),
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
