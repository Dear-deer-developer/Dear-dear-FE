import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupEmailController extends GetxController {
  final emailCtrl = TextEditingController();

  final isChecking = false.obs; // 중복 확인(=인증코드 전송) 중 로딩
  final isChecked = false.obs; // 중복 확인 성공 여부
  final isValidEmail = false.obs; // 이메일 형식 유효성

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }

  void onEmailChanged(String v) {
    isValidEmail.value = _validEmail(v.trim());
    // 이메일이 바뀌면 다시 확인 필요
    if (isChecked.value) isChecked.value = false;
  }

  Future<void> onCheckPressed() async {
    final email = emailCtrl.text.trim();
    if (!_validEmail(email)) {
      Get.snackbar('이메일', '올바른 이메일을 입력해주세요.');
      return;
    }

    isChecking.value = true;
    try {
      // 서버: 중복 체크를 겸한 "가입용 인증코드 전송" API 라고 가정
      final ok = await Get.find<AuthService>().sendSignupEmailCode(email);
      if (ok) {
        isChecked.value = true;
        Get.snackbar('발송 완료', '인증코드를 이메일로 보냈습니다.');
      } else {
        isChecked.value = false;
        Get.snackbar('실패', '중복 확인 또는 코드 발송에 실패했습니다.');
      }
    } catch (e, st) {
      logger.e('onCheckPressed 예외', error: e, stackTrace: st);
      Get.snackbar('오류', '일시적 오류가 발생했습니다.');
    } finally {
      isChecking.value = false;
    }
  }

  bool get canNext => isChecked.value; // 확인 성공 시에만 다음 활성화

  bool _validEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
}
