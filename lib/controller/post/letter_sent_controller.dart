import 'package:dear_deer_demo/model/post/letter_sent_model.dart';
import 'package:dear_deer_demo/service/post/letter_sent_service.dart';
import 'package:get/get.dart';

/// MARK: - 보낸 편지함 컨트롤러
/// 서버에서 보낸 편지 목록을 불러와 상태로 관리합니다.
class LetterSentController extends GetxController {
  var letters = <SentLetter>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSentLetters();
  }

  /// 서버에서 보낸 편지 목록 불러오기
  Future<void> loadSentLetters() async {
    try {
      isLoading.value = true;
      final result = await LetterSentService.fetchSentLetters();
      if (result != null) {
        letters.assignAll(
          result.map<SentLetter>((json) => SentLetter.fromJson(json)).toList(),
        );
      } else {
        letters.clear();
      }
    } catch (e) {
      print('LetterSentController - 편지 조회 실패: $e');
      letters.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// 단일 편지 상세 조회 (편지 클릭 시 호출)
  Future<Map<String, dynamic>?> loadLetterDetail(int letterId) async {
    try {
      final data = await LetterSentService.fetchLetterDetail(letterId);
      if (data != null) {
        print('편지 상세 불러오기 성공: $data');
      } else {
        print('편지 상세 불러오기 실패 (데이터 null)');
      }
      return data;
    } catch (e) {
      print('LetterSentController - 단일 편지 조회 실패: $e');
      return null;
    }
  }
}
