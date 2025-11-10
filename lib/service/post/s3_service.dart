import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class S3Service {
  final Dio _dio = Dio();

  // MARK: - letter 업로드용 presigned URL 발급
  Future<Map<String, dynamic>?> getLetterPresignedUrl({
    required String filename,
    required String contentType,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://dearxmas.com';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        print('액세스 토큰이 없습니다.');
        return null;
      }

      final response = await _dio.get(
        '$baseUrl/s3/letter-presigned-url',
        queryParameters: {
          'filename': filename,
          'contentType': contentType,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print('Presigned URL 발급 성공: ${response.data}');
        return response.data; // 그대로 반환
      } else {
        print('Presigned URL 발급 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('S3 presigned URL 요청 중 오류: $e');
      return null;
    }
  }

  // MARK: - S3에 실제 이미지 업로드
  Future<bool> uploadToS3(
      String uploadUrl, List<int> bytes, String contentType) async {
    try {
      final res = await _dio.put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length,
          },
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        print('S3 업로드 성공');
        return true;
      } else {
        print('업로드 실패 코드: ${res.statusCode}, 응답: ${res.data}');
        return false;
      }
    } catch (e) {
      print('S3 업로드 실패: $e');
      return false;
    }
  }

  // MARK: - S3 이미지 표시용 presigned URL 재발급
  Future<String?> getImagePresignedUrl(String key) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://dearxmas.com';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final res = await _dio.get(
        '$baseUrl/s3/image-url',
        queryParameters: {'key': key},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200 && res.data['url'] != null) {
        print('이미지 presigned URL 발급 성공: ${res.data['url']}');
        return res.data['url'];
      }
      print('이미지 presigned URL 발급 실패: ${res.statusCode}');
      return null;
    } catch (e) {
      print('getImagePresignedUrl 오류: $e');
      return null;
    }
  }
}
