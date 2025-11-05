import 'package:dear_deer_demo/controller/login/sign_up_email_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpEmail extends GetView<SignupEmailController> {
  const SignUpEmail({super.key});

  @override
  Widget build(BuildContext context) {
    // 바인딩에서 주입하고 있으면 생략 가능
    if (!Get.isRegistered<SignupEmailController>()) {
      Get.put(SignupEmailController(), permanent: true);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 바
              Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Image.asset(
                      ImagePath.backIcon,
                      width: 48.w,
                      height: 48.h,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('회원가입',
                          style: FontStyles.H2_bold_17.copyWith(
                              color: Colors.black)),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 12.h),

              // 타이틀
              Text('디어디어 가입을 환영합니다!', style: FontStyles.H1_bold_22),
              SizedBox(height: 4.h),
              Text('이메일을 입력해 주세요', style: FontStyles.B3_bold_15),
              SizedBox(height: 20.h),

              // ================== (1) 이메일 + 중복 확인 ==================
              Row(
                children: [
                  Expanded(child: _emailField()),
                  SizedBox(width: 8.w),
                  Obx(() {
                    final checking =
                        controller.emailState.value == EmailCheckState.checking;
                    final enabled = controller.isValidEmail.value && !checking;
                    return _pillButton(
                      label: checking ? '확인중...' : '중복 확인',
                      enabled: enabled,
                      onTap: enabled ? controller.onCheckDuplicate : null,
                    );
                  }),
                ],
              ),

              // 사용 불가 문구
              Obx(() {
                final showErr = controller.emailState.value ==
                        EmailCheckState.unavailable &&
                    controller.emailError.isNotEmpty;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: showErr
                      ? Padding(
                          key: const ValueKey('err'),
                          padding: EdgeInsets.only(top: 8.h, left: 4.w),
                          child: Text(
                            controller.emailError.value,
                            style: FontStyles.S1_reg_13.copyWith(
                                color: AppColors.mainRed),
                          ),
                        )
                      : SizedBox(height: 8.h, key: const ValueKey('noerr')),
                );
              }),

              SizedBox(height: 16.h),

              // ================== (2) 인증번호 + 발송 ==================
              Row(
                children: [
                  Expanded(child: _codeField()),
                  SizedBox(width: 8.w),
                  Obx(() {
                    final enabled = controller.canSend; // 이메일 사용 가능일 때만 true
                    return _pillButton(
                      label: controller.sending.value ? '발송중...' : '발송',
                      enabled: enabled && !controller.sending.value,
                      onTap: enabled ? controller.onSendCode : null,
                    );
                  }),
                ],
              ),

              const Spacer(),

              // ================== (3) 하단 확인 버튼 ==================
              Obx(() {
                final code = controller.code.value; // ✅ 직접 읽기
                final sent = controller.codeSent.value; // ✅ 직접 읽기
                final verifying = controller.verifying.value; // ✅ 직접 읽기
                final active = code.trim().length >= 6 && sent && !verifying;

                return GestureDetector(
                  onTap: active ? controller.onConfirmCode : null,
                  child: Container(
                    height: 52.h,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 24.h),
                    decoration: BoxDecoration(
                      color: active ? AppColors.mainGreen : AppColors.G_01,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '확인',
                      style: FontStyles.Button_bold_17.copyWith(
                        color: active ? Colors.white : AppColors.G_02,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- 이메일 입력 필드 (상태에 따른 테두리 색) ---
  Widget _emailField() {
    return Obx(() {
      Color borderColor = AppColors.G_02;
      if (controller.emailState.value == EmailCheckState.available) {
        borderColor = AppColors.mainGreen; // 사용 가능
      } else if (controller.emailState.value == EmailCheckState.unavailable) {
        borderColor = AppColors.mainRed; // 사용 불가
      }
      return Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: TextField(
          controller: controller.emailCtrl,
          onChanged: controller.onEmailChanged,
          keyboardType: TextInputType.emailAddress,
          textAlignVertical: TextAlignVertical.center,
          style: FontStyles.B3_bold_15,
          cursorColor: AppColors.mainGreen,
          decoration: InputDecoration(
            hintText: 'example@dear.com',
            hintStyle: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 16.w, right: 12.w, bottom: 2.h),
          ),
        ),
      );
    });
  }

  // --- 인증번호 입력 필드 ---
  Widget _codeField() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_02, width: 1.w),
      ),
      child: TextField(
        controller: controller.codeCtrl,
        keyboardType: TextInputType.number,
        textAlignVertical: TextAlignVertical.center,
        style: FontStyles.B3_bold_15,
        cursorColor: AppColors.mainGreen,
        decoration: InputDecoration(
          hintText: '인증번호',
          hintStyle: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 16.w, right: 12.w, bottom: 2.h),
        ),
        onChanged: controller.onCodeChanged,
      ),
    );
  }

  // --- 캡슐 버튼(중복확인/발송 공용) ---
  Widget _pillButton({
    required String label,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.mainGreen : AppColors.G_01,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: FontStyles.B3_bold_15.copyWith(
            color: enabled ? Colors.white : AppColors.G_02,
          ),
        ),
      ),
    );
  }
}
