import 'package:dear_deer_demo/controller/home/bg_music_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/model/music.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BgMusicWidget extends GetView<BgMusicController> {
  final int index;
  final MusicTrack track;

  const BgMusicWidget({
    super.key,
    required this.index,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.isSelected(index);
      final playing = controller.isPlaying.value && selected;

      return GestureDetector(
        onTap: () => controller.togglePlay(index),
        child: Container(
          height: 72.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.bgColor,
          ),
          child: Row(
            children: [
              // 앨범 커버
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  track.coverAssetPath,
                  width: 56.w,
                  height: 56.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              // Text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    SizedBox(
                      width: 221.w,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          track.title,
                          maxLines: 1,
                          style: (controller.isSelected(index)
                              ? FontStyles.B3_bold_15
                              : FontStyles.B3_reg_15),
                        ),
                      ),
                    ),
                    // Artist
                    Text(
                      track.artist,
                      style:
                          FontStyles.S1_reg_12.copyWith(color: AppColors.G_06),
                    )
                  ],
                ),
              ),

              // Play / Stop Icon
              Image.asset(
                playing ? ImagePath.musicStopIcon : ImagePath.musicPlayIcon,
                width: 40.w,
                height: 40.h,
              ),
            ],
          ),
        ),
      );
    });
  }
}
