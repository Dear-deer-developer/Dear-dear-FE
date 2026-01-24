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

  bool get canGoConfirm =>
      withdrawPw.value.trim().isNotEmpty && !isLoading.value;

  bool get canWithdraw =>
      withdrawAgree.value &&
      withdrawPw.value.trim().isNotEmpty &&
      !isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _resetWithdrawState();

    withdrawPwCtrl.addListener(() {
      withdrawPw.value = withdrawPwCtrl.text;
    });
  }

  void resetWithdrawFlow() {
    withdrawAgree.value = false;
    withdrawPw.value = '';
    withdrawPwCtrl.text = '';
  }

  void _resetWithdrawState() {
    withdrawAgree.value = false;
    withdrawPwCtrl.text = '';
  }

  void setWithdrawPassword(String v) {
    withdrawPwCtrl.text = v;
    update();
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

  //MARK: 회원가입 (기존 로직 유지)
  Future<void> registerLEGACY() async {
    final email = signEmailCtrl.text.trim();
    final pw1 = signPwCtrl.text;
    final nick = signNicknameCtrl.text.trim();
    final randomZip = 10000 + Random().nextInt(90000);

    final agreeRequired = (Get.arguments?['agreeRequired'] as bool?) ?? false;

    logger.i('[회원가입 버튼 클릭됨]');
    logger.i('입력값 => email:$email, pw1_len:${pw1.length}, nick:$nick');

    final emailValid = _validEmail(email);
    final pwValid = _validPw(pw1);
    final nickValid = _validNick(nick);

    if (!emailValid || !pwValid || !nickValid) {
      Get.snackbar('회원가입', '입력값을 확인해주세요.');
      return;
    }

    isLoading(true);
    try {
      final api = Get.find<ApiService>();
      final payload = {
        'email': email,
        'password': pw1,
        'nickname': nick,
        'isAgreed': agreeRequired,
        'agreeRequired': agreeRequired,
        'zipCode': randomZip,
      };

      final res = await api.postJson('/auth/native/register', data: payload);

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('회원가입', '완료되었습니다. 로그인해주세요!');

        FocusManager.instance.primaryFocus?.unfocus();
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
        await Future<void>.delayed(Duration.zero);
        await WidgetsBinding.instance.endOfFrame;

        // ✅ 로그인 화면으로 갈 때도 "새 AuthController" 보장
        if (Get.isRegistered<AuthController>()) {
          Get.delete<AuthController>(force: true);
        }
        Get.offAll(
          () => const LoginMain(),
          binding: BindingsBuilder(() {
            Get.put(AuthController());
          }),
        );
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
      final updated = await api.setNickname(nick);

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
        FocusManager.instance.primaryFocus?.unfocus();
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();
        await Future<void>.delayed(Duration.zero);
        await WidgetsBinding.instance.endOfFrame;

        // ✅ 탈퇴 후 로그인 화면 전환: 기존 AuthController 삭제 후 재생성
        if (Get.isRegistered<AuthController>()) {
          Get.delete<AuthController>(force: true);
        }

        Get.offAll(
          () => const LoginMain(),
          binding: BindingsBuilder(() {
            Get.put(AuthController());
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
      FocusManager.instance.primaryFocus?.unfocus();
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();

      final ok = await Get.find<AuthService>().logout();
      logger.i('로그아웃 요청 결과:$ok');

      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

      // ✅ 핵심: 기존 AuthController 완전 삭제 (dispose된 TextEditingController 재사용 방지)
      if (Get.isRegistered<AuthController>()) {
        Get.delete<AuthController>(force: true);
      }

      // ✅ 로그인 화면으로 가면서 새 AuthController 생성 보장
      Get.offAll(
        () => const LoginMain(),
        binding: BindingsBuilder(() {
          Get.put(AuthController());
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
