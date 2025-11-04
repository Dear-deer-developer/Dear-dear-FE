import 'package:dear_deer_demo/controller/login/signup_email_controller.dart';
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
    // 라우팅에서 바인딩하면 생략 가능
    if (!Get.isRegistered<SignupEmailController>()) {
      Get.put(SignupEmailController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 바
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

              // 타이틀
              Text('디어디어 가입을 환영합니다!', style: FontStyles.H1_bold_22),
              SizedBox(height: 4.h),
              Text('이메일을 입력해 주세요', style: FontStyles.B3_bold_15),
              SizedBox(height: 20.h),

              // 입력 + 중복확인 버튼
              Row(
                children: [
                  Expanded(child: _emailField()),
                  SizedBox(width: 8.w),
                  Obx(() {
                    final enabled = controller.isValidEmail.value &&
                        !controller.isChecking.value;
                    return _pillButton(
                      label: controller.isChecking.value ? '확인중...' : '중복 확인',
                      enabled: enabled,
                      onTap: enabled ? controller.onCheckPressed : null,
                    );
                  }),
                ],
              ),

              const Spacer(),

              // 다음 버튼
              Obx(() {
                final active = controller.canNext;
                return GestureDetector(
                  onTap:
                      active ? () => Get.toNamed('/signup/email-verify') : null,
                  behavior: HitTestBehavior.opaque,
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

  Widget _emailField() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_02, width: 1.w),
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
          contentPadding: EdgeInsets.only(left: 16.w, right: 12.w, bottom: 2.h),
        ),
      ),
    );
  }

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
