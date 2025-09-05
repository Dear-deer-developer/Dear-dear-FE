import 'dart:convert';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
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

// 모든 요청에 Firebase ID Token 자동 첨부
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
  // MARK: - AUTH
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
  Future<DeardeerUser?> setNickname(String nickname) async {
    final res = await patch(
      '/users/nickname',
      jsonEncode({'nickname': nickname}),
      headers: {'Content-Type': 'application/json'},
    );

    // === 정상 응답(JSON Body 포함) ===
    if (res.statusCode == 200 && (res.bodyString?.isNotEmpty ?? false)) {
      try {
        final map = jsonDecode(res.bodyString!) as Map<String, dynamic>;
        final user = DeardeerUser.fromJson(map);

        // 캐시 갱신
        await sharedPreferences.setString(
            'user_json', jsonEncode(user.toJson()));

        // 전역 상태(AuthService.user)도 같이 갱신해두면 편리
        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().user.value = user;
        }

        return user;
      } catch (e) {
        debugPrint('setNickname 파싱 실패: $e / ${res.bodyString}');
        return null;
      }
    }

    // === No Content(204) ===
    if (res.statusCode == 204) {
      // 서버가 바디 없이 성공만 주는 경우 → 바로 getUser() 호출해서 최신화 필요
      return null;
    }

    // === 기타 실패 ===
    debugPrint('setNickname 실패: ${res.statusCode} / ${res.bodyString}');
    return null;
  }

  Future<DeardeerUser?> getUser() async {
    final res = await get('/users/me');

    if (res.statusCode == 200 && res.bodyString != null) {
      try {
        final map = jsonDecode(res.bodyString!) as Map<String, dynamic>;
        final user = DeardeerUser.fromJson(map);

        // 재시작 복구용 캐시
        await sharedPreferences.setString('user_json', res.bodyString!);

        return user;
      } catch (e) {
        debugPrint('getMe 파싱 실패: $e / ${res.bodyString}');
        return null;
      }
    }

    debugPrint('getMe 실패: ${res.statusCode} / ${res.bodyString}');
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

  /// 캐시된 유저 JSON을 우선 복구
  DeardeerUser? getCachedUser() {
    final raw = sharedPreferences.getString('user_json');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return DeardeerUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
