import 'package:dear_deer_demo/service/api_service.dart';
import 'package:get/get.dart';

/// MARK: - 받은 편지함 서비스
/// 서버에서 받은 편지 목록을 조회합니다.
class LetterReceivedService extends GetxService {
  final _api = Get.find<ApiService>();

  /// 받은 편지 리스트 조회
  Future<List<dynamic>> fetchReceivedLetters() async {
    try {
      final result = await _api.getJson('/letters/received');

      if (result is List) {
        return result;
      } else {
        print('예상치 못한 응답 형식: $result');
        return [];
      }
    } catch (e) {
      print('LetterReceivedService - 받은 편지 조회 실패: $e');
      return [];
    }
  }

  /// 단일 편지 상세 조회 (선택 시)
  Future<Map<String, dynamic>?> fetchLetterDetail(int letterId) async {
    try {
      final result = await _api.getJson('/letters/$letterId');
      if (result is Map<String, dynamic>) {
        print('받은 편지 상세 불러오기 성공: $result');
        return result;
      } else {
        print('받은 편지 상세 데이터 형식이 올바르지 않음');
        return null;
      }
    } catch (e) {
      print(' LetterReceivedService - 단일 편지 조회 실패: $e');
      return null;
    }
  }
}
