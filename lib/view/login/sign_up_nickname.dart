import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/controller/login/sign_up_nickname_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/view/login/login_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpNickname extends GetView<SignupNicknameController> {
  SignUpNickname({super.key}) {
    if (!Get.isRegistered<SignupNicknameController>()) {
      Get.put(SignupNicknameController());
    }
  }

  // ⬇️ 이전 단계에서 전달된 값들
  final email = (Get.arguments?['email'] as String?) ?? '';
  final password = (Get.arguments?['password'] as String?) ?? '';
  final bool isAgreed = (Get.arguments?['isAgreed'] as bool?) ?? false;

  @override
  Widget build(BuildContext context) {
    logger.i('[Nickname] agreeRequired=$isAgreed'); // ✅ 확인용 로그
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 108.h,
          ),
          Text(
            '사용하실 닉네임을 알려주세요!',
            style: FontStyles.H1_bold_22,
          ),
          Text(
            '다른 유저에게 공개되는 이름으로, 수정이 불가능해요.',
            style: FontStyles.S1_reg_13,
          ),
          SizedBox(
            height: 92.h,
          ),
          // 닉네임 입력 필드

          // 입력 박스
          Obx(() {
            final error = controller.helperError;
            final borderColor = error == null
                ? (controller.len == 0 ? AppColors.G_02 : AppColors.mainGreen)
                : AppColors.mainRed;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: borderColor, width: 1.w),
                  ),
                  child: Row(
                    children: [
                      // 텍스트필드
                      Expanded(
                        child: TextField(
                          controller: controller.nickCtrl,
                          onChanged: controller.onChanged,
                          maxLength: 8, // UI 카운터는 커스텀으로, 기본 카운터 숨김
                          buildCounter: (_,
                                  {required currentLength,
                                  maxLength,
                                  required isFocused}) =>
                              const SizedBox.shrink(),
                          textAlignVertical: TextAlignVertical.center,
                          style: FontStyles.B3_bold_15,
                          cursorColor: AppColors.mainGreen,
                          decoration: InputDecoration(
                            hintText: '닉네임',
                            hintStyle: FontStyles.B3_reg_15.copyWith(
                                color: AppColors.G_05),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 16.w, right: 12.w, bottom: 2.h),
                          ),
                        ),
                      ),
                      // 우상단 길이 카운터
                      Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Text('${controller.len}/8',
                            style: FontStyles.S1_reg_13.copyWith(
                                color: AppColors.G_05)),
                      ),
                    ],
                  ),
                ),
                // 헬퍼/에러 텍스트
                SizedBox(height: 8.h),
                Text(
                  error ??
                      '최소 2글자, 최대 8글자까지 입력 가능합니다.\n영문, 한글, 숫자만 입력 가능해요. (특수문자, 공백, 이모지 불가)',
                  style: FontStyles.S1_reg_13.copyWith(
                    color: error == null ? AppColors.G_05 : AppColors.mainRed,
                  ),
                ),
              ],
            );
          }),

          const Spacer(),

          // 확인하기 버튼
          Obx(() {
            final active = controller.isValid && !controller.loading.value;
            return GestureDetector(
              onTap: active ? _onSubmit : null,
              child: Container(
                height: 52.h,
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.mainGreen : AppColors.G_01,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  controller.loading.value ? '처리 중...' : '확인하기',
                  style: FontStyles.Button_bold_17.copyWith(
                    color: active ? Colors.white : AppColors.G_02,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    controller.loading(true);
    try {
      // 🔎 디버그 로그로 최종 전달 값 점검
      logger.i('[REGISTER args] email=$email, isAgreed=$isAgreed, '
          'nick=${controller.nick.value}, isEmailVerified='
          '${Get.find<AuthService>().isEmailVerified.value}');

      final res = await Get.find<AuthService>().register(
        email: email,
        password: password,
        nickname: controller.nick.value,
        isAgreed: isAgreed, // 동의는 앞 단계에서 완료
      );

      if (res.isSuccess) {
        // ✅ 회원가입 성공 로그
        logger.i('✅ 회원가입 완료: $email (${controller.nick.value})');

        // ✅ SharedPreferences 초기화
        await sharedPreferences.clear();
        // 입력 포커스/스낵바 정리
        FocusManager.instance.primaryFocus?.unfocus();
        if (Get.isSnackbarOpen) Get.closeAllSnackbars();

        // ✅ 로그인 화면으로 이동 (새 컨트롤러 바인딩)
        await Future<void>.delayed(Duration.zero);
        await WidgetsBinding.instance.endOfFrame;
        Get.offAll(
          () => const LoginMain(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => AuthController());
          }),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<SignupNicknameController>()) {
            Get.delete<SignupNicknameController>(force: true);
          }
          // AuthService는 절대 지우지 마세요 (앱 공용 서비스)
        });
      } else {
        // ❌ 회원가입 실패
        logger.w('❌ 회원가입 실패 - message: ${res.message ?? "서버 응답 없음"}');
      }
    } catch (e, st) {
      logger.e('❌ 회원가입 예외 발생', error: e, stackTrace: st);
    } finally {
      controller.loading(false);
    }
  }
}
