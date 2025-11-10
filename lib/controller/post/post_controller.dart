import 'package:dear_deer_demo/view/letter/transfer_completed.dart';
import 'package:dear_deer_demo/view/letter/letter_sent.dart';
import 'package:dear_deer_demo/view/letter/select_letter_paper_screen.dart';
import 'package:dear_deer_demo/view/letter/write_letter_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 우체국(Post) 관련 비즈니스 로직을 담당하는 컨트롤러입니다.
/// - 편지지 선택, 편지 작성, 내 사서함, 보낸 편지함, 임시보관함 등 다양한 기능을 제공합니다.
/// - 스크롤 컨트롤 등 화면 관련 상태도 관리합니다.
class PostController extends GetxController {
  // MARK: - 상태 및 속성

  /// 화면 스크롤을 제어하는 컨트롤러입니다.
  final ScrollController scrollController = ScrollController();

  /// 현재 우체국 탭 인덱스 (바텀 네비에서 참조)
  var currentIndex = 0.obs;

  // MARK: - 스크롤 관련 메소드

  /// 화면을 맨 위로 스크롤합니다.
  void scrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeIn,
    );
  }

  // MARK: - 네비게이션 메소드

  /// 편지지 선택 화면으로 이동합니다.
  void goToSelectLetterPaper() {
    Get.to(() => const SelectLetterPaperScreen());
  }

  /// 편지 작성 화면으로 이동합니다.
  void goToWriteLetter(Map<String, dynamic> selectedPaper) {
    Get.to(
      () => const WriteLetterScreen(),
      arguments: {
        'selectedPaper': selectedPaper, // 선택한 편지지 정보 전달
      },
    );
  }

  /// 내 사서함 화면으로 이동합니다.
  void openMyMailbox() {
    Get.snackbar('알림', '내 사서함 기능은 준비 중이에요!');
  }

  /// 보낸 편지함 화면으로 이동합니다.
  void openSentLetters() {
    Get.to(() => const LetterSent());
  }

  /// 임시보관함 화면으로 이동합니다.
  /// (여기서 전송 완료 화면으로 이동)
  void openDrafts() {
    Get.to(() => const TransferCompleted());
  }

  /// 우체국 탭 변경
  void changeTab(int index) {
    currentIndex.value = index;
  }
}
