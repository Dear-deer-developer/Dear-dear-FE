import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dear_deer_demo/app.dart';
import 'package:dear_deer_demo/binding/main_bindings.dart';
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

  // 회원탈퇴
  final withdrawAgree = false.obs;
  final withdrawPwCtrl = TextEditingController();
  final withdrawPw = ''.obs;

  final isLoading = false.obs;

  // ✅ 새로 추가: 비밀번호 입력만으로 다음 단계로 갈 수 있는 조건
  bool get canGoConfirm =>
      withdrawPw.value.trim().isNotEmpty && !isLoading.value;

  // ✅ 기존: 최종 탈퇴 버튼 활성화 조건
  bool get canWithdraw =>
      withdrawAgree.value &&
      withdrawPw.value.trim().isNotEmpty &&
      !isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _resetWithdrawState();

    // ✅ TextField <-> Rx 동기화
    withdrawPwCtrl.addListener(() {
      withdrawPw.value = withdrawPwCtrl.text;
    });
  }

  // ✅ 외부에서 접근 가능한 초기화 (check_pw.dart 진입 시 호출)
  void resetWithdrawFlow() {
    withdrawAgree.value = false;
    withdrawPw.value = '';
    withdrawPwCtrl.text = '';
  }

  // 기존 내부 함수는 유지해도 무방
  void _resetWithdrawState() {
    withdrawAgree.value = false;
    withdrawPwCtrl.text = '';
  }

  void setWithdrawPassword(String v) {
    withdrawPwCtrl.text = v;
    update(); // 버튼 활성화 즉시 반영
  }

  @override
  void onClose() {
    loginEmailCtrl.dispose();
    loginPwCtrl.dispose();
    signEmailCtrl.dispose();
    signPwCtrl.dispose();
    signPw2Ctrl.dispose();
    signNicknameCtrl.dispose();
    withdrawPwCtrl.dispose();
    super.onClose();
  }

  // MARK: 로그인
  Future<void> login() async {
    final email = loginEmailCtrl.text.trim();
    final pw = loginPwCtrl.text;

    if (!_validEmail(email) || pw.isEmpty) {
      Get.snackbar('로그인', '이메일/비밀번호를 확인해 주세요.');
      return;
    }

    isLoading(true);
    try {
      final auth = Get.find<AuthService>();
      final r = await auth.loginWithEmail(email: email, password: pw);

      if (!r.isSuccess) {
        Get.snackbar('로그인 실패', r.message ?? '이메일/비밀번호를 확인해 주세요.');
        return;
      }

      await sharedPreferences.setBool(SharedPreferencesKeys.isRegistered, true);
      // ✅ 전환 전에 포커스/스낵바 정리 + 프레임 종료 대기
      FocusManager.instance.primaryFocus?.unfocus();
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

      Get.offAll(() => const App(), binding: MainBindings());

      logger.i('로그인 성공: $email');
    } catch (e, st) {
      logger.e('login 예외', error: e, stackTrace: st);
      Get.snackbar('오류', '일시적 오류가 발생했습니다.');
    } finally {
      isLoading(false);
    }
  }

//MARK: 회원가입
  Future<void> registerLEGACY() async {
    final email = signEmailCtrl.text.trim();
    final pw1 = signPwCtrl.text;
    final nick = signNicknameCtrl.text.trim();
    final randomZip = 10000 + Random().nextInt(90000); // 0~89999 → 10000~99999

    final agreeRequired = (Get.arguments?['agreeRequired'] as bool?) ?? false;

    logger.i('[회원가입 버튼 클릭됨]');
    logger.i('입력값 => email:$email, pw1_len:${pw1.length}, nick:$nick');

    final emailValid = _validEmail(email);
    // 비밀번호 정책은 기존대로 (예: 8~20자 영문+숫자)
    final pwValid = _validPw(pw1);
    final nickValid = _validNick(nick);

    logger.i(
        '검증 결과 => emailValid:$emailValid, pwValid:$pwValid, nickValid:$nickValid');

    if (!emailValid || !pwValid || !nickValid) {
      logger.w('⚠️ 입력값 유효성 실패, 회원가입 중단');
      Get.snackbar('회원가입', '입력값을 확인해주세요.');
      return;
    }

    isLoading(true);
    try {
      logger.i('서버 요청 시작 → /auth/native/register');
      final api = Get.find<ApiService>();
      final payload = {
        'email': email,
        'password': pw1,
        'nickname': nick,
        'isAgreed': agreeRequired,
        'agreeRequired': agreeRequired,
        'zipCode': randomZip,
        // 'passwordConfirm': pw1,   // 서버가 필요하면 이 줄을 주석 해제
      };
      logger.i('[REGISTER args] '
          'email=$email, isAgreed=$agreeRequired '
          '(type:${agreeRequired.runtimeType}), ');
      logger.i('[REGISTER payload] ${jsonEncode(payload)}');
      logger.i('요청 바디: $payload');

      final res = await api.postJson(
        '/auth/native/register',
        data: payload,
      );

      logger.i('서버 응답 상태코드: ${res.statusCode}');
      logger.i('서버 응답 본문: ${res.bodyString}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        logger.i('회원가입 성공: $email');
        Get.snackbar('회원가입', '완료되었습니다. 로그인해주세요!');
        // ✅ 전환 안정화
        FocusManager.instance.primaryFocus?.unfocus();
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
        await Future<void>.delayed(Duration.zero);
        await WidgetsBinding.instance.endOfFrame;
        Get.offAll(() => const LoginMain());
        return;
      }

      logger.w('❌ 회원가입 실패 - status:${res.statusCode}');
      Get.snackbar('회원가입 실패', res.bodyString ?? '서버 오류');
    } catch (e, st) {
      logger.e('register 예외', error: e, stackTrace: st);
      Get.snackbar('오류', '일시적 오류가 발생했습니다.');
    } finally {
      isLoading(false);
      logger.i('회원가입 처리 완료, isLoading=false');
    }
  }

  // MARK: 확인하기
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

      FocusManager.instance.primaryFocus?.unfocus();
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

      Get.offAll(() => const App(), binding: MainBindings());
      Get.snackbar('완료', '닉네임이 설정되었습니다.');
    } catch (e, st) {
      logger.e('submitNickname 예외', error: e, stackTrace: st);
      Get.snackbar('오류', '일시적 오류가 발생했습니다.');
    } finally {
      isLoading(false);
    }
  }

  // MARK: 회원탈퇴
  Future<void> withdraw() async {
    if (!canWithdraw || isLoading.value) return;
    isLoading(true);
    try {
      final password = withdrawPw.value.trim();
      final ok = await Get.find<AuthService>().withdraw(password);

      if (ok) {
        // ✅ 전역 SharedPreferences/캐시 초기화는 AuthService.withdraw 내부에서 이미 처리됨(_clearAuthLocal)
        // ✅ 여기서는 "화면 트리 교체 + 새 바인딩"만 책임지자
        FocusManager.instance.primaryFocus?.unfocus();
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
        await Future<void>.delayed(Duration.zero);
        await WidgetsBinding.instance.endOfFrame;
        Get.offAll(
          () => const LoginMain(),
          binding: BindingsBuilder(() {
            // 로그인 화면에서도 AuthController 요청 시 재생성 보장
            if (!Get.isRegistered<AuthController>()) {
              Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
            }
          }),
        );
      } else {
        Get.snackbar('탈퇴', '실패했습니다. 비밀번호를 확인해주세요.');
      }
    } catch (e, st) {
      logger.e('[WITHDRAW] 예외', error: e, stackTrace: st);
    } finally {
      isLoading(false);
    }
  }

  //MARK: 로그아웃
  Future<void> logout() async {
    if (isLoading.value) return;
    isLoading(true);

    try {
      // 키보드/텍스트 선택 제스처 차단
      FocusManager.instance.primaryFocus?.unfocus();
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();

      final ok = await Get.find<AuthService>().logout();
      logger.i('로그아웃 요청 결과:$ok');

      // 같은 프레임에서 남아있는 제스처/selection 처리가 끝나도록 대기
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

      // 🔧 LoginMain으로 이동하면서 새 AuthController 바인딩
      Get.offAll(
        () => const LoginMain(),
        binding: BindingsBuilder(() {
          Get.lazyPut<AuthController>(() => AuthController(), fenix: true); // ✅
        }),
      );
    } catch (e, st) {
      logger.e('❌ 로그아웃 실패', error: e, stackTrace: st);
      rethrow;
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
