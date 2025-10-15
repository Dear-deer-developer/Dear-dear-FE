import 'dart:async';
import 'package:dear_deer_demo/app.dart';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/view/login/login_main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  // 로그인 폼
  final loginEmailCtrl = TextEditingController();
  final loginPwCtrl = TextEditingController();

  // 회원가입 폼
  final signEmailCtrl = TextEditingController();
  final signPwCtrl = TextEditingController();
  final signPw2Ctrl = TextEditingController();
  final signNicknameCtrl = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    loginEmailCtrl.dispose();
    loginPwCtrl.dispose();
    signEmailCtrl.dispose();
    signPwCtrl.dispose();
    signPw2Ctrl.dispose();
    signNicknameCtrl.dispose();
    super.onClose();
  }

  // 로그인
  Future<void> login() async {
    final email = loginEmailCtrl.text.trim();
    final pw = loginPwCtrl.text;

    if (!_validEmail(email) || pw.isEmpty) {
      Get.snackbar('로그인', '이메일/비밀번호를 확인해주세요.');
      return;
    }

    isLoading(true);
    try {
      final auth = Get.find<AuthService>();
      final r = await auth.loginWithEmail(email: email, password: pw);

      if (!r.isSuccess) {
        Get.snackbar('로그인 실패', r.message ?? '이메일/비밀번호를 확인해주세요.');
        return;
      }

      await sharedPreferences.setBool(SharedPreferencesKeys.isRegistered, true);
      Get.offAll(() => const App());

      logger.i('✅ 로그인 성공: $email');
    } catch (e, st) {
      logger.e('login 예외', error: e, stackTrace: st);
      Get.snackbar('오류', '일시적 오류가 발생했습니다.');
    } finally {
      isLoading(false);
    }
  }

  // 회원가입
  Future<void> register() async {
    final email = signEmailCtrl.text.trim();
    final pw1 = signPwCtrl.text;
    final pw2 = signPw2Ctrl.text;
    final nick = signNicknameCtrl.text.trim();

    if (!_validEmail(email) ||
        !_validPw(pw1) ||
        pw1 != pw2 ||
        !_validNick(nick)) {
      Get.snackbar('회원가입', '입력값을 확인해주세요.');
      return;
    }

    isLoading(true);
    try {
      final api = Get.find<ApiService>();
      final res = await api.postJson('/auth/register', {
        'email': email,
        'password': pw1,
        'passwordConfirm': pw2,
        'nickname': nick,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('회원가입', '완료되었습니다. 로그인해주세요!');
        Get.offAll(() => const LoginMain());
        return;
      }
      Get.snackbar('회원가입 실패', res.bodyString ?? '서버 오류');
    } catch (e, st) {
      logger.e('register 예외', error: e, stackTrace: st);
      Get.snackbar('오류', '일시적 오류가 발생했습니다.');
    } finally {
      isLoading(false);
    }
  }

  // 확인하기
  Future<void> submitNickname() async {
    final nick = signNicknameCtrl.text.trim();

    if (!_validNick(nick)) {
      Get.snackbar('닉네임', '닉네임 형식을 확인해주세요.');
      return;
    }

    isLoading(true);
    try {
      final api = Get.find<ApiService>();
      final updated = await api.setNickname(nick); // PATCH /users/nickname

      if (updated == null) {
        Get.snackbar('닉네임 실패', '저장에 실패했습니다. 다시 시도해주세요.');
        return;
      }

      Get.offAll(() => const App());
      Get.snackbar('완료', '닉네임이 설정되었습니다.');
    } catch (e, st) {
      logger.e('submitNickname 예외', error: e, stackTrace: st);
      Get.snackbar('오류', '일시적 오류가 발생했습니다.');
    } finally {
      isLoading(false);
    }
  }

  // ─── validators (공용) ───
  bool _validEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
  bool _validPw(String v) => v.length >= 6;
  bool _validNick(String v) =>
      v.length >= 2 &&
      v.length <= 16 &&
      !RegExp(r'[^\w\uAC00-\uD7A3]+').hasMatch(v);
}
// // kakao login ver.
// import 'dart:async';
// import 'package:dear_deer_demo/model/deardeer_user.dart';
// import 'package:dear_deer_demo/service/api_service.dart';
// import 'package:dear_deer_demo/service/auth_service.dart';
// import 'package:dear_deer_demo/view/home/home.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SignUpController extends GetxController {
//   final nicknameCtrl = TextEditingController();
//   // 입력 & 상태
//   final nickname = ''.obs;

//   final isSubmitting = false.obs;
//   final canSubmit = false.obs;
//   final errorText = RxnString();

//   Timer? _debounce;

//   @override
//   void onInit() {
//     super.onInit();
//     nicknameCtrl.addListener(_onNicknameChanged);
//   }

//   @override
//   void onClose() {
//     _debounce?.cancel();
//     nicknameCtrl.removeListener(_onNicknameChanged);
//     nicknameCtrl.dispose();
//     super.onClose();
//   }

//   // ── 입력 변화 처리 ─────────────────────────────────────────────
//   void _onNicknameChanged() {
//     final value = nicknameCtrl.text.trim();

//     // ✅ Rx 업데이트
//     nickname.value = value;

//     errorText.value = _validateNickname(value);

//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 120), () {
//       canSubmit.value = errorText.value == null && value.isNotEmpty;
//     });
//   }

//   // ── 닉네임 유효성 검사 ───────────────────────────────────────
//   String? _validateNickname(String value) {
//     if (value.isEmpty) return '닉네임을 입력하세요.';
//     if (value.length < 2) return '닉네임은 2자 이상이어야 합니다.';
//     if (value.length > 16) return '닉네임은 16자 이하로 입력하세요.';
//     final invalid = RegExp(r'[^\w\uAC00-\uD7A3]+'); // 한글/영문/숫자/밑줄 허용
//     if (invalid.hasMatch(value)) return '특수문자는 사용할 수 없어요.';
//     return null;
//   }

//   // ── 제출 액션 ───────────────────────────────────────────────
//   Future<void> submit() async {
//     if (isSubmitting.value) return;

//     final nick = nicknameCtrl.text.trim();
//     final err = _validateNickname(nick);
//     if (err != null) {
//       errorText.value = err;
//       return;
//     }

//     try {
//       isSubmitting(true);

//       // 서버 PATCH /users/nickname
//       final api = Get.find<ApiService>();
//       final DeardeerUser? updated = await api.setNickname(nick);

//       if (updated == null) {
//         Get.snackbar('실패', '닉네임 저장에 실패했습니다. 다시 시도해 주세요.');
//         return;
//       }

//       // 전역 Auth 상태 갱신
//       final auth = Get.find<AuthService>();
//       auth.user.value = updated;

//       // 성공 UX
//       Get.offAll(() => const Home());
//       Get.snackbar('완료', '닉네임이 설정되었습니다.');
//     } catch (e, st) {
//       if (kDebugMode) {
//         debugPrint('SignUp submit error: $e');
//         debugPrintStack(stackTrace: st);
//       }
//       Get.snackbar('오류', '처리 중 문제가 발생했습니다.');
//     } finally {
//       isSubmitting(false);
//     }
//   }
// }
