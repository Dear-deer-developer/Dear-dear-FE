import 'package:dear_deer_demo/controller/post/post_controller.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/view/letter/letter_sent_list.dart';
import 'package:dear_deer_demo/view/letter/received_letter_list.dart';
import 'package:dear_deer_demo/view/letter/temporary_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';

/// 우체국 메인 화면(우편함)
/// 사용자는 이 화면에서 편지 보내기, 내 사서함 확인, 보낸 편지함, 임시 보관함 등
/// 다양한 우체국 서비스를 이용할 수 있습니다.
class PostMain extends GetView<PostController> {
  PostMain({super.key});

  final authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _appBar(),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _deerPostImage(),
              _mainButtonsRow(),
              _number(),
              _otherServicesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - AppBar
  AppBar _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "우체국",
          style: FontStyles.H2_bold_17,
        ),
      );

  // MARK: - 상단 이미지
  Widget _deerPostImage() => Padding(
        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
        child: Image.asset(
          ImagePath.deerPost,
          width: 360.w,
          height: 165.h,
          fit: BoxFit.cover,
        ),
      );

  // MARK: - 메인 버튼 영역
  Widget _mainButtonsRow() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _mainCardButton(
              image: ImagePath.letterImage,
              title: "편지 보내기",
              subtitle: "12월 25일에 일괄 배송",
              onTap: controller.goToSelectLetterPaper,
            ),
            _mainCardButton(
              image: ImagePath.letterBoxImage,
              title: "내 사서함 확인",
              subtitle: "내용은 12월 25일부터 확인 가능",
              onTap: () => Get.to(() => ReceivedLetterList()),
            ),
          ],
        ),
      );

  Widget _mainCardButton({
    required String image,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: 148.w,
        height: 176.h,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: AppColors.G_02),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(image, width: 80.w, height: 80.h),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    style: FontStyles.B4_bold_14.copyWith(color: Colors.black),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: FontStyles.S3_reg_10.copyWith(color: AppColors.G_05),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // MARK: - 사서함 번호
  Widget _number() {
    // ✅ 로그인한 유저 정보에서 zipCode 가져오기
    final zipCode = authService.user.value?.zipCode ?? '00000';

    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Container(
        width: 312.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.G_01,
          borderRadius: BorderRadius.circular(7.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "내 사서함 번호: $zipCode",
              style: FontStyles.S1_reg_13.copyWith(color: Colors.black),
            ),
            SizedBox(
              width: 38.w,
              height: 22.h,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 공유 기능 추가
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "공유",
                  style: FontStyles.S3_reg_10.copyWith(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - 그 외 업무 영역
  Widget _otherServicesSection() => Padding(
        padding: EdgeInsets.only(left: 24.w, top: 32.h, right: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "그 외 업무",
              style: FontStyles.H3_bold_16.copyWith(color: Colors.black),
            ),
            SizedBox(height: 16.h),
            _serviceTextButton(
              "보낸 편지함",
              () => Get.to(() => LetterSentList()),
            ),
            SizedBox(height: 12.h),
            _serviceTextButton(
              "임시 보관함",
              () => Get.to(() => TemporaryStorage()),
            ),
          ],
        ),
      );

  Widget _serviceTextButton(String label, VoidCallback onTap) => TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: FontStyles.B3_reg_15.copyWith(color: Colors.black),
            textAlign: TextAlign.left,
          ),
        ),
      );
}
