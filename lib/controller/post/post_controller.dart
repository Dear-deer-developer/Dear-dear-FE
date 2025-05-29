import 'package:dear_deer_demo/view/%08letter/select_letter_paper_screen.dart';
import 'package:dear_deer_demo/view/%08letter/write_letter_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PostController extends GetxController {
  final ScrollController scrollController = ScrollController();

  void scrollUp() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeIn);
  }
  
  void goToSelectLetterPaper() {
    Get.to(() => const SelectLetterPaperScreen());
  }

  void goToWriteLetter() {
    Get.to(() => const WriteLetterScreen());
  }

  void openMyMailbox() {
    Get.snackbar('알림', '내 사서함 기능은 준비 중이에요!');
  }

  void openSentLetters() {
    Get.snackbar('알림', '보낸 편지함 기능은 준비 중이에요!');
  }

  void openDrafts() {
    Get.snackbar('알림', '임시 보관함 기능은 준비 중이에요!');
  }
}
