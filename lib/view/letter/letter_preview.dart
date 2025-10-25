import 'package:dear_deer_demo/controller/post/letter_preview_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LetterPreview extends StatelessWidget {
  const LetterPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LetterPreviewController());

    // ✅ WriteLetterScreen에서 전달된 모든 인자 받기
    final arguments = Get.arguments ?? {};
    final senderName = arguments['senderName'] ?? '';
    final content = arguments['content'] ?? '';
    final selectedPaper = arguments['selectedPaper'];
    final recipientName = arguments['recipientName'] ?? '';
    final recipientNumber = arguments['recipientNumber'] ?? '';

    // 컨트롤러 초기화
    controller.setLetterContent(content);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: Column(
        children: [
          _letterPreviewBody(
              controller, senderName, recipientName, selectedPaper),
          _slide(controller),
          const SizedBox(height: 20),
          _button(controller),
          _edit(controller),
        ],
      ),
    );
  }

  // MARK: 앱바
  AppBar _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text('편지 확인', style: FontStyles.H2_bold_17),
        ),
        centerTitle: false,
      );

  // MARK: 편지 내용 미리보기
  Widget _letterPreviewBody(
    LetterPreviewController controller,
    String senderName,
    String recipientName,
    dynamic selectedPaper,
  ) {
    return Expanded(
      child: Obx(
        () => PageView.builder(
          controller: controller.pageController,
          itemCount: controller.pagedTexts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 30),
              child: Container(
                width: 300.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: selectedPaper != null
                      ? DecorationImage(
                          image: AssetImage(selectedPaper['image']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: selectedPaper == null ? AppColors.G_01 : null,
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
                    // Dear 문구 (첫 페이지에만)
                    if (index == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 99, bottom: 15),
                        child: Text(
                          "Dear. ${recipientName.isNotEmpty ? recipientName : '친구'}",
                          style: FontStyles.L1_reg_20,
                        ),
                      )
                    else
                      SizedBox(height: 80.h),

                    // 본문 내용
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

                    // 마지막 페이지에 발신자 정보
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 15, top: 15, bottom: 15),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: index == controller.pagedTexts.length - 1
                            ? Text(
                                "2025년 12월 20일\nFrom. $senderName",
                                style: FontStyles.L3_reg_16.merge(
                                  const TextStyle(fontFamily: 'LeeSeoyun'),
                                ),
                                textAlign: TextAlign.right,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // MARK: 페이지 인디케이터
  Widget _slide(LetterPreviewController controller) => Padding(
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

// MARK: 전송 버튼
  Widget _button(LetterPreviewController controller) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(300.w, 40.h),
          backgroundColor: AppColors.mainGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: controller.onEdit,
        child: Text(
          '전송하기',
          style: FontStyles.Button_bold_17.copyWith(color: AppColors.White),
        ),
      );

  // MARK: 수정 버튼
  Widget _edit(LetterPreviewController controller) => TextButton(
        onPressed: controller.onEdit,
        child: Text(
          "수정하기",
          style: FontStyles.S1_reg_13.copyWith(
            decoration: TextDecoration.underline,
            decorationThickness: 1.0,
            decorationColor: AppColors.Black,
          ),
        ),
      );
}
