import 'package:dear_deer_demo/controller/login/agreement_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/view/login/sign_up_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpAgreement extends GetView<AgreementController> {
  const SignUpAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Padding(
      padding: EdgeInsets.only(top: 41.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MARK: title
          Row(
            children: [
              SizedBox(
                width: 6.w,
              ),
              GestureDetector(
                onTap: Get.back,
                child:
                    Image.asset(ImagePath.backIcon, width: 48.w, height: 48.h),
              ),
              SizedBox(
                width: 95.w,
              ),
              Text('회원가입',
                  style: FontStyles.H2_bold_17.copyWith(color: Colors.black)),
            ],
          ),
          SizedBox(height: 19.h),
          // MARK: Main
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '서비스 이용을 위한 동의 안내',
                  style: FontStyles.H1_bold_22,
                ),
                Text(
                  '서비스 이용을 위해  반드시 필요한 사항입니다.',
                  style: FontStyles.S1_reg_13,
                ),
                SizedBox(
                  height: 92.h,
                ),
                // 전체 동의 컨테이너
                _overallAgreeBox(),
                SizedBox(height: 16.h),
                Text(
                  '[필수]',
                  style:
                      FontStyles.S1_reg_13.copyWith(color: AppColors.mainGreen),
                ),
                Obx(() => _agreeRow(
                      title: '디어디어 약관 및 동의사항',
                      value: controller.reqAgree.value,
                      onTap: () =>
                          controller.toggleReq(!controller.reqAgree.value),
                    )),
                SizedBox(height: 16.h),
                Text(
                  '[선택]',
                  style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06),
                ),
                Obx(() => _agreeRow(
                      title: '혜택 · 이벤트 정보 수신 동의',
                      value: controller.optAgree.value,
                      onTap: () =>
                          controller.toggleOpt(!controller.optAgree.value),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 198.h,
          ),
          // ==================== 다음 버튼 ====================
          Obx(() => Padding(
                padding: EdgeInsets.only(left: 24.w),
                child: _nextButton(
                  active: controller.canNext,
                  onTap: controller.canNext
                      ? () => Get.to(() => const SignUpEmail())
                      : null,
                ),
              )),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // 전체 동의 영역
  Widget _overallAgreeBox() {
    return Container(
      width: 312.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.G_01, // 연한 회색 배경 토큰 (없으면 Colors.grey[100] 등으로 대체)
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Obx(() => _agreeRow(
            title: '전체 동의',
            value: controller.allAgree.value,
            onTap: () => controller.toggleAll(!controller.allAgree.value),
          )),
    );
  }

  // 공통 동의 Row (큰 터치 영역)
  Widget _agreeRow({
    required String title,
    required bool value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 17.w,
              ),
              child: Text(title, style: FontStyles.S1_reg_13),
            ),
            Spacer(),
            _checkbox(value),
          ],
        ),
      ),
    );
  }

// 디자인 맞춘 커스텀 체크박스
  Widget _checkbox(bool value) {
    return Image.asset(
      value ? ImagePath.checkboxOn : ImagePath.checkboxOff,
      width: 24.w,
      height: 24.h,
    );
  }

  // 다음 버튼
  Widget _nextButton({required bool active, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 312.w,
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
  }
}
