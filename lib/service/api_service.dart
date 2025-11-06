// MARK: - JWT Token 자체 로그인 ver.
import 'dart:convert';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/custom_get_connect.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/util/mem_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ApiService extends CustomGetConnect implements GetxService {
  final String _baseUrl = "https://dearxmas.com"; // ← 누락된 .com 복원

  @override
  void onInit() {
    super.onInit();

    httpClient
      ..baseUrl = _baseUrl
      ..timeout = const Duration(seconds: 15);

    // ✅ 모든 요청에 JWT AccessToken 자동 첨부 (리프레시/로그인 예외)
    httpClient.addRequestModifier<dynamic>((request) async {
      // 1) 토큰
      String? accessToken = MemCache.get(MemCacheKey.jwtAccessToken) as String?;
      accessToken ??=
          sharedPreferences.getString(SharedPreferencesKeys.accessToken);

      // 2) Authorization 제외할 경로 (로그인/리프레시)
      const noAuthPaths = {
        '/auth/native/login',
        '/auth/native/refresh',
        '/auth/native/register',
        '/auth/native/register-email/send',
        '/auth/native/register-email/verify',
      };

      // 3) Authorization 헤더 (필요할 때만)
      if (accessToken != null &&
          accessToken.isNotEmpty &&
          !noAuthPaths.contains(request.url.path)) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      // 4) JSON 기본 헤더
      request.headers['Content-Type'] = 'application/json';
      logger.t('➡️ ${request.method} ${request.url}');
      return request;
    });

    // 응답 로깅
    httpClient.addResponseModifier<dynamic>((request, response) {
      logger.t('⬅️ [${response.statusCode}] ${request.method} ${request.url}');
      return response;
    });
  }

  // MARK: - 이메일 인증코드
  Future<Response> postSignupEmailSend(String email) {
    return postJson('/auth/native/register-email/send', data: {'email': email});
  }

  Future<Response> postSignupEmailVerify(String email, String code) {
    return postJson('/auth/native/register-email/verify',
        data: {'email': email, 'code': code});
  }

  /// 현재 저장된 JWT 토큰 반환
  Future<String?> getToken() async {
    String? accessToken = MemCache.get(MemCacheKey.jwtAccessToken) as String?;
    accessToken ??=
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);
    return accessToken;
  }

  // MARK: - User API
  Future<DeardeerUser?> setNickname(String nickname) async {
    final res = await patch(
      '/users/nickname',
      jsonEncode({'nickname': nickname}),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200 && (res.bodyString?.isNotEmpty ?? false)) {
      try {
        final map = jsonDecode(res.bodyString!) as Map<String, dynamic>;
        final user = DeardeerUser.fromJson(map);

        await sharedPreferences.setString(
            'user_json', jsonEncode(user.toJson()));

        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().user.value = user;
        }
        return user;
      } catch (e) {
        debugPrint('setNickname 파싱 실패: $e / ${res.bodyString}');
        return null;
      }
    }

    if (res.statusCode == 204) return null;

    debugPrint('setNickname 실패: ${res.statusCode} / ${res.bodyString}');
    return null;
  }

  Future<DeardeerUser?> getUser() async {
    final res = await get('/users/me');

    if (res.statusCode == 200 && res.bodyString != null) {
      try {
        final map = jsonDecode(res.bodyString!) as Map<String, dynamic>;
        final user = DeardeerUser.fromJson(map);
        await sharedPreferences.setString('user_json', res.bodyString!);
        return user;
      } catch (e) {
        debugPrint('getUser 파싱 실패: $e / ${res.bodyString}');
        return null;
      }
    }

    debugPrint('getUser 실패: ${res.statusCode} / ${res.bodyString}');
    return null;
  }

  // MARK: - 공통 요청 메서드
  Future<Response<T>> guardedGet<T>(String path) async {
    Response<T> res = await get<T>(path);
    if (res.statusCode == 401) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) res = await get<T>(path);
    }
    return res;
  }

  Future<Response<T>> guardedPostJson<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    Response<T> res = await post<T>(
      path,
      jsonEncode(data),
      headers: {'Content-Type': 'application/json', ...?headers},
    );
    if (res.statusCode == 401) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        res = await post<T>(
          path,
          jsonEncode(data),
          headers: {'Content-Type': 'application/json', ...?headers},
        );
      }
    }
    return res;
  }

  Future<Response<T>> guardedPatchJson<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    Response<T> res = await patch<T>(
      path,
      jsonEncode(data),
      headers: {'Content-Type': 'application/json', ...?headers},
    );
    if (res.statusCode == 401) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) {
        res = await patch<T>(
          path,
          jsonEncode(data),
          headers: {'Content-Type': 'application/json', ...?headers},
        );
      }
    }
    return res;
  }

  // MARK: - 공통 JSON 요청 헬퍼
  Future<Response> postJson(String path, {Map<String, dynamic>? data}) {
    return post(
      path,
      data != null ? jsonEncode(data) : null,
      headers: {'Content-Type': 'application/json'},
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

  Future<Response> deleteJson(String path, {Map<String, dynamic>? data}) {
    if (data != null && data.isNotEmpty) {
      final query = data.entries.map((e) {
        final value = e.value;
        if (value is List) {
          // 예: letterIds=[1,2] → letterIds=1&letterIds=2
          return value
              .map((v) =>
                  '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(v.toString())}')
              .join('&');
        } else {
          return '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(value.toString())}';
        }
      }).join('&');
      path = '$path?$query';
    }

    return delete(
      path,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<dynamic> getJson(String path, {Map<String, String>? headers}) async {
    final res = await guardedGet(path);

    if (res.statusCode == 200) {
      try {
        if (res.bodyString?.isNotEmpty ?? false) {
          return jsonDecode(res.bodyString!);
        }
      } catch (e) {
        debugPrint('getJson 파싱 실패: $e');
      }
    }

    debugPrint('getJson 실패: ${res.statusCode} / ${res.bodyString}');
    return null;
  }

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
