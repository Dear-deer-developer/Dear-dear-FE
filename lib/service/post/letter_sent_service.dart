import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/service/api_service.dart';

class LetterSentService {
  static final Dio _dio = Dio();
  static const String baseUrl = 'http://dearxmas.com:3000';

  /// ✅ 보낸 편지 목록 조회
  static Future<List<dynamic>?> fetchSentLetters() async {
    try {
      final token = await ApiService().getToken();
      final response = await _dio.get(
        '$baseUrl/letters/sent',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        print('보낸 편지 목록 불러오기 성공');
        return response.data;
      } else {
        print('보낸 편지 목록 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('보낸 편지 조회 에러: $e');
      return null;
    }
  }

  /// ✅ 단일 편지 조회
  static Future<Map<String, dynamic>?> fetchLetterById(int letterId) async {
    try {
      final token = await ApiService().getToken();
      final response = await _dio.get(
        '$baseUrl/letters/$letterId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        print('편지 조회 성공');
        return response.data;
      } else {
        print('편지 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('편지 조회 중 오류 발생: $e');
      return null;
    }
  }
}
