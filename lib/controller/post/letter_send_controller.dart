import 'package:dear_deer_demo/model/post/letter_send_model.dart';
import 'package:dear_deer_demo/service/post/letter_send_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LetterSendController extends GetxController {
  var isSending = false.obs;

  Future<void> sendLetter({
    required int receiverId,
    required String content,
    String? imageUrl,
  }) async {
    isSending.value = true;

    final letter = Letter(
      receiverId: receiverId,
      content: content,
      imageUrl: imageUrl,
    );

    // 여기 추가
    final prefs = await SharedPreferences.getInstance();
    print("저장된 accessToken: ${prefs.getString('accessToken')}");

    // 이제 실제 전송
    final success = await LetterService.sendLetter(letter);
    isSending.value = false;

    if (success) {
      Get.snackbar("전송 완료", "편지가 성공적으로 전송되었습니다!");
    } else {
      Get.snackbar("전송 실패", "편지 전송 중 오류가 발생했습니다.");
    }
  }
}
