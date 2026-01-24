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
      padding: EdgeInsets.only(top: 17.h, left: 4.w),
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
            style: FontStyles.H2_bold_17,
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
    return Obx(() {
      final i =
          controller.selectedIndex.value.clamp(0, controller.tracks.length - 1);
      final track = controller.tracks[i];
      final isPlaying = controller.isPlaying.value;

      return Container(
        width: 360.w,
        height: 72.h,
        decoration: const BoxDecoration(
          color: AppColors.mainRed,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 앨범 커버
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                track.coverAssetPath,
                width: 50.w,
                height: 50.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 11.w,
            ),
            // 제목 / 아티스트
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontStyles.B4_bold_14.copyWith(color: Colors.white),
                  ),
                  // artist
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontStyles.S2_reg_12.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // 일시정지/재생
            GestureDetector(
              onTap: () => controller.togglePlay(i),
              child: Image.asset(
                isPlaying
                    ? ImagePath.musicStopIconWhite
                    : ImagePath.musicPlayIconWhite,
                width: 40.w,
                height: 40.h,
              ),
            ),
            SizedBox(width: 8.w),

            // 다음 곡
            GestureDetector(
              onTap: controller.playNext,
              child: Image.asset(
                ImagePath.musicNextIconWhite,
                width: 40.w,
                height: 40.h,
              ),
            ),
          ],
        ),
      );
    });
  }
}
