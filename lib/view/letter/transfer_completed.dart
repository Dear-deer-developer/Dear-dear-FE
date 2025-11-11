import 'package:dear_deer_demo/app.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransferCompleted extends StatelessWidget {
  const TransferCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appbar(),
      body: Column(
        children: [
          _middle(),
          _button(),
        ],
      ),
    );
  }

  AppBar _appbar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text('전송 완료', style: FontStyles.H2_bold_17),
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
              child: Text('우편이 성공적으로 접수되었습니다!', style: FontStyles.B3_bold_15),
            ),
          ),
          Center(
            child: Text('이 편지는 12월 25일 00시부터 열람 가능합니다.',
                style: FontStyles.B5_reg_13),
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
          onPressed: () async {
            await Get.deleteAll(force: true);
            Phoenix.rebirth(Get.context!);
            Get.offAll(() => const App());
          },
          child: Text(
            '닫기',
            style: FontStyles.Button_bold_17.copyWith(color: AppColors.White),
          ),
        ),
      );
}
