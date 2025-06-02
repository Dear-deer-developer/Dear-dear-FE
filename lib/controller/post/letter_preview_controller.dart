import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LetterPreviewController extends GetxController {
  /// 편지 내용을 페이지별 텍스트 리스트로 관리하는 반응형 변수를 지정.
  final RxList<String> pagedTexts = <String>[].obs;
  
  /// 한 페이지에 보여 줄 글자 수를 500 으로 한정.
  final int charsPerPage = 500;

  @override
  void onInit() {
    super.onInit();
    _paginateLetterText();
  }

  /// 페이지 컨트롤러를 생성하여 관리합니다.
  final PageController pageController = PageController();

  @override
  void onClose() {
    pageController.dispose(); // 페이지 컨트롤러 해제
    super.onClose();
  }

  // MARK: 편지 내용을 페이지별로 나누는 함수
  /// 전체 편지 문자열을 지정하여 나타내고, 분할한 페이지들을 리스트에 저장합니다.

  void _paginateLetterText() {
    String fullText =
        '안녕 주원아? 사용자가 편지를 받으면 어떨지 한번 본다고 여기 내가 너에게 편지를 쓰고 있어. 시험은 잘끝났닝?? 일단 행간이 쪼금 넓은 기분? 일단 밑줄은 빼봤어  이야기를 쪼금 해봐야겠땅ㅋㅋㅋㅎㅋㅎㅋㅎㅋㅎㅋㅎㅎㅎ 그리고 페이지 나눠지는거도 만들어야해!!!!!!!! 시험끝나고 할 일 많겠다ㅎㅎㅎㅎㅎㅎ 아뵤 일단 행간이 쪼금 넓은 기분? 일단 밑줄은 빼봤어  이야기를 쪼금 해봐야겠땅ㅋㅋㅋㅎㅋㅎㅋㅎㅋㅎㅋㅎㅎㅎ 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 ㅍ2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이지 2페이';

    /// 500 글자씩 잘라서 페이지별로 나누고, 마지막 인덱스에서는 편지가 끝을 넘지 않도록 처리합니다.
    /// 각 페이지는 리스트에 추가됩니다.
    List<String> pages = [];
    for (int i = 0; i < fullText.length; i += charsPerPage) {
      int end = (i + charsPerPage < fullText.length)
          ? i + charsPerPage
          : fullText.length;
      pages.add(fullText.substring(i, end));
    }

    pagedTexts.value = pages;
  }

  void onSend() {
    print("편지를 전송했습니다!");
  }

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
              Text(
                "확인",
                style: FontStyles.H1_bold_17,
              ),
              const SizedBox(height: 16),
              Text(
                "한 번 전송한 편지는\n취소하거나 수정할 수 없습니다. 🥺",
                style: FontStyles.B1_reg_16,
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
                        style: FontStyles.B1_reg_16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 120),
                      child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            "확인",
                            style: FontStyles.B1_reg_16,
                          )),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
