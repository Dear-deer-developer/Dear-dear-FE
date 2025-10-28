import 'dart:convert';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/util/mem_cache.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final Rxn<DeardeerUser> user = Rxn<DeardeerUser>();

  bool get isLoggedIn {
    // 런타임 캐시 우선 + SharedPreferences fallback
    String? access = MemCache.get(MemCacheKey.jwtAccessToken) as String?;
    access ??= sharedPreferences.getString(SharedPreferencesKeys.accessToken);
    return (access != null && access.isNotEmpty) && user.value != null;
  }

// 전역으로 로그인 토큰 값 불러오기
  String? get accessTokenQuick =>
      (MemCache.get(MemCacheKey.jwtAccessToken) as String?) ??
      sharedPreferences.getString(SharedPreferencesKeys.accessToken);

  @override
  void onInit() {
    super.onInit();

    // ApiService는 MainBindings에서 먼저 등록되도록 순서 보장할 것
    if (!Get.isRegistered<ApiService>()) {
      logger.w('ApiService not registered yet. Check MainBindings order.');
    }

    // 🔻 초기 복구 책임 단일화: 토큰 + 유저 모두 여기서 복구
    _restoreFromStorage();
  }

  // MARK: 로그인: POST /auth/native/login
  Future<LoginResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final api = Get.find<ApiService>();

      final res = await api.postJson('/auth/native/login', {
        'email': email,
        'password': password,
      });

      final bodyStr = res.bodyString;
      if (res.statusCode != 200 || bodyStr == null || bodyStr.isEmpty) {
        logger.e('loginWithEmail 실패: ${res.statusCode} ${res.bodyString}');
        return const LoginResult(isSuccess: false, message: '로그인 실패');
      }

      Map<String, dynamic> body;
      try {
        body = jsonDecode(bodyStr) as Map<String, dynamic>;
      } catch (e) {
        logger.e('loginWithEmail JSON 파싱 실패', error: e);
        return const LoginResult(isSuccess: false, message: '서버 응답 오류');
      }

      final access = body['accessToken'] as String?;
      final refresh = body['refreshToken'] as String?;

      if (access == null || access.isEmpty) {
        logger.e('loginWithEmail 토큰 없음: $bodyStr');
        return const LoginResult(isSuccess: false, message: '토큰 없음');
      }

      // ✅ 로그인 직후 한 번만 AccessToken 로그 출력
      logger.i('로그인 토큰 : $access');

      await _persistTokens(access, refresh);
      _logAccessOnce();

      // 유저 프로필 시도 (/users/me) — 실패해도 로그인은 성공
      DeardeerUser? u;
      try {
        // final me = await api.get('/users/me');
        final me = await _getWithRefresh('/users/me');
        if (me.statusCode == 200 && me.bodyString?.isNotEmpty == true) {
          final map = jsonDecode(me.bodyString!) as Map<String, dynamic>;
          u = DeardeerUser.fromJson(map);
          await _persistUser(u);
          user.value = u;
        } else {
          logger.w('get /users/me 실패: ${me.statusCode} ${me.bodyString}');
        }
      } catch (e, st) {
        logger.w('get /users/me 예외', error: e, stackTrace: st);
      }

      logger.i('로그인 성공(토큰 기반). user=${u?.email ?? u?.nickname ?? 'null'}');
      return LoginResult(isSuccess: true, user: u);
    } catch (e, st) {
      logger.e('loginWithEmail 예외', error: e, stackTrace: st);
      return const LoginResult(isSuccess: false, message: '예기치 못한 오류');
    }
  }

  // MARK: 로그아웃
  Future<bool> logout() async {
    try {
      await _clearAuthLocal();
      logger.i('로그아웃 완료');
      return true;
    } catch (e, st) {
      logger.e('로그아웃 예외', error: e, stackTrace: st);
      return false;
    }
  }

  // 내 정보 재조회: GET /auth/me
  Future<bool> fetchMe() async {
    try {
      // final api = Get.find<ApiService>();
      // final res = await api.get('/auth/me');

      final res = await _getWithRefresh('/users/me');

      final bodyStr = res.bodyString;
      if (res.statusCode == 200 && bodyStr != null && bodyStr.isNotEmpty) {
        try {
          final map = jsonDecode(bodyStr) as Map<String, dynamic>;
          final u = DeardeerUser.fromJson(map);
          await _persistUser(u);
          user.value = u;
          return true;
        } catch (e) {
          logger.e('fetchMe 파싱 실패', error: e);
        }
      } else {
        logger.e('fetchMe 실패: ${res.statusCode} ${res.bodyString}');
      }
      return false;
    } catch (e, st) {
      logger.e('fetchMe 예외', error: e, stackTrace: st);
      return false;
    }
  }

  // MARK: refreshToken 갱신
  Future<bool> refreshAccessToken() async {
    try {
      // 저장된 refreshToken 읽기
      final rt = (MemCache.get(MemCacheKey.jwtRefreshToken) as String?) ??
          sharedPreferences.getString(SharedPreferencesKeys.refreshToken);

      if (rt == null || rt.isEmpty) {
        logger.w('refreshAccessToken: refreshToken 없음');
        return false;
      }

      final api = Get.find<ApiService>();
      // refresh 스펙: 헤더에 'refresh-token'
      final res = await api.post(
        '/auth/native/refresh',
        {}, // 보통 바디 불필요
        headers: {
          'Content-Type': 'application/json',
          'refresh-token': rt,
          // (ApiService에서 Authorization 자동부착이 있다면 끄는 옵션이 있을 수 있음.
          // 없다면 이대로 두면 됨. Authorization 없이도 동작해야 함)
        },
      );

      final bodyStr = res.bodyString;
      if (res.statusCode != 200 || bodyStr == null || bodyStr.isEmpty) {
        logger.e('refreshAccessToken 실패: ${res.statusCode} ${res.bodyString}');
        return false;
      }

      Map<String, dynamic> body;
      try {
        body = jsonDecode(bodyStr) as Map<String, dynamic>;
      } catch (e) {
        logger.e('refreshAccessToken JSON 파싱 실패', error: e);
        return false;
      }

      // 백엔드 키 이름에 맞춰 읽기
      final newAccess = body['accessToken'] as String?;
      final newRefresh = body['refreshToken'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        logger.e('refreshAccessToken: accessToken 없음');
        return false;
      }

      await _persistTokens(newAccess, newRefresh ?? rt);
      logger.i('🔄 AccessToken 갱신 완료');
      return true;
    } catch (e, st) {
      logger.e('refreshAccessToken 예외', error: e, stackTrace: st);
      return false;
    }
  }

  Future<Response> _getWithRefresh(String path) async {
    final api = Get.find<ApiService>();
    Response res = await api.get(path);
    if (res.statusCode == 401) {
      final ok = await refreshAccessToken();
      if (ok) {
        res = await api.get(path); // 1회 재시도
      }
    }
    return res;
  }

  // -------------------- 내부 유틸 --------------------

  // ✅ 단일화된 복구 진입점 (main.dart에서는 더 이상 복구하지 않음)
  void _restoreFromStorage() {
    final isRegistered =
        sharedPreferences.getBool(SharedPreferencesKeys.isRegistered) ?? false;
    if (!isRegistered) {
      logger.d('🚫 복구 생략: 등록된 사용자 없음');
      user.value = null;
      return;
    }

    // 토큰/유저 읽기
    final cachedUserJson =
        sharedPreferences.getString(SharedPreferencesKeys.deardeerUserJson);
    final accessToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);
    final refreshToken =
        sharedPreferences.getString(SharedPreferencesKeys.refreshToken);

    // MemCache 적재
    if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
      MemCache.put(MemCacheKey.deardeerUserJson, cachedUserJson);
      try {
        user.value = DeardeerUser.fromJson(jsonDecode(cachedUserJson));
      } catch (e) {
        logger.e('유저 JSON 파싱 실패(복구)', error: e);
        user.value = null;
      }
    } else {
      user.value = null;
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      MemCache.put(MemCacheKey.jwtAccessToken, accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      MemCache.put(MemCacheKey.jwtRefreshToken, refreshToken);
    }

    logger.d('✅ 복구 완료 (JWT)');
    // ✅ 자동 로그인(복구) 시에도 1회만 토큰 로그 출력
    _logAccessOnce();
  }

  Future<void> _persistTokens(String access, String? refresh) async {
    await sharedPreferences.setString(
        SharedPreferencesKeys.accessToken, access);
    MemCache.put(MemCacheKey.jwtAccessToken, access);

    if (refresh != null && refresh.isNotEmpty) {
      await sharedPreferences.setString(
          SharedPreferencesKeys.refreshToken, refresh);
      MemCache.put(MemCacheKey.jwtRefreshToken, refresh);
    }
  }

  Future<void> _persistUser(DeardeerUser u) async {
    final jsonStr = jsonEncode(u.toJson());
    await sharedPreferences.setString(
        SharedPreferencesKeys.deardeerUserJson, jsonStr);
    MemCache.put(MemCacheKey.deardeerUserJson, jsonStr);
  }

  Future<void> _clearAuthLocal() async {
    await sharedPreferences.remove(SharedPreferencesKeys.accessToken);
    await sharedPreferences.remove(SharedPreferencesKeys.refreshToken);
    await sharedPreferences.remove(SharedPreferencesKeys.deardeerUserJson);

    // 전체 clear() 대신 관련 키만 제거
    MemCache.remove(MemCacheKey.jwtAccessToken);
    MemCache.remove(MemCacheKey.jwtRefreshToken);
    MemCache.remove(MemCacheKey.deardeerUserJson);

    user.value = null;
  }
}

bool _tokenLoggedOnce = false;

void _logAccessOnce() {
  if (_tokenLoggedOnce) return;

  final access = (MemCache.get(MemCacheKey.jwtAccessToken) as String?) ??
      sharedPreferences.getString(SharedPreferencesKeys.accessToken);

  if (access != null && access.isNotEmpty) {
    // 배포시엔 전체 노출이 위험하니 필요하면 마스킹/가드를 사용하세요.
    // if (kReleaseMode) return; // ← 배포에서 끄고 싶다면 활성화
    logger.i('로그인 토큰 : $access');
    _tokenLoggedOnce = true;
  }
}

class LoginResult {
  final DeardeerUser? user;
  final bool isSuccess;
  final bool isNewUser;
  final String? message;

  const LoginResult({
    required this.isSuccess,
    this.isNewUser = false,
    this.user,
    this.message,
  });
}
