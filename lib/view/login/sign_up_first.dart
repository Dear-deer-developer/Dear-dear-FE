import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpFirst extends StatelessWidget {
  const SignUpFirst({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 108.h, left: 24.w),
          child: Text(
            '000 가입을 환영합니다:)\n사용하실 닉네임을 알려주세요!',
            style: FontStyles.H1_bold_22,
            //  기존 방법
            // style: TextStyle(
            //     fontFamily: 'KakaoSmallSansBold',
            //     fontSize: 22.sp,
            //     fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
