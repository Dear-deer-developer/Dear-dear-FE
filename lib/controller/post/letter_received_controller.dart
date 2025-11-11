import 'package:dear_deer_demo/service/post/letter_received_service.dart';
import 'package:get/get.dart';

/// MARK: - 받은 편지함 컨트롤러
/// 서버에서 받은 편지 목록을 불러와 상태로 관리합니다.
class LetterReceivedController extends GetxController {
  final _service = Get.put(LetterReceivedService());
  var receivedLetters = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReceivedLetters(); // 컨트롤러 초기화 시 자동 호출
  }

  /// 받은 편지 전체 목록 불러오기
  Future<void> loadReceivedLetters() async {
    try {
      isLoading.value = true;
      final letters = await _service.fetchReceivedLetters();
      receivedLetters.assignAll(letters);
      print('받은 편지 ${letters.length}건 로드 완료');
    } catch (e) {
      print('LetterReceivedController - 받은 편지 로드 실패: $e');
      receivedLetters.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// 단일 편지 상세 조회
  Future<Map<String, dynamic>?> loadLetterDetail(int letterId) async {
    try {
      final data = await _service.fetchLetterDetail(letterId);
      if (data != null) {
        print('편지 상세 조회 성공: $data');
      } else {
        print('편지 상세 데이터 없음');
      }
      return data;
    } catch (e) {
      print('LetterReceivedController - 단일 편지 조회 실패: $e');
      return null;
    }
  }
}
