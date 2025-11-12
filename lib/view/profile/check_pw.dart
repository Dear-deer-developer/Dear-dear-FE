import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/view/profile/withdraw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CheckPw extends GetView<AuthController> {
  const CheckPw({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    // 새 진입 시 초기화
    controller.resetWithdrawFlow();

    final obscure = true.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Image.asset(ImagePath.backIcon,
                        width: 48.w, height: 48.h),
                  ),
                  SizedBox(width: 93.w),
                  Text('회원 탈퇴', style: FontStyles.H2_bold_17),
                ],
              ),
              SizedBox(height: 19.h),

              Text('본인 확인을 위해\n비밀번호를 입력해 주세요.', style: FontStyles.H1_bold_22),
              SizedBox(height: 24.h),

              // 비밀번호 입력
              Obx(() => Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: controller.withdrawPw.value.isEmpty
                            ? AppColors.G_02
                            : AppColors.mainGreen,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            obscureText: obscure.value,
                            onChanged: controller.setWithdrawPassword,
                            onSubmitted: (_) => _goNextIfPossible(),
                            style: FontStyles.B3_bold_15,
                            cursorColor: AppColors.mainGreen,
                            decoration: InputDecoration(
                              hintText: '비밀번호',
                              hintStyle: FontStyles.B3_reg_15.copyWith(
                                  color: AppColors.G_05),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 16.w, right: 12.w, bottom: 2.h),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => obscure.toggle(),
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Icon(
                              obscure.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20.w,
                              color: AppColors.G_05,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 12.h),

              Obx(() => controller.withdrawPw.value.isEmpty
                  ? Text('비밀번호를 입력해 주세요.',
                      style:
                          FontStyles.S1_reg_13.copyWith(color: AppColors.G_06))
                  : const SizedBox.shrink()),

              const Spacer(),

              // 다음 버튼
              Obx(() {
                final active = controller.canGoConfirm;
                return GestureDetector(
                  onTap: active ? _goNextIfPossible : null,
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
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

  void _goNextIfPossible() {
    final c = Get.find<AuthController>();
    if (c.canGoConfirm) {
      logger.i('[WITHDRAW PW] 입력 완료 (len=${c.withdrawPw.value.length})');
      Get.to(() => Withdraw()); // 다음 단계로 이동
    }
  }
}
