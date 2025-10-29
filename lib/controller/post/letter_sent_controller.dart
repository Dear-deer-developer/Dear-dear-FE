import 'package:get/get.dart';
import 'package:dear_deer_demo/model/post/letter_sent_model.dart';
import 'package:dear_deer_demo/service/post/letter_sent_service.dart';

// MARK: 보낸 편지 컨트롤러
class LetterSentController extends GetxController {
  var letters = <SentLetter>[].obs;
  var isLoading = false.obs;

  Future<void> loadSentLetters() async {
    isLoading.value = true;
    final data = await LetterSentService.fetchSentLetters();

    if (data != null) {
      letters.value = data.map((e) => SentLetter.fromJson(e)).toList();
    }

    isLoading.value = false;
  }
}
