import 'package:dear_deer_demo/controller/home/bg_music_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/widget/bg_music_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BgMusic extends GetView<BgMusicController> {
  const BgMusic({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _head(),
        SizedBox(height: 19.h),
        Expanded(child: _musicList()),
        _playWidget(),
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
            '배경음악',
            textAlign: TextAlign.center,
            style: FontStyles.H2_bold_17, // H2로 변경해야함.
          ),
        ],
      ),
    );
  }

  // MARK: - 음악 리스트 (내부 위젯)
  Widget _musicList() {
    return Obx(() {
      final items = controller.tracks; // 컨트롤러가 보유한 데이터
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListView.builder(
            itemCount: controller.tracks.length,
            itemBuilder: (context, i) {
              return BgMusicWidget(
                index: i,
                track: controller.tracks[i],
              );
            }),
      );
    });
  }

  Widget _playWidget() {
    return Container(
      width: 360.w,
      height: 72.h,
      decoration: const BoxDecoration(
        color: AppColors.mainRed,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }
}
