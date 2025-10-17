import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/controller/profile/profile_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:dear_deer_demo/widget/camera_dialog.dart';
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
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _head(),
        _profileArea(context),
        SizedBox(height: 20.h),
        _divider(),
        _setting(),
      ],
    );
  }

  // MARK: 헤더
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
            style: FontStyles.H2_bold_17,
          ),
        ],
      ),
    );
  }

  // MARK: Profile
  Widget _profileArea(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0.h),
      child: Column(
        children: [
          // 프로필 사진
          Stack(
            children: [
              ClipOval(
                child: Image.asset(
                  ImagePath.sampleImage, // 샘플 이미지
                  width: 65.w,
                  height: 65.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -9.h,
                right: -4.w,
                child: GestureDetector(
                  onTap: () async {
                    final result = await CameraDialog.show(context);
                    if (result == ProfileImageAction.pickFromAlbum) {
                      // TODO: 갤러리 열기
                    } else if (result == ProfileImageAction.useDefault) {
                      // TODO: 기본 이미지 적용
                    }
                  },
                  child: Image.asset(
                    ImagePath.cameraIcon, // 카메라 아이콘
                    width: 32.w,
                    height: 32.h,
                  ),
                ),
              ),
            ],
          ),
          // usernickname
          Obx(() => Text(
                controller.getUserName(),
                style: FontStyles.B4_bold_14,
              )),
          SizedBox(height: 20.h),
          // zipCode Box
          Container(
            width: 312.w,
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.r),
              color: AppColors.G_01,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 17.w),
                  child: Text(
                    '내 사서함 번호: ${controller.getZipCodeText()}',
                    style: FontStyles.S1_reg_13,
                  ),
                ),
                // 공유 버튼
                Padding(
                  padding: EdgeInsets.only(right: 13.0.w),
                  child: _shareButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _setting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 24.w, top: 12.h),
          child: Text(
            '사용자 설정',
            style: FontStyles.H3_bold_16, // H3로 변경
          ),
        ),
        // 보안 설정
        SizedBox(
          height: 48.h,
          child: Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '보안 설정',
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

  // MARK: 공유 버튼
  Widget _shareButton() {
    return GestureDetector(
      onTap: () {
        // TODO: 공유 기능 추가 예정
      },
      child: Container(
        width: 38.w,
        height: 22.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.G_02,
            width: 1.w,
          ),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text('공유', style: FontStyles.S3_reg_10),
      ),
    );
  }

  // MARK: 디바이더
  Widget _divider() {
    return Container(
      width: double.infinity,
      height: 1.h,
      color: AppColors.G_01,
    );
  }
}
