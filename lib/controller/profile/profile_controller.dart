import 'dart:convert';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:dear_deer_demo/service/kakao_share_service.dart';

enum ShareType { kakao, system }

class ProfileController extends GetxController {
  final Rxn<DeardeerUser> me = Rxn<DeardeerUser>();
  final KakaoShareService _kakaoShareService = KakaoShareService();

  @override
  void onInit() {
    _restoreFromCache(); // 1) 캐시 선적용
    refreshMe(); // 2) 서버 최신화
    super.onInit();
  }

  // === 게터들 (뷰에서 사용) ===
  String getUserName() {
    final name = me.value?.nickname ?? '';
    logger.i('User Nickname: $name');
    return name;
  }

  String getZipCodeText() {
    final zc = me.value?.zipCode ?? 0;
    // 0 이거나 미설정이면 대시로 표시
    return zc > 0 ? zc.toString() : '--';
  }

  int getProfileImageIdx() {
    // 백엔드가 imageIdx를 주면 모델에 추가해 여기에 매핑
    return 0;
  }

  /// 서버에서 최신 유저 정보 가져와서 반영
  Future<void> refreshMe() async {
    final api = Get.find<ApiService>();
    final auth = Get.find<AuthService>();

    final DeardeerUser? fetched = await api.getUser();
    if (fetched != null) {
      me.value = fetched; // 로컬 상태
      auth.user.value = fetched; // 전역 상태(다른 화면에서도 반응)
    }
  }

  // === 내부: 캐시 복구 ===
  void _restoreFromCache() {
    final raw = sharedPreferences.getString('user_json');
    if (raw == null || raw.isEmpty) return;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final cached = DeardeerUser.fromJson(map);

      // 로컬/전역 동기화
      me.value = cached;
      if (Get.isRegistered<AuthService>()) {
        Get.find<AuthService>().user.value = cached;
      }
    } catch (_) {
      // 캐시 파싱 실패는 무시
    }
  }

  // MARK: 공유

  // 공유 문구
  String getZipCodeShareText() {
    final code = getZipCodeText(); // '--' 포함 가능
    return '내 사서함 번호: $code';
  }

  // Kakao 공유 문구 - 사서함
  Future<void> shareZipCodeToKakao() async {
    final code = getZipCodeText();

    if (code == '--') {
      Get.snackbar(
        '공유 불가',
        '사서함 번호가 설정되지 않았어요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    await _kakaoShareService.shareMailbox(code, getUserName());
  }

  /// 시스템 공유 시트 열기 (iOS/Android 공통)
  Future<void> shareZipCode(BuildContext context,
      {String source = 'profile_share_button'}) async {
    final text = getZipCodeShareText();

    // iPad/큰 화면에서 위치 지정 권장
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 0, 0);

    logger.i('[Share] tap: source=$source, text="$text", origin=$origin');

    try {
      await Share.share(
        text,
        subject: 'Dear.deer',
        sharePositionOrigin: origin,
      );
      // 호출 완료 로그 (성공/취소 구분 불가)
      logger.i('[Share] invoked: source=$source');
    } catch (e, st) {
      logger.e('[Share] error: source=$source, e=$e', stackTrace: st);
      // 에러 안내는 선택 사항
      Get.snackbar('공유 실패', '잠시 후 다시 시도해 주세요.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    }
  }

  /// 클립보드 복사 + 로깅
  Future<void> copyZipCode(
      {String source = 'profile_share_button_longpress'}) async {
    final text = getZipCodeShareText();
    logger.i('[Clipboard] copy start: source=$source, text="$text"');
    try {
      await Clipboard.setData(ClipboardData(text: text));
      logger.i('[Clipboard] copy done: source=$source');
      Get.snackbar('복사 완료', '사서함 번호가 클립보드에 복사됐어요.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 2));
    } catch (e, st) {
      logger.e('[Clipboard] error: source=$source, e=$e', stackTrace: st);
    }
  }
}
