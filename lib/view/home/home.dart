import 'package:dear_deer_demo/controller/home/home_controller.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/view/home/alarm_onboarding.dart';
import 'package:dear_deer_demo/view/home/bg_music.dart';
import 'package:dear_deer_demo/view/home/gift_main.dart';
import 'package:dear_deer_demo/view/home/not_yet.dart';
import 'package:dear_deer_demo/view/profile/profile_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Stack(
      children: [
        // === 배경 ===
        Positioned.fill(
          child: Obx(() {
            final bgPath = controller.dayNight.isNight.value
                ? ImagePath.homeBgImagePm
                : ImagePath.homeBgImageAm;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                bgPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
              ),
            );
          }),
        ),

        // MARK: - 위젯
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _topWidget(), // 상단바
              _mainWidget(), // 메인 트리
            ],
          ),
        ),
        _bottomIcon(context), // 하단 아이콘
      ],
    );
  }

  // MARK: - 상단 위젯
  Widget _topWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 7.w, top: 8.h, bottom: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            ImagePath.homeTopWidget,
            width: 88.w,
            height: 46.h,
          ),
          SizedBox(
            height: 5.h,
          ),
          GestureDetector(
              onTap: () {
                Get.to(() => const ProfileMain());
              },
              child: _profileIcon()),
        ],
      ),
    );
  }

  // MARK: - 프로필 (임시)
  Widget _profileIcon() {
    return ClipOval(
      child: Image.asset(
        ImagePath.sampleImage, // 샘플 이미지
        width: 36.w,
        height: 36.h,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _mainWidget() {
    return Stack(
      children: [
        Image.asset(
          ImagePath.normalTree,
          width: 369.w,
          height: 548.h,
        )
      ],
    );
  }

  // MARK: - 하단 아이콘
  Widget _bottomIcon(BuildContext context) {
    return Stack(
      children: [
        // 알람 아이콘
        Positioned(
          bottom: 87.h,
          left: 28.w,
          right: 293.w,
          child: GestureDetector(
            onTap: () {
              Get.to(() => const AlarmOnboarding());
            },
            child: Image.asset(
              ImagePath.alarmIcon,
              width: 48.w,
              height: 48.h,
            ),
          ),
        ),
        // MARK: - 선물함 - 임시 처리
        Positioned(
          bottom: 136.h,
          left: 292.w,
          right: 28.h,
          child: GestureDetector(
            onTap: () {
              Get.to(() => const GiftMain());
              // Get.to(() => NotYet());
            },
            child: Image.asset(
              ImagePath.giftBoxIcon,
              width: 48.w,
              height: 48.h,
            ),
          ),
        ),
        // 배경음악
        Positioned(
          bottom: 87.h,
          left: 292.w,
          right: 28.h,
          child: GestureDetector(
            onTap: () {
              Get.to(() => const BgMusic());
            },
            child: Image.asset(
              ImagePath.bgMusicIcon,
              width: 48.w,
              height: 48.h,
            ),
          ),
        ),
      ],
    );
  }
}
