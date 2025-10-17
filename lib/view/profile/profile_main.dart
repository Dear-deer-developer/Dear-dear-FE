import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/controller/profile/profile_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/widget/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileMain extends GetView<ProfileController> {
  const ProfileMain({super.key});

  @override
  StatelessElement createElement() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _head(),
        _postBox(),
        _setting(),
      ],
    );
  }

  Widget _head() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, left: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(ImagePath.backIcon, width: 48.w, height: 48.h),
          SizedBox(width: 110.w),
          Text(
            '설정',
            textAlign: TextAlign.center,
            style: FontStyles.H2_bold_17, // H2로 변경해야함.
          ),
        ],
      ),
    );
  }

  // MARK: - 우편함
  // Widget _postBox() {
  //   return Padding(
  //     padding: EdgeInsets.only(left: 24.w, top: 30.h, bottom: 16.h),
  //     child: Container(
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(8.r),
  //           color: const Color(0xffFEF5E3)),
  //       width: 312.w,
  //       height: 119.h,
  //     ),
  //   );
  // }
  Widget _postBox() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 30.h, bottom: 16.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: const Color(0xffFEF5E3),
        ),
        width: 312.w,
        height: 119.h,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 16.w),
                // 프로필 사진
                Stack(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        ImagePath.sampleImage, // 샘플 이미지
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        ImagePath.cameraIcon, // 카메라 아이콘
                        width: 32.w,
                        height: 32.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 9.w),
                // 텍스트 영역
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: 유저 닉네임 불러오기
                    Obx(() => Text(
                          controller.getUserName(),
                          style: FontStyles.B3_bold_15,
                        )),
                    SizedBox(height: 4.h),
                    // TODO: 유저 우편 번호 불러오기
                    Text('2001-0516', style: FontStyles.B3_reg_15 // B5로 변경
                        ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _setting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 24.w),
          child: Text(
            '사용자 설정',
            style: FontStyles.H3_bold_16, // H3로 변경
          ),
        ),
        // 계정 설정
        SizedBox(
          height: 48.h,
          child: Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '계정 설정',
                style: FontStyles.B3_reg_15,
              ),
            ),
          ),
        ),
        // 문의하기
        SizedBox(
          height: 48.h,
          child: Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '문의하기',
                style: FontStyles.B3_reg_15,
              ),
            ),
          ),
        ),
        // 버전
        SizedBox(
          height: 48.h,
          child: Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '버전',
                style: FontStyles.B3_reg_15,
              ),
            ),
          ),
        ),
        // MARK: 로그아웃
        SizedBox(
          height: 48.h,
          child: Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                final ok = await LogoutDialog.show();
                if (!ok) {
                  logger.i('[UI] 로그아웃 다이얼로그: 취소/닫힘');
                  return;
                }

                // AuthController 가져오기 (미등록 시 안전하게 put)
                final authCtrl = Get.isRegistered<AuthController>()
                    ? Get.find<AuthController>()
                    : Get.put(AuthController());

                logger.i('[UI] 로그아웃 확인 클릭 → AuthController.logout() 호출');
                try {
                  await authCtrl.logout(); // ← AuthController에 구현된 로그아웃 사용
                  logger.i('[UI] AuthController.logout() 완료');
                } catch (e, st) {
                  logger.e('[UI] AuthController.logout() 예외',
                      error: e, stackTrace: st);
                  Get.snackbar('로그아웃 실패', '잠시 후 다시 시도해주세요.');
                }
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '로그아웃',
                  style: FontStyles.B3_reg_15.copyWith(
                      color: const Color(0xFFFF5656)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
