import 'package:dear_deer_demo/model/post/letter_send_model.dart';
import 'package:dear_deer_demo/service/post/letter_send_service.dart';
import 'package:dear_deer_demo/view/letter/transfer_completed.dart';
import 'package:get/get.dart';

class LetterSendController extends GetxController {
  var isSending = false.obs;

  Future<void> sendLetter({
    required int receiverId,
    required String content,
    required int paperId,
    String? imageUrl,
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
        Get.offAll(() => transferCompleted());
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
