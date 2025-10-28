import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dear_deer_demo/model/post/letter_sent_model.dart';

class LetterSentService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<SentLetter>?> fetchSentLetters() async {
    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        print('accessToken 없음. 로그인 상태를 확인하세요.');
        return null;
      }

      print('요청 URL: $baseUrl/letters/sent');
      final response = await dio.get(
        '$baseUrl/letters/sent',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('응답 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        dynamic raw = response.data;

        // 1. 리스트 그대로 오는 경우
        if (raw is List) {
          return raw.map((json) => SentLetter.fromJson(json)).toList();
        }

        // 2. lettersWithPresign 키 안에 들어있는 경우
        if (raw is Map && raw['lettersWithPresign'] is List) {
          return (raw['lettersWithPresign'] as List)
              .map((json) => SentLetter.fromJson(json))
              .toList();
        }

        print('예기치 않은 데이터 구조: ${response.data.runtimeType}');
        return null;
      }

      print('조회 실패: ${response.statusCode}');
      return null;
    } catch (e) {
      print('네트워크 에러: $e');
      return null;
    }
  }
}
