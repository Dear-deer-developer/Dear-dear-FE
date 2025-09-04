import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FontStyles {
  // MARK: - Header
  static TextStyle H1_bold_22 = TextStyle(
    fontFamily: 'KakaoSmallSansBold',
    fontSize: 22.sp,
    fontWeight: FontWeight
        .bold, // Flutter에서는 폰트 파일과 무게를 따로 인식, fontWeight를 지정해주지 않으면 기본값(Regular)로 인식할 수 있음.
    height: 1.2.h, // 줄 간 간격을 폰트 크기의 120%로 설정하여 텍스트가 뭉치지 않고 가독성을 높임.
  );
  static TextStyle H1_bold_17 = TextStyle(
    fontFamily: 'KakaoSmallSansBold',
    fontSize: 17.sp,
    fontWeight: FontWeight.bold,
    height: 1.2.h,
  );
  static TextStyle H1_bold_16 = TextStyle(
    fontFamily: 'KakaoSmallSansBold',
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    height: 1.2.h,
  );

  // MARK: - Body
  static TextStyle B1_bold_20 = TextStyle(
    fontFamily: 'KakaoSmallSansBold',
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    height: 1.2.h,
  );
  static TextStyle B1_reg_16 = TextStyle(
    fontFamily: 'KakaoSmallSansRegular',
    fontSize: 16.sp,
    height: 1.2.h,
  );
  static TextStyle B1_bold_15 = TextStyle(
    fontFamily: 'KakaoSmallSansBold',
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
    height: 1.2.h,
  );
  static TextStyle B1_reg_15 = TextStyle(
    fontFamily: 'KakaoSmallSansRegular',
    fontSize: 15.sp,
    height: 1.2.h,
  );
  static TextStyle B1_bold_14 = TextStyle(
    fontFamily: 'KakaoSmallSansBold',
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
    height: 1.2.h,
  );
  static TextStyle B1_reg_14 = TextStyle(
    fontFamily: 'KakaoSmallSansRegular',
    fontSize: 14.sp,
    height: 1.2.h,
  );
  static TextStyle B1_reg_13 = TextStyle(
    fontFamily: 'KakaoSmallSansRegular',
    fontSize: 13.sp,
    height: 1.2.h,
  );

  // MARK: - Sub
  static TextStyle S1_reg_13 = TextStyle(
    fontFamily: 'KakaoSmallSansRegular',
    fontSize: 13.sp,
    height: 1.2.h,
  );
  static TextStyle S1_reg_12 = TextStyle(
    fontFamily: 'KakaoSmallSansRegular',
    fontSize: 12.sp,
    height: 1.2.h,
  );
  static TextStyle S1_reg_10 = TextStyle(
    fontFamily: 'KakaoSmallSansRegular',
    fontSize: 10.sp,
    height: 1.2.h,
  );

  // MARK: - letter
  static TextStyle L1_reg_20 = TextStyle(
    fontFamily: 'LeeSeoyun',
    fontSize: 20.sp,
    height: 1.2.h,
  );
  static TextStyle L1_reg_18 = TextStyle(
    fontFamily: 'LeeSeoyun',
    fontSize: 18.sp,
    height: 1.2.h,
  );
  static TextStyle L1_reg_16 = TextStyle(
    fontFamily: 'LeeSeoyun',
    fontSize: 16.sp,
    height: 1.2.h,
  );

  // MARK: - cal
  static TextStyle C1_bold_14 = TextStyle(
    fontFamily: 'TJJoyofSinging',
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
    height: 1.6.h,
  );

  static TextStyle C2_reg_24 = TextStyle(
    fontFamily: 'KCCGanpan',
    fontSize: 24.sp,
    height: 1.3.h,
  );

  // MARK : - Button
  static TextStyle Button_bold_17 = TextStyle(
    fontFamily: 'KakaoSmallSansBold',
    fontSize: 17.sp,
    fontWeight: FontWeight.bold,
    height: 1.2.h,
  );

  // MARK : - novi
  static TextStyle novi_bold_10 = TextStyle(
    fontFamily: 'KakaoSmallSansBold',
    fontSize: 10.sp,
    fontWeight: FontWeight.bold,
    height: 1.2.h,
  );
}
