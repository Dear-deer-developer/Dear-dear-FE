import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

// MARK: 사서함 번호(zipCode)로 사용자 검색
class UserService {
  static Future<Map<String, dynamic>?> searchByZipCode(String zipCode) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://dearxmas.com:3000';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('액세스 토큰이 없습니다.');
        return null;
      }

      final dio = Dio();

      print('[Request] GET $baseUrl/users/zipcode?zipCode=$zipCode');
      print('Token: $token');

      final response = await dio.get(
        '$baseUrl/users/zipcode',
        queryParameters: {'zipCode': zipCode},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      print('[Response] ${response.statusCode} | ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        print('사서함 검색 성공: ${response.data}');
        return Map<String, dynamic>.from(response.data);
      }

      print('사서함 검색 실패: ${response.statusCode}');
      return null;
    } catch (e) {
      print('UserService - zipCode 검색 에러: $e');
      return null;
    }
  }
}
