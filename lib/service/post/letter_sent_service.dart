import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LetterSentService {
  /// ✅ 내가 보낸 편지 조회
  static Future<List<dynamic>?> fetchSentLetters() async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://dearxmas.com:3000';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('액세스 토큰이 없습니다.');
        return null;
      }

      final dio = Dio();
      print('[Request] GET $baseUrl/letters/sent');
      final response = await dio.get(
        '$baseUrl/letters/sent',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('보낸 편지 목록 불러오기 성공');
        print(response.data);
        return response.data;
      } else {
        print('보낸 편지 불러오기 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('LetterService - fetchSentLetters 에러: $e');
      return null;
    }
  }

  // MARK: - 단일 편지 조회
  static Future<Map<String, dynamic>?> fetchLetterDetail(int letterId) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://dearxmas.com:3000';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('액세스 토큰이 없습니다.');
        return null;
      }

      final dio = Dio();
      print('[Request] GET $baseUrl/letters/$letterId');

      final response = await dio.get(
        '$baseUrl/letters/$letterId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        print('편지 상세 조회 성공');
        print(response.data);
        return response.data;
      } else {
        print('편지 상세 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('LetterService - fetchLetterDetail 에러: $e');
      return null;
    }
  }
}
