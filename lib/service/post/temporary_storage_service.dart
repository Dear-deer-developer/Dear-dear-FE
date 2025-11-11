import 'dart:convert';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:get/get.dart';

class TemporaryStorageService extends GetxService {
  final _api = Get.find<ApiService>();

  /// 임시 보관함 목록 조회
  Future<List<dynamic>> fetchDraftLetters() async {
    try {
      final res = await _api.getJson('/letters/draft');

      if (res is List) {
        print('임시 보관함 불러오기 성공: ${res.length}건');
        return res;
      }

      print('서버 응답이 List가 아님: $res');
      return [];
    } catch (e) {
      print('임시 보관함 불러오기 실패: $e');
      return [];
    }
  }

  /// 임시 편지 삭제 (Swagger 명세 기반: DELETE /letters?letterIds=1&letterIds=2)
  Future<Map<String, dynamic>?> deleteDraftLetters(List<int> ids) async {
    try {
      if (ids.isEmpty) {
        print('삭제할 ID가 비어 있습니다.');
        return null;
      }

      print(' 삭제 요청 IDs: $ids');

      // ApiService.deleteJson이 자동으로
      // letterIds=1&letterIds=2 형식으로 변환함
      final response = await _api.deleteJson('/letters', data: {
        'letterIds': ids,
      });

      print('삭제 응답: ${response.bodyString ?? response.body}');

      // 응답 파싱 처리
      if (response.body is Map<String, dynamic>) {
        return response.body as Map<String, dynamic>;
      }

      if (response.bodyString?.isNotEmpty ?? false) {
        return jsonDecode(response.bodyString!) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('deleteDraftLetters 실패: $e');
      return null;
    }
  }

  /// 특정 사용자 정보 조회
  Future<Map<String, dynamic>?> fetchUserById(int? userId) async {
    if (userId == null) return null;

    try {
      final res = await _api.getJson('/users/$userId');

      if (res != null && res is Map<String, dynamic>) {
        print('사용자 조회 성공: ${res['nickname'] ?? '이름 없음'}');
        return res;
      }

      print('fetchUserById 응답이 Map이 아님: $res');
    } catch (e) {
      print('fetchUserById 실패: $e');
    }

    return null;
  }
}
