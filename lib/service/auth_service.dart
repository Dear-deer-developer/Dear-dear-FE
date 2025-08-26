import 'dart:convert';

import 'package:dear_deer_demo/main.dart'
    show sharedPreferences; // global SharedPreferences
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/util/helper/auth_helper.dart';
import 'package:dear_deer_demo/util/helper/kakao_auth_helper.dart';
import 'package:dear_deer_demo/util/mem_cache.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  AuthHelper? helper; // 플랫폼 헬퍼 (카카오)
  String? token; // Firebase ID Token
  final Rxn<DeardeerUser> user = Rxn<DeardeerUser>();

  @override
  void onInit() {
    // 1) 캐시 복구 (WeTeam 패턴)
    final firebaseIdToken = MemCache.get(MemCacheKey.firebaseAuthIdToken);
    final userJson = MemCache.get(MemCacheKey.deardeerUserJson);

    if (firebaseIdToken != null) {
      token = firebaseIdToken as String?;
    }
    if (userJson != null) {
      try {
        user.value = DeardeerUser.fromJson(jsonDecode(userJson as String));
      } catch (_) {
        user.value = null;
      }
    }

    // 2) 공급자 추정 (현재 카카오만 사용)
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      helper = KakaoAuthHelper();
      if (kDebugMode) print('카카오');
    }

    // 3) ApiService 주입
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService());
    }

    super.onInit();
  }

  /// 로그인: helper → kakao SDK 로그인/교환 → Firebase signIn → 토큰 캐시
  /// (유저 정보는 닉네임 API 응답으로만 세팅됨)
  Future<LoginResult> login(AuthHelper authHelper) async {
    try {
      // 기존 세션 정리
      if (helper != null && await helper!.isLoggedIn()) {
        await logout();
      }

      helper = authHelper;

      // 1) 플랫폼 로그인 (서버 /auth/kakao 교환 & Firebase signIn은 KakaoAuthHelper 내부에서)
      final ok = await helper!.login();
      if (!ok) {
        debugPrint("helper 로그인 실패");
        return const LoginResult(isSuccess: false);
      }

      // 2) Firebase ID Token
      token = await helper!.getToken();
      if (kDebugMode) print('Firebase ID Token: $token');

      // 3) 토큰 메모리 캐시
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        MemCache.put(MemCacheKey.firebaseAuthIdToken, idToken);
      }

      // 4) 캐시된 user_json 복구 (있으면)
      final cached = sharedPreferences.getString('user_json');
      if (cached != null && cached.isNotEmpty) {
        try {
          user.value = DeardeerUser.fromJson(jsonDecode(cached));
        } catch (_) {/* ignore */}
      }

      // 🔐 여기서 '신규가입 여부' 판단을 모델에 의존하지 않고, 캐시 JSON으로만 안전 추정
      final isNewUser = _inferIsNewUserFromCache(cached);

      return LoginResult(
          isSuccess: true, user: user.value, isNewUser: isNewUser);
    } catch (e, st) {
      debugPrint("로그인 실패: $e");
      debugPrintStack(stackTrace: st);
      return const LoginResult(isSuccess: false);
    }
  }

  /// 로그아웃: 플랫폼 로그아웃 → Firebase signOut → 로컬 정리
  Future<bool> logout() async {
    try {
      if (helper != null) {
        final platformOk = await helper!.logout(); // 카카오 세션 종료
        if (!platformOk) return false;
      }
      await FirebaseAuth.instance.signOut();

      token = null;
      user.value = null;

      debugPrint("SharedPreferences의 데이터를 모두 삭제하는 중");
      await sharedPreferences.clear();
      MemCache.clear();

      return true;
    } catch (e, st) {
      debugPrint("로그아웃 중 예외발생: $e");
      debugPrintStack(stackTrace: st);
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      if (helper == null) return false;
      return await helper!.isLoggedIn();
    } catch (e) {
      debugPrint("로그인 상태 확인 중 예외발생: $e");
      return false;
    }
  }

  /// 회원 탈퇴 (백엔드 엔드포인트가 아직 없다면 false 처리)
  Future<bool> withdrawal() async {
    try {
      // TODO: 백엔드 탈퇴 엔드포인트 추가 시 ApiService에 구현 후 호출
      debugPrint("withdrawal: backend endpoint not implemented yet.");
      return false;
    } catch (e) {
      debugPrint("회원탈퇴 중 예외발생: $e");
      return false;
    }
  }

  /// 닉네임 등록/수정 후 최신 유저를 반영 (백엔드 응답으로만 user 세팅)
  // Future<DeardeerUser?> setNicknameAndRefresh(String nickname) async {
  //   try {
  //     final api = Get.find<ApiService>();
  //     final u = await api.setNickname(nickname);
  //     if (u != null) {
  //       user.value = u;

  //       // 캐싱 (MemCache + SharedPreferences)
  //       final jsonStr = jsonEncode({
  //         'pri': u.pri,
  //         'providerId': u.providerId,
  //         'nickname': u.nickname,
  //         'imageIdx': u.imageIdx,
  //         'createdAt': u.createdAt?.toIso8601String(),
  //       });
  //       MemCache.put(MemCacheKey.deardeerUserJson, jsonStr);
  //       await sharedPreferences.setString('user_json', jsonStr);
  //     }
  //     return u;
  //   } catch (e, st) {
  //     debugPrint("닉네임 반영 실패: $e");
  //     debugPrintStack(stackTrace: st);
  //     return null;
  //   }
  // }

  /// 외부에서 user_json을 전달받아 반영하고 싶을 때 사용(옵션)
  void setUserFromJsonString(String jsonStr) {
    try {
      final u = DeardeerUser.fromJson(jsonDecode(jsonStr));
      user.value = u;
      MemCache.put(MemCacheKey.deardeerUserJson, jsonStr);
      sharedPreferences.setString('user_json', jsonStr);
    } catch (_) {/* ignore */}
  }

  // ---------------------------------------------------------------------------
  // 내부 유틸: 모델에 의존하지 않고 신규가입 여부 추정
  // ---------------------------------------------------------------------------
  bool _inferIsNewUserFromCache(String? cachedJson) {
    if (cachedJson == null || cachedJson.isEmpty) {
      return true; // 캐시가 없으면 신규로 판단
    }
    try {
      final map = jsonDecode(cachedJson);
      if (map is Map<String, dynamic>) {
        final nn = map['nickname'];
        if (nn is String && nn.trim().isNotEmpty) {
          return false; // 닉네임 있으면 기존 사용자
        }
        // 만약 profile 기반 판단을 쓰고 싶다면:
        // final profile = map['profile'];
        // if (profile is Map) return false;
      }
    } catch (_) {/* ignore */}
    return true;
  }
}

class LoginResult {
  final DeardeerUser? user;
  final bool isSuccess;
  final bool isNewUser;

  const LoginResult({
    required this.isSuccess,
    this.isNewUser = false,
    this.user,
  });
}
