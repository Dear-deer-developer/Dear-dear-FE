import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/letter/transfer_completed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LetterPreviewController extends GetxController {
  final RxList<String> pagedTexts = <String>[].obs;
  final int charsPerPage = 500;
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _paginateLetterText();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // MARK: 페이지 나누기
  void _paginateLetterText() {
    String fullText = '안녕 주원아? 사용자가 편지를 받으면 어떨지 한번 본다고 여기 내가 너에게 편지를 쓰고 있어...';

    List<String> pages = [];
    for (int i = 0; i < fullText.length; i += charsPerPage) {
      int end = (i + charsPerPage < fullText.length)
          ? i + charsPerPage
          : fullText.length;
      pages.add(fullText.substring(i, end));
    }

    pagedTexts.value = pages;
  }

  // MARK: 실제 전송 처리
  void onSend() {
    print("📩 편지를 전송했습니다!");
    Get.offAll(() => transferCompleted());
  }

  // MARK: 전송 전 확인 다이얼로그
  void onEdit() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 310.w,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("확인", style: FontStyles.H2_bold_17),
              const SizedBox(height: 16),
              Text(
                "한 번 전송한 편지는\n취소하거나 수정할 수 없습니다 🥺",
                style: FontStyles.B2_reg_16,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 45),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        "뒤로",
                        style: FontStyles.B2_reg_16.copyWith(
                            color: AppColors.G_06),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 120),
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          onSend();
                        },
                        child: Text(
                          "전송",
                          style: FontStyles.B2_reg_16.copyWith(
                              color: AppColors.Black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: 편지 내용 설정
  void setLetterContent(String content) {
    final pages = <String>[];
    const pageLimit = 500;

    for (int i = 0; i < content.length; i += pageLimit) {
      final end =
          (i + pageLimit < content.length) ? i + pageLimit : content.length;
      pages.add(content.substring(i, end));
    }

    pagedTexts.assignAll(pages);
  }
}
