import 'package:dear_deer_demo/controller/post/letter_preview_controller.dart';
import 'package:dear_deer_demo/controller/post/letter_send_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/letter/write_letter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LetterPreview extends StatelessWidget {
  const LetterPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LetterPreviewController());

    // WriteLetterScreen에서 전달된 모든 인자 받기
    final arguments = Get.arguments ?? {};
    final senderName = arguments['senderName'] ?? '';
    final content = arguments['content'] ?? '';
    final selectedPaper = arguments['selectedPaper'];
    final recipientName = arguments['recipientName'] ?? '';
    final recipientNumber = arguments['recipientNumber'] ?? '';

    // 컨트롤러 초기화
    controller.setLetterContent(content);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _appBar(),
      body: Column(
        children: [
          _letterPreviewBody(
              controller, senderName, recipientName, selectedPaper),
          _slide(controller),
          const SizedBox(height: 20),
          _button(),
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
    final selectedImage = Get.arguments?['selectedImage'];

    return Expanded(
      child: Obx(
        () => PageView.builder(
          controller: controller.pageController,
          itemCount: controller.pagedTexts.length,
          itemBuilder: (context, index) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: selectedPaper != null
                        ? Image.asset(
                            selectedPaper['image'],
                            width: 312.w,
                            height: 500.h,
                            fit: BoxFit.fill,
                            alignment: Alignment.center,
                          )
                        : const SizedBox.shrink(),
                  ),

                  /// 편지 내용 (편지지 위)
                  SizedBox(
                    width: 312.w,
                    height: 500.h,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 90.h, 20.w, 20.h),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Dear 문구
                            if (index == 0)
                              Padding(
                                padding: EdgeInsets.only(bottom: 15.h),
                                child: Text(
                                  "Dear. ${recipientName.isNotEmpty ? recipientName : '친구'}",
                                  style: FontStyles.L1_reg_20.copyWith(
                                    fontFamily: 'LeeSeoyun',
                                    color: AppColors.Black,
                                  ),
                                ),
                              ),

                            // 선택된 사진
                            if (index == 0 && selectedImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(
                                  selectedImage,
                                  width: 280.w,
                                  height: 184.h,
                                  fit: BoxFit.cover,
                                ),
                              ),

                            if (index == 0 && selectedImage != null)
                              SizedBox(height: 14.h),

                            // 본문 텍스트
                            Text(
                              controller.pagedTexts[index],
                              style: FontStyles.L3_reg_16.copyWith(
                                fontFamily: 'LeeSeoyun',
                                color: AppColors.Black,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // 마지막 페이지 From.
                            if (index == controller.pagedTexts.length - 1)
                              Padding(
                                padding: EdgeInsets.only(top: 16.h),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    "2025년 12월 20일\nFrom. $senderName",
                                    style: FontStyles.L3_reg_16.copyWith(
                                      fontFamily: 'LeeSeoyun',
                                      color: AppColors.Black,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
  // Widget _button() {
  //   final sendController = Get.put(LetterSendController());
  //   final arguments = Get.arguments ?? {};

  //   final receiverId = arguments['receiverId'] ?? 0;
  //   final content = arguments['content'] ?? '';
  //   final imageUrl = arguments['imageUrl'];

  //   return ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //       minimumSize: Size(300.w, 40.h),
  //       backgroundColor: AppColors.mainGreen,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //     onPressed: () async {
  //       await sendController.sendLetter(
  //         receiverId: receiverId,
  //         content: content,
  //         imageUrl: imageUrl,
  //       );
  //     },
  //     child: Text(
  //       '전송하기',
  //       style: FontStyles.Button_bold_17.copyWith(color: AppColors.White),
  //     ),
  //   );
  // }

  Widget _button() {
    final sendController = Get.put(LetterSendController());
    final arguments = Get.arguments ?? {};

    final receiverId = 23; // ✅ 테스트용 (receiverId 고정)
    final content = arguments['content'] ?? '테스트용 편지입니다.';
    final imageUrl = arguments['imageUrl'];

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(300.w, 40.h),
        backgroundColor: AppColors.mainGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        await sendController.sendLetter(
          receiverId: receiverId,
          content: content,
          imageUrl: imageUrl,
        );
      },
      child: Text(
        '전송하기',
        style: FontStyles.Button_bold_17.copyWith(color: AppColors.White),
      ),
    );
  }

// MARK: 수정 버튼
  Widget _edit(LetterPreviewController controller) => TextButton(
        onPressed: () {
          Get.back();
        },
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
