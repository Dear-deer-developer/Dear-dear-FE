import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class S3Service {
  final Dio _dio = Dio();

  /// letter 업로드용 presigned URL 발급
  Future<Map<String, dynamic>?> getLetterPresignedUrl({
    required String filename,
    required String contentType,
  }) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'https://dearxmas.com';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
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
        print('presigned URL 발급 성공: ${response.data}');
        return Map<String, dynamic>.from(response.data);
      } else {
        print('presigned URL 발급 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('S3 presigned URL 요청 중 오류: $e');
      return null;
    }
  }

  /// S3에 실제 업로드
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
          validateStatus: (status) => status! < 500,
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

  Future<String?> getImagePresignedUrl(String key) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'https://dearxmas.com';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final res = await _dio.get(
        '$baseUrl/s3/image-url',
        queryParameters: {'key': key},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200 && res.data['url'] != null) {
        return res.data['url'];
      }
      return null;
    } catch (e) {
      print('getImagePresignedUrl 오류: $e');
      return null;
    }
  }
}
