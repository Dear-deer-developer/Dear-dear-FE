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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(), // 상단 앱바
      body: Column(
        children: [
          _letterPreviewBody(controller),
          _slide(controller),
          SizedBox(height: 20),
          _button(controller), // 전송 버튼
          _edit(controller), // 수정 버튼
        ],
      ),
    );
  }

// MARK: 앱 바
  AppBar _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            '편지 확인',
            style: FontStyles.H1_bold_17,
          ),
        ),
        centerTitle: false,
      );

// MARK: 편지 내용 미리보기
  /// 편지 내용을 페이지별로 나누어 보여주는 위젯입니다.
  /// 페이지 수는 500 자씩 끊어서 나누어진 리스트로 관리됩니다.
  /// 각 페이지는 PageView.builder를 사용하여 스크롤할 수 있습니다.
  Widget _letterPreviewBody(LetterPreviewController controller) => Expanded(
        child: Obx(() => PageView.builder(
              controller: controller.pageController,
              itemCount: controller.pagedTexts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 27, horizontal: 30),
                  child: Container(
                    width: 300.w,
                    decoration: BoxDecoration(
                      color: AppColors.G_01,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    /// 첫 페이지에만 "Dear. 닉네임 이용" 문구를 추가하고, 마지막 페이지에만 날짜와 발신자 정보를 표시합니다.
                    /// 각 페이지는 컨테이너 내에서 스크롤할 수 없도록 설정되어 있습니다.
                    /// 첫 페이지가 아닌 경우에는 상단의 여백을 추가하여 레이아웃을 맞추었습니다.
                    child: Column(
                      children: [
                        if (index == 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 99, bottom: 15),
                            child: Text("Dear. 닉네임 이용",
                                style: FontStyles.L1_reg_20),
                          )
                        else
                          SizedBox(height: 80.h),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Text(
                                controller.pagedTexts[index],
                                style: FontStyles.L1_reg_16,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 15, top: 15, bottom: 15),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: index == controller.pagedTexts.length - 1
                                ? Text("2025년 12월 20일 \nFrom. OOO",
                                    style: FontStyles.L1_reg_16,
                                    textAlign: TextAlign.right)
                                : SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
      );

//MARK: 페이지 슬라이드 인디케이터
  /// SmoothPageIndicator를 사용하여 현재 페이지를 표시합니다.
  /// 현재 페이지는 빨간색으로 표시되고, 나머지 페이지는 회색으로 표시됩니다.
  Widget _slide(LetterPreviewController controller) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SmoothPageIndicator(
          controller: controller.pageController,
          count: controller.pagedTexts.length,
          effect: SlideEffect(
            dotWidth: 6,
            dotHeight: 6,
            activeDotColor: AppColors.mainRed,
            dotColor: AppColors.G_03,
          )));

//MARK: 전송 버튼
  Widget _button(LetterPreviewController controller) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(300.w, 40.h),
          backgroundColor: AppColors.mainGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: controller.onSend,
        child: Text('전송하기',
            style: FontStyles.Button_bold_17.copyWith(color: AppColors.White)),
      );

//MARK: 수정 버튼
  Widget _edit(LetterPreviewController controller) => TextButton(
        onPressed: controller.onEdit,
        child: Text("수정하기",
            style: FontStyles.S1_reg_13.copyWith(
              decoration: TextDecoration.underline,
              decorationThickness: 1.0,
              decorationColor: AppColors.Black,
            )),
      );
}
