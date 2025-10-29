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

    // 서버에서 받은 상세 데이터
    final arguments = Get.arguments ?? {};
    final content = arguments['content'] ?? '';
    final sentAt = arguments['sentAt'] ?? '';
    final receiver = arguments['receiver'] ?? {};
    final recipientName = receiver['nickname'] ?? '받는 사람 없음';

    // controller에 내용 반영
    controller.setLetterContent(content);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _AppBar(),
      body: _Body(controller, recipientName, sentAt),
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

  Widget _Body(
      LetterPreviewController controller, String recipientName, String sentAt) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            ImagePath.imageOpenLetter,
            width: double.infinity,
            height: 300.h,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          bottom: 140.h,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LetterView(controller, recipientName, sentAt),
              const SizedBox(height: 30),
              _PageIndicator(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _LetterView(
      LetterPreviewController controller, String recipientName, String sentAt) {
    return SizedBox(
      height: 460.h,
      child: Obx(() => PageView.builder(
            controller: controller.pageController,
            itemCount: controller.pagedTexts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
                child: _LetterCard(index, controller, recipientName, sentAt),
              );
            },
          )),
    );
  }

  Widget _LetterCard(int index, LetterPreviewController controller,
      String recipientName, String sentAt) {
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
                "Dear. $recipientName",
                style: FontStyles.L1_reg_20,
              ),
            ),
          ),

          // 본문
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Text(
                controller.pagedTexts[index],
                style: FontStyles.L3_reg_16.merge(
                  const TextStyle(fontFamily: 'LeeSeoyun'),
                ),
              ),
            ),
          ),

          // 날짜 & From
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Text(
                "$sentAt\nFrom. 나",
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
