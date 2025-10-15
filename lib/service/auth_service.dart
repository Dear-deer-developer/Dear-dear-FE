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

  // 로그인: POST /auth/login
  Future<LoginResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final api = Get.find<ApiService>();
      final res = await api.postJson('/auth/login', {
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
      final userMap = body['user'] as Map<String, dynamic>?;

      if ((access == null || access.isEmpty) || userMap == null) {
        logger.e('loginWithEmail 응답 누락: $bodyStr');
        return const LoginResult(isSuccess: false, message: '응답 데이터 누락');
      }

      final u = DeardeerUser.fromJson(userMap);

      await _persistTokens(access, refresh);
      await _persistUser(u);
      user.value = u;

      logger.i('로그인 성공: ${u.email ?? u.nickname ?? 'no-identifier'}');
      return LoginResult(isSuccess: true, user: u);
    } catch (e, st) {
      logger.e('loginWithEmail 예외', error: e, stackTrace: st);
      return const LoginResult(isSuccess: false, message: '예기치 못한 오류');
    }
  }

  // 로그아웃
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
      final api = Get.find<ApiService>();
      final res = await api.get('/auth/me');

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

  // (옵션) 외부 문자열 유저 세팅 — 필요 없으면 제거 가능
  void setUserFromJsonString(String jsonStr) {
    try {
      final u = DeardeerUser.fromJson(jsonDecode(jsonStr));
      user.value = u;
      MemCache.put(MemCacheKey.deardeerUserJson, jsonStr);
      sharedPreferences.setString(
          SharedPreferencesKeys.deardeerUserJson, jsonStr);
      logger.i('setUserFromJsonString 적용 완료');
    } catch (e) {
      logger.e('setUserFromJsonString 실패', error: e);
    }
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

// class AuthService extends GetxService {
//   AuthHelper? helper; // 플랫폼 헬퍼 (카카오)
//   String? token; // Firebase ID Token

//   final Rxn<DeardeerUser> user = Rxn<DeardeerUser>();

//   @override
//   void onInit() {
//     try {
//       final cached = sharedPreferences
//           .getString('user_json'); // SharedPreferencesKeys.deardeerUserJson 권장
//       if (cached != null && cached.isNotEmpty) {
//         user.value = DeardeerUser.fromJson(jsonDecode(cached));
//       }
//       final savedToken = sharedPreferences
//           .getString('token'); // SharedPreferencesKeys.firebaseToken 권장
//       if (savedToken != null && savedToken.isNotEmpty) {
//         token = savedToken;
//       }
//     } catch (_) {
//       user.value = null;
//     }

//     // 1) 캐시 복구

//     final firebaseIdToken = MemCache.get(MemCacheKey.firebaseAuthIdToken);
//     final userJson = MemCache.get(MemCacheKey.deardeerUserJson);

//     if (firebaseIdToken != null) {
//       token = firebaseIdToken as String?;
//     }
//     if (userJson != null) {
//       try {
//         user.value = DeardeerUser.fromJson(jsonDecode(userJson as String));
//       } catch (_) {
//         user.value = null;
//       }
//     }

//     // 2) 공급자 추정 (현재 카카오만 사용)
//     final current = FirebaseAuth.instance.currentUser;
//     if (current != null) {
//       helper = KakaoAuthHelper();
//       if (kDebugMode) print('카카오');
//     }

//     // 3) ApiService 주입
//     if (!Get.isRegistered<ApiService>()) {
//       Get.put<ApiService>(ApiService());
//     }

//     super.onInit();
//   }

//   /// 로그인: helper → kakao SDK 로그인/교환 → Firebase signIn → 토큰 캐시
//   /// (유저 정보는 닉네임 API 응답으로만 세팅됨)
//   Future<LoginResult> login(AuthHelper authHelper) async {
//     try {
//       // 기존 세션 정리
//       if (helper != null && await helper!.isLoggedIn()) {
//         await logout();
//       }

//       helper = authHelper;

//       // 1) 플랫폼 로그인 (서버 /auth/kakao 교환 & Firebase signIn은 KakaoAuthHelper 내부에서)
//       final ok = await helper!.login();
//       if (!ok) {
//         debugPrint("helper 로그인 실패");
//         return const LoginResult(isSuccess: false);
//       }

//       // 2) Firebase ID Token
//       token = await helper!.getToken();
//       if (kDebugMode) print('Firebase ID Token: $token');

//       // 3) 토큰 메모리 캐시
//       final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
//       if (idToken != null && idToken.isNotEmpty) {
//         MemCache.put(MemCacheKey.firebaseAuthIdToken, idToken);
//         await sharedPreferences.setString('token', idToken);
//       }

//       // 4) 캐시된 user_json 복구 (있으면)
//       final cached = sharedPreferences.getString('user_json');
//       if (cached != null && cached.isNotEmpty) {
//         try {
//           user.value = DeardeerUser.fromJson(jsonDecode(cached));
//         } catch (_) {/* ignore */}
//       }

//       // 🔐 여기서 '신규가입 여부' 판단을 모델에 의존하지 않고, 캐시 JSON으로만 안전 추정
//       final isNewUser = _inferIsNewUserFromCache(cached);

//       return LoginResult(
//           isSuccess: true, user: user.value, isNewUser: isNewUser);
//     } catch (e, st) {
//       debugPrint("로그인 실패: $e");
//       debugPrintStack(stackTrace: st);
//       return const LoginResult(isSuccess: false);
//     }
//   }

//   /// 로그아웃: 플랫폼 로그아웃 → Firebase signOut → 로컬 정리
//   Future<bool> logout() async {
//     try {
//       if (helper != null) {
//         final platformOk = await helper!.logout(); // 카카오 세션 종료
//         if (!platformOk) return false;
//       }
//       await FirebaseAuth.instance.signOut();

//       token = null;
//       user.value = null;

//       debugPrint("SharedPreferences의 데이터를 모두 삭제하는 중");
//       await sharedPreferences.clear();
//       MemCache.clear();

//       return true;
//     } catch (e, st) {
//       debugPrint("로그아웃 중 예외발생: $e");
//       debugPrintStack(stackTrace: st);
//       return false;
//     }
//   }

//   Future<bool> isLoggedIn() async {
//     try {
//       if (helper == null) return false;
//       return await helper!.isLoggedIn();
//     } catch (e) {
//       debugPrint("로그인 상태 확인 중 예외발생: $e");
//       return false;
//     }
//   }

//   /// 회원 탈퇴 (백엔드 엔드포인트가 아직 없다면 false 처리)
//   Future<bool> withdrawal() async {
//     try {
//       // TODO: 백엔드 탈퇴 엔드포인트 추가 시 ApiService에 구현 후 호출
//       debugPrint("withdrawal: backend endpoint not implemented yet.");
//       return false;
//     } catch (e) {
//       debugPrint("회원탈퇴 중 예외발생: $e");
//       return false;
//     }
//   }

//   /// 외부에서 user_json을 전달받아 반영하고 싶을 때 사용(옵션)
//   void setUserFromJsonString(String jsonStr) {
//     try {
//       final u = DeardeerUser.fromJson(jsonDecode(jsonStr));
//       user.value = u;
//       MemCache.put(MemCacheKey.deardeerUserJson, jsonStr);
//       sharedPreferences.setString('user_json', jsonStr);
//     } catch (_) {/* ignore */}
//   }

//   // ---------------------------------------------------------------------------
//   // 내부 유틸: 모델에 의존하지 않고 신규가입 여부 추정
//   // ---------------------------------------------------------------------------
//   bool _inferIsNewUserFromCache(String? cachedJson) {
//     if (cachedJson == null || cachedJson.isEmpty) {
//       return true; // 캐시가 없으면 신규로 판단
//     }
//     try {
//       final map = jsonDecode(cachedJson);
//       if (map is Map<String, dynamic>) {
//         final nn = map['nickname'];
//         if (nn is String && nn.trim().isNotEmpty) {
//           return false; // 닉네임 있으면 기존 사용자
//         }
//       }
//     } catch (_) {/* ignore */}
//     return true;
//   }
// }

// class LoginResult {
//   final DeardeerUser? user;
//   final bool isSuccess;
//   final bool isNewUser;

//   const LoginResult({
//     required this.isSuccess,
//     this.isNewUser = false,
//     this.user,
//   });
// }
