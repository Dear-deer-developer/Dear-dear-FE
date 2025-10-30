import 'dart:convert';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:get/get.dart';

class TemporaryStorageService extends GetxService {
  final _api = Get.find<ApiService>();

  /// 임시 보관함 목록 조회
  Future<List<dynamic>> fetchDraftLetters() async {
    try {
      final res = await _api.getJson('/letters/draft');
      if (res is List) return res;
      print('서버 응답이 List가 아님: $res');
      return [];
    } catch (e) {
      print('임시 보관함 불러오기 실패: $e');
      return [];
    }
  }

  /// 임시 편지 삭제
  Future<Map<String, dynamic>?> deleteDraftLetters(List<int> ids) async {
    try {
      print('삭제 요청: $ids');
      final response = await _api.deleteJson('/letters', data: {
        'letterIds': ids,
      });
      print('삭제 성공 응답: ${response.bodyString ?? response.body}');
      if (response.body is Map<String, dynamic>) {
        return response.body;
      }
      if (response.bodyString?.isNotEmpty ?? false) {
        return jsonDecode(response.bodyString!) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('삭제 실패: $e');
      return null;
    }
  }
}
