import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AlarmOnboarding extends StatelessWidget {
  const AlarmOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final nickname = Get.find<AuthService>().user.value?.nickname ?? '유저네임';
    return Scaffold(
      body: _body(nickname),
    );
  }

  Widget _body(String nickname) {
    return Column(
      children: [
        _head(),
        SizedBox(
          height: 19.h,
        ),
        _ment(nickname),
        SizedBox(
          height: 421.h,
        ),
        _setting(),
      ],
    );
  }

  Widget _head() {
    return Padding(
      padding: EdgeInsets.only(top: 41.h, left: 4.w),
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
          SizedBox(width: 69.w),
          Text(
            '크리스마스 알람',
            textAlign: TextAlign.center,
            style: FontStyles.H2_bold_17,
          ),
          SizedBox(
            height: 19.h,
          ),
        ],
      ),
    );
  }

  Widget _ment(String nickname) {
    return Column(
      children: [
        Text(
          'Dear. $nickname',
          style: TextStyle(
            fontFamily: 'LeeSeoyun',
            fontSize: 20.sp,
            // fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          '크리스마스를 기다리는 마음,\n올해도 여전히 설레죠?\n그 특별한 시작을 우리가 알람으로 살짝 알려드릴게요.\n가장 반짝이는 순간, 함께 준비해요. 🎁',
          style: FontStyles.L3_reg_16,
          textAlign: TextAlign.left,
        )
      ],
    );
  }

  Widget _setting() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 312.w,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.mainGreen,
        ),
        child: Center(
          child: Text(
            '설정하기',
            style: FontStyles.Button_bold_17.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
