// lib/util/custom_get_connect.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Dear.deer 공통 API 커넥트
/// - 모든 요청에 Firebase ID 토큰 자동 첨부
/// - GET, POST, DELETE, PATCH 오버라이드
class CustomGetConnect extends GetConnect {
  /// Authorization 헤더에 Firebase ID Token 추가
  Future<Map<String, String>?> putTokenToHeaders(
      Map<String, String>? headers) async {
    headers ??= {};

    // 이미 Authorization 헤더가 없다면 추가
    if (!headers.containsKey('Authorization')) {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  @override
  Future<Response<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    headers = await putTokenToHeaders(headers);
    return await super.get<T>(
      url,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String? url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) async {
    headers = await putTokenToHeaders(headers);
    return await super.post<T>(
      url,
      body,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    headers = await putTokenToHeaders(headers);
    return await super.delete<T>(
      url,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) async {
    headers = await putTokenToHeaders(headers);
    return await httpClient.patch<T>(
      url,
      body: body,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }
}
