import 'package:dear_deer_demo/controller/home/bg_music_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        // _musicList(),
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

  // MARK: - 음악 리스트
// Widget _musicList() {
//   return Column(
//     children: List.generate(
//       6,
//       (index) => _musicItem(
//         title: '음악 제목 자리입니다.',
//         artist: '가수 자리입니다.',
//         cover: ImagePath.defaultMusicCover, // 기본 이미지
//         onTap: () {
//           controller.playMusic(index); // 컨트롤러에서 처리
//         },
//       ),
//     ),
//   );
// }

// 개별 음악 아이템 위젯
  Widget _musicItem({
    required String title,
    required String artist,
    required String cover,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 앨범 커버
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: Image.asset(
              cover,
              width: 48.w,
              height: 48.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),

          // 제목 & 가수
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FontStyles.B3_bold_15,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  artist,
                  style: FontStyles.B5_reg_13.copyWith(color: AppColors.G_05),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 재생 버튼
          GestureDetector(
            onTap: onTap,
            child: Icon(
              Icons.play_arrow,
              color: Colors.black,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }
}
