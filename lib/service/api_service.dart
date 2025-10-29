// MARK: - JWT Toekn 자체 로그인 ver.
//import 'dart:convert';
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
  final String _baseUrl = "https://dearxmas.com";

  @override
  void onInit() {
    super.onInit();

    httpClient
      ..baseUrl = _baseUrl
      ..timeout = const Duration(seconds: 15);

// 모든 요청에 JWT AccessToken 자동 첨부 (리프레시/로그인 예외)
    httpClient.addRequestModifier<dynamic>((request) async {
      // 1) 토큰
      String? accessToken = MemCache.get(MemCacheKey.jwtAccessToken) as String?;
      accessToken ??=
          sharedPreferences.getString(SharedPreferencesKeys.accessToken);

      // 2) Authorization 제외할 경로 (로그인/리프레시)
      const noAuthPaths = {
        '/auth/native/login',
        '/auth/native/refresh',
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

  Future<String?> getToken() async {
    // 1MemCache에서 먼저 시도
    String? accessToken = MemCache.get(MemCacheKey.jwtAccessToken) as String?;
    // 없으면 sharedPreferences에서 시도
    accessToken ??=
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);
    return accessToken;
  }

  // User
  /// 사용자 닉네임 생성/수정
  Future<DeardeerUser?> setNickname(String nickname) async {
    final res = await patch(
      '/users/nickname',
      jsonEncode({'nickname': nickname}),
      headers: {'Content-Type': 'application/json'},
    );

    // 성공 (JSON body 포함)
    if (res.statusCode == 200 && (res.bodyString?.isNotEmpty ?? false)) {
      try {
        final map = jsonDecode(res.bodyString!) as Map<String, dynamic>;
        final user = DeardeerUser.fromJson(map);

        // 캐시 갱신
        await sharedPreferences.setString(
            'user_json', jsonEncode(user.toJson()));

        // 전역 상태(AuthService.user) 갱신
        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().user.value = user;
        }
        return user;
      } catch (e) {
        debugPrint('setNickname 파싱 실패: $e / ${res.bodyString}');
        return null;
      }
    }

    // Body 없이 성공만 준 경우 (204)
    if (res.statusCode == 204) return null;

    // 실패
    debugPrint('setNickname 실패: ${res.statusCode} / ${res.bodyString}');
    return null;
  }

  /// 내 정보 조회
  Future<DeardeerUser?> getUser() async {
    final res = await get('/users/me');

    if (res.statusCode == 200 && res.bodyString != null) {
      try {
        final map = jsonDecode(res.bodyString!) as Map<String, dynamic>;
        final user = DeardeerUser.fromJson(map);

        // 로컬 캐시 저장 (앱 재시작 복구용)
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

  Future<Response<T>> guardedGet<T>(String path) async {
    Response<T> res = await get<T>(path);
    if (res.statusCode == 401) {
      final ok = await Get.find<AuthService>().refreshAccessToken();
      if (ok) res = await get<T>(path);
    }
    return res;
  }

  /// 401이면 refresh 후 1회 재시도하는 JSON POST
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

  /// 401이면 refresh 후 1회 재시도하는 JSON PATCH
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

  /// 캐시된 유저 정보 복구
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

  // MARK: - 일반 GET (JSON 응답용)
  Future<dynamic> getJson(String path, {Map<String, String>? headers}) async {
    final res = await guardedGet(path);

    if (res.statusCode == 200) {
      try {
        // bodyString이 비어 있지 않다면 JSON 디코드
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
}
