import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/widget/custom_button.dart';
import 'package:dear_deer_demo/controller/post/post_controller.dart';
// import 'package:dear_deer_demo/view/%08letter/select_recipient.dart';

class WriteLetterScreen extends StatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _receiverController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 전체 너비 (screenutil을 쓴다면 360.w, 아니면 MediaQuery로도 가능)
    final double screenWidth = 360.w;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "편지 쓰기",
            style: FontStyles.H1_bold_17,
            textAlign: TextAlign.left,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            // "받는 사람" 레이블 + 입력창 (좌우 여백)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "받는 사람",
                    style: FontStyles.B1_bold_14.copyWith(
                      color: AppColors.Black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () {
                      // Get.to(() => SelectRecipient());
                    },
                    child: Container(
                      width: 312.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.white, // 하얀색 배경
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.G_02, // 테두리 색
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _receiverController,
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // "내용" 레이블 (좌우 여백)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                "내용",
                style: FontStyles.B1_bold_14.copyWith(color: AppColors.Black),
              ),
            ),
            SizedBox(height: 4.h),
            // 내용 입력창 (좌우 여백 없이, 위아래 테두리만)
            Container(
              width: screenWidth,
              // height: 338.h,
              height: 300.h,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.G_02, width: 1),
                  bottom: BorderSide(color: AppColors.G_02, width: 1),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 49.h),
                  child: Container(
                    width: 312.w,
                    height: 274.h,
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        hintText: "내용을 입력해주세요.",
                        hintStyle: FontStyles.L1_reg_16.copyWith(
                          color: AppColors.G_06,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "보내는 사람",
                    style: FontStyles.B1_bold_14.copyWith(
                      color: AppColors.Black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 312.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white, // 하얀색 배경
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.G_02, // 테두리 색
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _senderController, // 컨트롤러 연결
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // 저장 버튼 (좌우 여백)
            SelectLetterButton(
              isEnabled: _receiverController.text.isNotEmpty &&
                  _textController.text.isNotEmpty &&
                  _senderController.text.isNotEmpty,
              onPressed: () {
                // 편지 확인 후 전송 로직
                Get.snackbar('알림', '편지가 전송되었습니다!');
              },
              buttonText: "편지 확인 후 전송하기",
            ),
          ],
        ),
      ),
    );
  }
}
