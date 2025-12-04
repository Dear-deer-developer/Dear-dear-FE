import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportService {
  final Dio dio = Dio();

  Future<bool> createReport({
    required int reportedUserId,
    required int letterId,
    required String reason,
  }) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://dearxmas.com:3000';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print('ReportService: 토큰 없음');
        return false;
      }

      // 서버가 요구하는 바디 형식
      final data = {
        "targetUserId": reportedUserId,
        "letterId": letterId,
        "reason": reason
      };

      print('ReportService: 신고 요청 시작');
      print('신고 데이터: $data');

      final response = await dio.post(
        '$baseUrl/reports',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('ReportService: 서버 응답: ${response.statusCode}');
      print(response.data);

      if (response.statusCode == 201) {
        print('ReportService: 신고 성공');
        return true;
      }

      print('ReportService: 신고 실패 - 상태코드: ${response.statusCode}');
      return false;
    } catch (e) {
      print('ReportService: 신고 요청 중 오류 발생: $e');
      return false;
    }
  }
}
