// lib/controller/auth/sign_up_controller.dart
import 'dart:async';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/view/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final nicknameCtrl = TextEditingController();
  // 입력 & 상태
  final nickname = ''.obs;

  final isSubmitting = false.obs;
  final canSubmit = false.obs;
  final errorText = RxnString();

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    nicknameCtrl.addListener(_onNicknameChanged);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    nicknameCtrl.removeListener(_onNicknameChanged);
    nicknameCtrl.dispose();
    super.onClose();
  }

  // ── 입력 변화 처리 ─────────────────────────────────────────────
  void _onNicknameChanged() {
    final value = nicknameCtrl.text.trim();

    // ✅ Rx 업데이트
    nickname.value = value;

    errorText.value = _validateNickname(value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      canSubmit.value = errorText.value == null && value.isNotEmpty;
    });
  }

  // ── 닉네임 유효성 검사 ───────────────────────────────────────
  String? _validateNickname(String value) {
    if (value.isEmpty) return '닉네임을 입력하세요.';
    if (value.length < 2) return '닉네임은 2자 이상이어야 합니다.';
    if (value.length > 16) return '닉네임은 16자 이하로 입력하세요.';
    final invalid = RegExp(r'[^\w\uAC00-\uD7A3]+'); // 한글/영문/숫자/밑줄 허용
    if (invalid.hasMatch(value)) return '특수문자는 사용할 수 없어요.';
    return null;
  }

  // ── 제출 액션 ───────────────────────────────────────────────
  Future<void> submit() async {
    if (isSubmitting.value) return;

    final nick = nicknameCtrl.text.trim();
    final err = _validateNickname(nick);
    if (err != null) {
      errorText.value = err;
      return;
    }

    try {
      isSubmitting(true);

      // 서버 PATCH /users/nickname
      final api = Get.find<ApiService>();
      final DeardeerUser? updated = await api.setNickname(nick);

      if (updated == null) {
        Get.snackbar('실패', '닉네임 저장에 실패했습니다. 다시 시도해 주세요.');
        return;
      }

      // 전역 Auth 상태 갱신
      final auth = Get.find<AuthService>();
      auth.user.value = updated;

      // 성공 UX
      Get.offAll(() => const Home());
      Get.snackbar('완료', '닉네임이 설정되었습니다.');
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('SignUp submit error: $e');
        debugPrintStack(stackTrace: st);
      }
      Get.snackbar('오류', '처리 중 문제가 발생했습니다.');
    } finally {
      isSubmitting(false);
    }
  }
}
