import 'package:dear_deer_demo/controller/post/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';

class PostMain extends StatelessWidget {
  PostMain({super.key});

  final controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(), // 우편함 앱바
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          Image.asset(ImagePath.deerPost, width: 360.w, height: 190.h, fit: BoxFit.contain,),
          SizedBox(height: 24.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sendbutton(), // 편지 보내기 버튼
                _mailboxbutton(), // 내 사서함 버튼
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 30.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "그 외 업무",
                    style: FontStyles.H1_bold_16.copyWith(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _sentletterbutton(), // 보낸 편지함 버튼
                  const SizedBox(height: 24),
                  _draftbutton(), // 임시 보관함 버튼
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // MARK: - 우체국 앱 바
  ///
  AppBar _appBar() => AppBar(
    title: Text(
      "우체국",
      style: FontStyles.H1_bold_17,
    ),
    backgroundColor: AppColors.bgColor,
  );
  
  // MARK: - 편지 보내기 버튼
  ///
  Widget _sendbutton() => SizedBox(
    width: 160,
    height: 176,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(width: 1, color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: controller.goToSelectLetterPaper,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/letter.png', width: 80.w, height: 80.h),
          // const SizedBox(height: 5),
          Text(
            "편지 보내기",
            style: FontStyles.B1_bold_14.copyWith(color: Colors.black),
          ),
          Text(
            "12월 25일에 일괄 배송",
            style: FontStyles.S1_reg_10.copyWith(color: AppColors.G_05),
          ),
        ],
      ),
    ),
  );
  
  // MARK: - 내 사서함 확인 버튼
  ///
  Widget _mailboxbutton() => SizedBox(
    width: 160,
    height: 176,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(width: 1, color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: controller.openMyMailbox,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ImagePath.letterBoxImage, width: 80.w, height: 80.h),
          Text(
            "내 사서함 확인",
            style: FontStyles.B1_bold_14.copyWith(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          Text(
            "내용은 12월 25일부터 확인 가능",
            style: FontStyles.S1_reg_10.copyWith(color: AppColors.G_05),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  // MARK: - 보낸 편지함 버튼
  ///
  Widget _sentletterbutton() => TextButton(
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    onPressed: controller.openSentLetters,
    child: Text(
      "보낸 편지함",
      style: FontStyles.B1_reg_15.copyWith(color: Colors.black),
      textAlign: TextAlign.left,
    ),
  );
  
  // MARK: - 임시 보관함 버튼
  ///
  Widget _draftbutton() => TextButton(
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    onPressed: controller.openDrafts,
    child: Text(
      "임시 보관함",
      style: FontStyles.B1_reg_15.copyWith(color: Colors.black),
      textAlign: TextAlign.left,
    ),
  );

}