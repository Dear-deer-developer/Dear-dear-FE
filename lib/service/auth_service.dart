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

      final res = await api.postJson(
        '/auth/native/login',
        data: {
          'email': email,
          'password': password,
        },
      );
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

  // MARK: 이메일 인증
  final isEmailVerified = false.obs; // 가입용 이메일 인증 완료 플래그

  // 이메일 중복 확인 (코드 발송 아님)
  Future<bool> isEmailAvailable(String email) async {
    try {
      final api = Get.find<ApiService>();

      // ✅ GET + query 로 호출 (스웨거 스펙)
      final res = await api.get(
        '/auth/native/check-email',
        query: {'email': email},
      );

      logger.i(
          '[이메일 중복확인] email=$email, status=${res.statusCode}, body=${res.bodyString}');

      if (res.statusCode == 200) return true; // 사용 가능
      if (res.statusCode == 409) return false; // 이미 사용 중
      logger.w('check-email 예외 응답: ${res.statusCode} ${res.bodyString}');
      return false;
    } catch (e, st) {
      logger.e('isEmailAvailable 예외', error: e, stackTrace: st);
      return false;
    }
  }

  // 이메일 인증코드 전송
  Future<bool> sendSignupEmailCode(String email) async {
    try {
      final api = Get.find<ApiService>();
      final res = await api.postJson(
        '/auth/native/register/auth-code',
        data: {'email': email},
      );

      logger.i('[이메일 인증코드 요청] email=$email, status=${res.statusCode}');

      if (res.statusCode == 200) {
        logger.i('✅ 인증 코드 발송 성공');
        return true;
      }

      if (res.statusCode == 409) {
        logger.w('⚠️ 중복된 이메일 - 이미 가입된 이메일입니다.');
      } else if (res.statusCode == 400) {
        logger.w('⚠️ 잘못된 이메일 형식입니다.');
      } else {
        logger.e('❌ 인증코드 요청 실패: ${res.statusCode} ${res.bodyString}');
      }
      return false;
    } catch (e, st) {
      logger.e('❌ sendSignupEmailCode 예외', error: e, stackTrace: st);
      return false;
    }
  }

  // 2) 이메일 인증코드 확인
  Future<bool> verifySignupEmailCode(String email, String code) async {
    try {
      final api = Get.find<ApiService>();
      final res = await api.postJson(
        '/auth/native/register/verify-code',
        data: {'email': email, 'code': code},
      );

      logger.i(
          '[이메일 인증코드 검증] email=$email, code=$code, status=${res.statusCode}');

      if (res.statusCode == 200) {
        logger.i('✅ 이메일 인증 성공');
        isEmailVerified(true);
        return true;
      }

      if (res.statusCode == 400) {
        logger.w('⚠️ 인증 실패 - 코드 불일치 또는 만료됨');
      } else {
        logger.e('❌ 인증코드 검증 실패: ${res.statusCode} ${res.bodyString}');
      }
      return false;
    } catch (e, st) {
      logger.e('❌ verifySignupEmailCode 예외', error: e, stackTrace: st);
      return false;
    }
  }

  // 3) 최종 회원가입 (스웨거: "사전에 반드시 '회원가입용 이메일 인증' API를 호출해야 함")
  Future<LoginResult> register({
    required String email,
    required String password,
    required String nickname,
    required bool isAgreed,
  }) async {
    if (!isEmailVerified.value) {
      logger.w('⚠️ 이메일 인증 미완료 상태에서 회원가입 시도됨');
      return const LoginResult(
        isSuccess: false,
        message: '이메일 인증을 먼저 완료해주세요.',
      );
    }

    try {
      final api = Get.find<ApiService>();
      final res = await api.postJson('/auth/native/register', data: {
        'email': email,
        'password': password,
        'nickname': nickname,
        //  'agreeMarketing': agreeMarketing ?? false,
        'isAgreed': isAgreed,
      });

      logger.i('[회원가입 요청] email=$email, status=${res.statusCode}');

      logger.i('[회원가입 payload] ${jsonEncode({
            'email': email,
            'password': '***',
            'nickname': nickname,
            'isAgreed': isAgreed,
          })}');

      if (res.statusCode == 201) {
        logger.i('✅ 회원가입 성공');

        // 토큰이 함께 오는 경우 처리
        if ((res.bodyString ?? '').isNotEmpty) {
          try {
            final body = jsonDecode(res.bodyString!) as Map<String, dynamic>;
            final access = body['accessToken'] as String?;
            final refresh = body['refreshToken'] as String?;

            if (access != null && access.isNotEmpty) {
              await _persistTokens(access, refresh);
              _logAccessOnce();
              await fetchMe();
              logger.i('🔑 토큰 저장 및 사용자 정보 갱신 완료');
              return const LoginResult(
                isSuccess: true,
                message: '회원가입 및 로그인 완료',
              );
            }
          } catch (e) {
            logger.w('회원가입 응답 파싱 중 예외 발생 (body가 비었을 가능성)');
          }
        }
        return const LoginResult(isSuccess: true, message: '회원가입 완료');
      }

      if (res.statusCode == 401) {
        logger.w('⚠️ 이메일 인증이 완료되지 않음');
        return const LoginResult(
          isSuccess: false,
          message: '이메일 인증이 완료되지 않았습니다.',
        );
      }

      if (res.statusCode == 409) {
        logger.w('⚠️ 중복된 이메일/닉네임');
        return const LoginResult(
          isSuccess: false,
          message: '이미 사용 중인 이메일/닉네임입니다.',
        );
      }

      logger.e('❌ 회원가입 실패 - status:${res.statusCode}, body:${res.bodyString}');
      return const LoginResult(isSuccess: false, message: '회원가입 실패');
    } catch (e, st) {
      logger.e('❌ register 예외', error: e, stackTrace: st);
      return const LoginResult(isSuccess: false, message: '네트워크 오류');
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
