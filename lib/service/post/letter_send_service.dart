import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dear_deer_demo/model/post/letter_send_model.dart';

// MARK: 편지 전송 서비스
class LetterService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> sendLetter(Letter letter) async {
    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        print('accessToken 없음. 로그인 상태를 확인하세요.');
        return false;
      }

      final data = {
        'receiverId': letter.receiverId,
        'content': letter.content,
        if (letter.imageUrl != null && letter.imageUrl!.isNotEmpty)
          'imageUrl': letter.imageUrl,
      };

      print('요청 URL: $baseUrl/letters');
      print('전송 데이터: $data');
      print('Authorization 헤더: Bearer $token');

      final response = await dio.post(
        '$baseUrl/letters',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('응답 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      if (response.statusCode == 201) {
        print('편지 전송 성공!');
        return true;
      } else {
        print('전송 실패: ${response.statusCode}, ${response.data}');
        return false;
      }
    } catch (e) {
      print('네트워크 에러: $e');
      return false;
    }
  }

// MARK: 편지 임시저장 서비스
  static Future<bool> saveDraft(
      //int letterId,
      String content) async {
    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        print('accessToken 없음. 로그인 상태를 확인하세요.');
        return false;
      }

      final data = {
        // 'letterId': letterId,
        'content': content,
      };

      print('요청 URL: $baseUrl/letters/draft');
      print('전송 데이터: $data');
      print('Authorization 헤더: Bearer $token');

      final response = await dio.post(
        '$baseUrl/letters/draft',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('응답 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      return response.statusCode == 201;
    } catch (e) {
      print('네트워크 에러: $e');
      return false;
    }
  }
}
