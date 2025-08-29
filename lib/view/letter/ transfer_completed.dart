import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class transferCompleted extends StatelessWidget {
  const transferCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appbar(),
      body: Column(
        children: [_middle(), _button()],
      ),
    );
  }

  AppBar _appbar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            '전송 완료',
            style: FontStyles.H1_bold_17,
          ),
        ),
        centerTitle: false,
      );

  Widget _middle() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Image.asset(
              'assets/images/letter.png',
              width: 220.w,
              height: 220.h,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 4),
            child: Center(
              child: Text(
                '우편이 성공적으로 접수되었습니다!',
                style: FontStyles.B3_bold_15,
              ),
            ),
          ),
          Center(
            child: Text(
              '이 편지는 12 월 25 일 00 시부터 열람 가능합니다. ',
              style: FontStyles.B5_reg_13,
            ),
          ),
        ],
      );

  Widget _button() => Padding(
        padding: const EdgeInsets.only(top: 235),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(300.w, 40.h),
            backgroundColor: AppColors.mainGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: Text('우체국 로비로 이동하기',
              style:
                  FontStyles.Button_bold_17.copyWith(color: AppColors.White)),
        ),
      );
}
