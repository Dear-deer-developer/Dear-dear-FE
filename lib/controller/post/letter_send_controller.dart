import 'package:dear_deer_demo/model/post/letter_send_model.dart';
import 'package:dear_deer_demo/service/post/letter_send_service.dart';
import 'package:dear_deer_demo/view/letter/transfer_completed.dart';
import 'package:dear_deer_demo/view/letter/transfer_share.dart';
import 'package:get/get.dart';

// MARK: - 편지 전송 컨트롤러
// S3 업로드가 완료된 후 imageKey를 받아 LetterService로 전달
class LetterSendController extends GetxController {
  var isSending = false.obs;

  // MARK: - 편지 전송 메서드
  Future<void> sendLetter({
    required int receiverId,
    required String content,
    required int paperId,
    String? imageUrl,
    bool isLinkMode = false,
  }) async {
    isSending.value = true;

    try {
      final letter = Letter(
        receiverId: receiverId,
        content: content,
        paperId: paperId,
        imageUrl: imageUrl,
      );

      final success = await LetterService.sendLetter(letter);

      if (success) {
        print('편지 전송 성공 (paperId: $paperId)');

        if (isLinkMode) {
          // 링크 모드면 TransferShare 화면으로
          Get.offAll(() => const TransferShare());
        } else {
          // 일반 모드면 TransferCompleted 화면으로
          Get.offAll(() => const TransferCompleted());
        }
      } else {
        print('편지 전송 실패');
      }
    } catch (e) {
      print('편지 전송 중 오류: $e');
    } finally {
      isSending.value = false;
    }
  }
}
