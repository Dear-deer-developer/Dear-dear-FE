import 'package:dear_deer_demo/view/letter/letter_recived.dart';
import 'package:dear_deer_demo/view/letter/letter_sent.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ReceivedLetterList extends StatelessWidget {
  const ReceivedLetterList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: Column(
        children: [
          _message(),
          _letterList(),
        ],
      ),
    );
  }

  AppBar _appbar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "내 사서함",
          style: FontStyles.H2_bold_17,
        ),
      );

  Widget _message() => Align(
        alignment: const Alignment(0, -0.9),
        child: Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: Container(
            width: 300.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: AppColors.mainRed.withOpacity(0.3),
              borderRadius: BorderRadius.circular(7.r),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                  child: Image.asset(
                    ImagePath.letterImage,
                    width: 34.w,
                    height: 34.h,
                  ),
                ),
                Text(
                  "편지는 크리스마스 당일날 개봉 가능해요.",
                  style: FontStyles.B4_reg_14.copyWith(
                    color: AppColors.Black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

// MARK: - 편지 리스트
  /// 보낸 편지들을 이미지 위에 'Dear. 이름' 텍스트와 함께 표시하고,
  /// 편지를 누르면 LetterSent() 페이지로 이동합니다.
  Widget _letterList() {
    // 📨 임시 데이터 (나중에 API로 대체 가능)
    final List<Map<String, String>> letters = [
      {
        "recipient": "미가입자",
        "content": "안녕? 첫 번째 편지야!",
      },
      {
        "recipient": "닉네임 이용자",
        "content": "이번에도 편지를 보냈어.",
      },
    ];

    return Padding(
      padding: EdgeInsets.only(top: 30.h),
      child: Center(
        child: Column(
          children: List.generate(letters.length, (index) {
            final letter = letters[index];
            final recipientName = letter['recipient'] ?? '받는 사람 없음';
            final content = letter['content'] ?? '';

            return Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: GestureDetector(
                onTap: () {
                  // 편지 클릭 시 LetterSent() 페이지로 이동
                  Get.to(() => LetterRecived(), arguments: {
                    "recipientName": recipientName,
                    "content": content,
                  });
                },
                child: Stack(
                  children: [
                    // 편지 배경 이미지
                    Container(
                      width: 312.w,
                      height: 184.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        ImagePath.imageLetterEnvelope,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Dear. 이름 텍스트 (편지 이미지 위)
                    Positioned(
                        left: 20.w,
                        bottom: 16.h,
                        child: Text(
                          "Dear. $recipientName",
                          style: FontStyles.L3_reg_16.merge(
                            const TextStyle(fontFamily: 'LeeSeoyun'),
                          ),
                        )),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
