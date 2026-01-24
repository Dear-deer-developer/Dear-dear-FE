import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockService {
  final Dio dio = Dio();

  Future<bool> blockUser({required int targetUserId}) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://dearxmas.com:3000';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('BlockService: 토큰 없음');
        return false;
      }

      final data = {
        "targetUserId": targetUserId,
      };

      print('BlockService: 차단 요청 시작');
      print('차단 데이터: $data');

      final response = await dio.post(
        '$baseUrl/reports/block',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('BlockService: 서버 응답 ${response.statusCode}');
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('BlockService: 차단 성공');
        return true;
      }

      print('BlockService: 차단 실패');
      return false;
    } catch (e) {
      print('BlockService: 차단 중 오류 발생: $e');
      return false;
    }
  }
}
