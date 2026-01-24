import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/view/login/sign_up_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum EmailCheckState { idle, checking, available, unavailable }

class SignupEmailController extends GetxController {
  final emailCtrl = TextEditingController();
  final codeCtrl = TextEditingController();

  final emailState = EmailCheckState.idle.obs;
  final isValidEmail = false.obs;
  final emailError = ''.obs;

  final sending = false.obs; // 코드 발송 로딩
  final codeSent = false.obs; // 코드 발송 완료 여부
  final verifying = false.obs; // 코드 검증 로딩

  // 추가 ⬇️
  final code = ''.obs; // 인증코드 반응형 상태
  final agreeRequired = false.obs;

  final isAgreed = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    isAgreed.value = (args?['isAgreed'] as bool?) ?? false;
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    codeCtrl.dispose();
    super.onClose();
  }

  void onEmailChanged(String v) {
    final t = v.trim();
    isValidEmail.value = _validEmail(t);
    // 이메일이 바뀌면 상태 초기화
    emailState.value = EmailCheckState.idle;
    emailError.value = '';
    codeSent(false);
  }

  bool get canConfirm =>
      code.value.trim().length >= 6 && codeSent.value && !verifying.value;
  bool get canSend =>
      emailState.value == EmailCheckState.available && !sending.value;

  Future<void> onCheckDuplicate() async {
    final email = emailCtrl.text.trim();
    if (!_validEmail(email)) {
      emailState.value = EmailCheckState.unavailable;
      emailError.value = '이메일 형식을 확인해주세요.';
      return;
    }

    emailState.value = EmailCheckState.checking;
    emailError.value = '';
    try {
      final ok = await Get.find<AuthService>().isEmailAvailable(email);
      if (ok) {
        emailState.value = EmailCheckState.available; // ✅ 초록 테두리
        emailError.value = '';
      } else {
        emailState.value = EmailCheckState.unavailable; // ❌ 빨간 테두리
        emailError.value = '사용할 수 없는 이메일입니다.';
      }
    } catch (e, st) {
      logger.e('onCheckDuplicate 예외', error: e, stackTrace: st);
      emailState.value = EmailCheckState.unavailable;
      emailError.value = '네트워크 오류가 발생했습니다.';
    }
  }

  void onCodeChanged(String v) => code.value = v;

  Future<void> onSendCode() async {
    if (!canSend) return;

    final email = emailCtrl.text.trim();
    sending(true);
    try {
      final ok = await Get.find<AuthService>().sendSignupEmailCode(email);
      codeSent.value = ok; // ✅ 발송 성공 시 true
      // 필요하면 여기서 타이머 시작/쿨다운 처리도 추가 가능
    } catch (e, st) {
      logger.e('onSendCode 예외', error: e, stackTrace: st);
      codeSent.value = false;
    } finally {
      sending(false);
    }
  }

  Future<void> onConfirmCode() async {
    final email = emailCtrl.text.trim();
    final codeInput = code.value.trim(); // ✅ Rx에서 읽기
    if (codeInput.length < 6) return;

    verifying(true);
    try {
      final ok =
          await Get.find<AuthService>().verifySignupEmailCode(email, codeInput);
      if (ok) {
        Get.to(() => SignUpPassword(), arguments: {
          'email': email,
          'isAgreed': isAgreed.value,
        });
      }
    } catch (e, st) {
      logger.e('onConfirmCode 예외', error: e, stackTrace: st);
    } finally {
      verifying(false);
    }
  }

  bool _validEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
}
