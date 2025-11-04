import 'package:dear_deer_demo/controller/login/sign_up_password_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/view/login/sign_up_nickname.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpPassword extends GetView<SignupPasswordController> {
  SignUpPassword({super.key});

  final String email = (Get.arguments?['email'] as String?) ?? '';

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SignupPasswordController>()) {
      Get.put(SignupPasswordController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Image.asset(ImagePath.backIcon,
                        width: 48.w, height: 48.h),
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

              Text('비밀번호를 입력해 주세요', style: FontStyles.H1_bold_22),
              SizedBox(height: 6.h),
              Text('비밀번호는 8~12자의 영문, 숫자, 특수기호를 조합하여 설정해 주세요.',
                  style: FontStyles.S1_reg_13),

              SizedBox(height: 18.h),

              // 비밀번호
              Obx(() {
                final valid = controller.isPwValid;
                final hasInput = controller.pw.value.isNotEmpty;
                final borderColor = !hasInput
                    ? AppColors.G_02
                    : (valid
                        ? AppColors.mainGreen
                        : AppColors.mainRed); // 초록/빨강

                return _pwField(
                  hint: '비밀번호 입력',
                  controller: controller.pwCtrl,
                  obscured: !controller.showPw.value,
                  onChanged: controller.onPwChanged,
                  onToggleObscure: () => controller.showPw.toggle(),
                  onClear: controller.clearPw,
                  borderColor: borderColor,
                );
              }),

              // 가이드/에러 문구
              Obx(() {
                if (controller.pw.value.isEmpty) return SizedBox(height: 8.h);
                final ok = controller.isPwValid;
                return Padding(
                  padding: EdgeInsets.only(left: 4.w, top: 6.h, bottom: 2.h),
                  child: Text(
                    ok ? '안전한 비밀번호입니다.' : '비밀번호는 8~12자의 영문, 숫자, 특수기호 조합이어야 해요.',
                    style: FontStyles.S1_reg_13.copyWith(
                      color: ok ? AppColors.mainGreen : AppColors.mainRed,
                    ),
                  ),
                );
              }),

              SizedBox(height: 10.h),

              // 비밀번호 확인
              Obx(() {
                final showState = controller.pw2.value.isNotEmpty;
                Color borderColor = AppColors.G_02;
                if (showState) {
                  borderColor = controller.isMatch
                      ? AppColors.mainGreen
                      : AppColors.mainRed;
                }
                return _pwField(
                  hint: '비밀번호 확인',
                  controller: controller.pw2Ctrl,
                  obscured: !controller.showPw2.value,
                  onChanged: controller.onPw2Changed,
                  onToggleObscure: () => controller.showPw2.toggle(),
                  onClear: controller.clearPw2,
                  borderColor: borderColor,
                );
              }),

              const Spacer(),

              // 다음 버튼 → 닉네임
              Obx(() {
                final active = controller.canNext;
                return GestureDetector(
                  onTap: active
                      ? () {
                          Get.to(() => SignUpNickname(), arguments: {
                            'email': email,
                            'password': controller.pw.value,
                          });
                        }
                      : null,
                  child: Container(
                    height: 52.h,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 24.h),
                    decoration: BoxDecoration(
                      color: active ? AppColors.mainGreen : AppColors.G_01,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '다음',
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

  Widget _pwField({
    required String hint,
    required TextEditingController controller,
    required bool obscured,
    required VoidCallback onToggleObscure,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
    required Color borderColor,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscured,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: FontStyles.B3_bold_15,
              cursorColor: AppColors.mainGreen,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 16.w, right: 12.w, bottom: 2.h),
              ),
            ),
          ),
          // 눈 아이콘
          GestureDetector(
            onTap: onToggleObscure,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(
                obscured
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18.r,
                color: AppColors.G_04,
              ),
            ),
          ),
          // X(지우기)
          GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: 10.w, left: 6.w),
              child:
                  Icon(Icons.close_rounded, size: 18.r, color: AppColors.G_04),
            ),
          ),
        ],
      ),
    );
  }
}
