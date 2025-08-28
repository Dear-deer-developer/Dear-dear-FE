import 'dart:convert';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/util/custom_get_connect.dart';
import 'package:dear_deer_demo/util/mem_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService extends CustomGetConnect implements GetxService {
  final String _baseUrl = "https://dearxmas.com";

  @override
  void onInit() {
    super.onInit();

    httpClient
      ..baseUrl = _baseUrl
      ..timeout = const Duration(seconds: 15);

// 모든 요청에 Firebase ID Token 자동 첨부 (WeTeam의 CustomGetConnect 역할)
    httpClient.addRequestModifier<dynamic>((request) async {
      // 1) MemCache 시도
      String? idToken =
          MemCache.get(MemCacheKey.firebaseAuthIdToken) as String?;

      // 2) 없으면 Firebase에서 최신 토큰
      idToken ??= await FirebaseAuth.instance.currentUser?.getIdToken();

      if (idToken != null && idToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $idToken';
      }
      // JSON 기본
      request.headers['Content-Type'] = 'application/json';
      return request;
    });
  }
  // ---------------------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------------------

  /// Kakao accessToken → Firebase customToken 교환
  /// - POST /auth/kakao
  /// Request: { "accessToken": "<kakao access token>" }
  /// Response(200): { "customToken": "<firebase custom token>" }
  Future<String?> exchangeKakaoAccessToken(String accessToken) async {
    final res = await post(
      '/auth/kakao',
      jsonEncode({'accessToken': accessToken}),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200 && res.bodyString != null) {
      try {
        final body = jsonDecode(res.bodyString!) as Map<String, dynamic>;
        final customToken = body['customToken'] as String?;
        return (customToken != null && customToken.isNotEmpty)
            ? customToken
            : null;
      } catch (e) {
        debugPrint('exchangeKakaoAccessToken 파싱 실패: $e / ${res.bodyString}');
        return null;
      }
    }

    debugPrint(
        'exchangeKakaoAccessToken 실패: ${res.statusCode} / ${res.bodyString}');
    return null;
  }

  /// (선택) 서버에 Firebase ID Token을 전달
  /// - POST /auth/id-token
  /// Request: { "idToken": "<firebase id token>" }
  /// Response: 201(or 200) 이면 성공으로 간주
  Future<bool> submitFirebaseIdToken(String idToken) async {
    final res = await post(
      '/auth/id-token',
      jsonEncode({'idToken': idToken}),
      headers: {'Content-Type': 'application/json'},
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  // ---------------------------------------------------------------------------
  // USERS
  // ---------------------------------------------------------------------------

  /// 사용자 닉네임 생성/수정
  /// - PATCH /users/nickname
  /// Request: { "nickname": "디디디어" }
  /// Response(200):
  /// {
  ///   "pri": 1,
  ///   "providerId": "123456789",
  ///   "nickname": "디디디어",
  ///   "imageIdx": 1001,
  ///   "createdAt": "2025-01-05T08:00:00.000Z"
  /// }
  Future<DeardeerUser?> setNickname(String nickname) async {
    final res = await patch(
      '/users/nickname',
      jsonEncode({'nickname': nickname}),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200 && res.bodyString != null) {
      try {
        final map = jsonDecode(res.bodyString!) as Map<String, dynamic>;
        final user = DeardeerUser.fromJson(map);

        // 캐시(재시작 복구 용)
        await sharedPreferences.setString('user_json', res.bodyString!);

        return user;
      } catch (e) {
        debugPrint('setNickname 파싱 실패: $e / ${res.bodyString}');
        return null;
      }
    }

    debugPrint('setNickname 실패: ${res.statusCode} / ${res.bodyString}');
    return null;
  }

  // ---------------------------------------------------------------------------
  // 유틸 (선택) JSON POST/PATCH 래퍼
  // ---------------------------------------------------------------------------

  Future<Response> postJson(String path, Map<String, dynamic> data,
      {Map<String, String>? headers}) {
    return post(
      path,
      jsonEncode(data),
      headers: {'Content-Type': 'application/json', ...?headers},
    );
  }

  Future<Response> patchJson(String path, Map<String, dynamic> data,
      {Map<String, String>? headers}) {
    return patch(
      path,
      jsonEncode(data),
      headers: {'Content-Type': 'application/json', ...?headers},
    );
  }
}
