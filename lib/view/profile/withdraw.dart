import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Withdraw extends StatelessWidget {
  Withdraw({super.key});

  final RxBool agreed = false.obs; // ✅ 동의 체크 상태

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final user = auth.user.value; // 로그인한 유저 정보 가져오기
    final ctrl = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: _body(user, ctrl),
      ),
    );
  }

  Widget _body(DeardeerUser? user, AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단바
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
            SizedBox(width: 93.w),
            Text(
              '회원 탈퇴',
              style: FontStyles.H2_bold_17,
            ),
          ],
        ),
        SizedBox(height: 19.h),

        // ✅ 닉네임 표시
        Text(
          '잠시만요, ${user?.nickname}님!',
          style: FontStyles.H1_bold_22,
        ),
        SizedBox(height: 24.h),
        Text(
          '- 계정 탈퇴시, 모든 데이터가 삭제됩니다.',
          style: FontStyles.B5_reg_13.copyWith(color: AppColors.G_06),
        ),
        SizedBox(height: 16.h),
        Text(
          '- 삭제된 데이터는 복구가 불가능합니다..',
          style: FontStyles.B5_reg_13.copyWith(color: AppColors.G_06),
        ),
        SizedBox(height: 16.h),
        Text(
          '- 위의 사항에 동의하며 탈퇴 진행을 원할 경우,\n아래 동의하기 버튼을 눌러 탈퇴를 진행해주세요..',
          style: FontStyles.B5_reg_13.copyWith(color: AppColors.G_06),
        ),

        Spacer(), // ✅ 비밀번호 입력

        // ✅ 체크박스 + 탈퇴 버튼
        Obx(() {
          final agreed = controller.withdrawAgree.value;
          final canSubmit = controller.canWithdraw;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => controller.withdrawAgree.toggle(),
                child: Row(
                  children: [
                    Image.asset(
                      agreed ? ImagePath.checkboxOn : ImagePath.checkboxOff,
                      width: 20.w,
                      height: 20.h,
                    ),
                    SizedBox(width: 8.w),
                    Text('위 내용에 동의합니다.',
                        style:
                            FontStyles.B3_reg_15.copyWith(color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(height: 38.h),

              // 탈퇴하기
              GestureDetector(
                onTap: canSubmit
                    ? () {
                        logger.i(
                            '회원탈퇴 요청: agree=$agreed, pwLen=${controller.withdrawPwCtrl.text.length}');
                        controller.withdraw();
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: canSubmit ? AppColors.mainGreen : AppColors.G_01,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    controller.isLoading.value ? '처리 중...' : '탈퇴하기',
                    style: FontStyles.Button_bold_17.copyWith(
                      color: canSubmit ? Colors.white : AppColors.G_02,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
