import 'package:dear_deer_demo/controller/post/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';

/// 우체국 메인 화면(우편함)입니다.
/// 사용자는 이 화면에서 편지 보내기, 내 사서함 확인, 보낸 편지함, 임시 보관함 등
/// 다양한 우체국 서비스를 이용할 수 있습니다.
class PostMain extends GetView<PostController> {
  const PostMain({super.key});

  // MARK: - Controller
  /// 우체국 관련 비즈니스 로직을 담당하는 컨트롤러입니다.
  // @override
  // final controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor, // NOTE: 전체 배경은 흰색으로 설정
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _deerPostImage(),
            _mainButtonsRow(),
            _otherServicesSection(),
          ],
        ),
      ),
    );
  }

  // MARK: - AppBar

  /// 우체국 메인 화면의 상단 앱바입니다.
  /// "우체국" 타이틀을 가운데 정렬로 표시합니다.
  AppBar _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // FIXME: 그림자 제거
        centerTitle: true,
        title: Text(
          "우체국",
          style: FontStyles.H1_bold_17,
        ),
      );

  // MARK: - 상단 이미지

  /// 화면 상단에 위치하는 디어디어 캐릭터 이미지입니다.
  /// 우체국 메인 화면을 시각적으로 강조합니다.
  Widget _deerPostImage() => Padding(
        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
        child: Image.asset(
          ImagePath.deerPost,
          width: 360.w,
          height: 190.h,
          fit: BoxFit.cover,
        ),
      );

  // MARK: - 메인 버튼 영역

  /// 편지 보내기와 내 사서함 버튼을 가로로 배치하는 영역입니다.
  /// 각 버튼은 카드 형태로, 이미지와 텍스트로 구성되어 있습니다.
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
              onTap: controller.openMyMailbox,
            ),
          ],
        ),
      );

  /// 카드 형태의 메인 버튼 위젯입니다.
  /// 이미지, 제목, 부제목, 클릭 이벤트를 받습니다.
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
                    style: FontStyles.S1_reg_10.copyWith(color: AppColors.G_05),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // MARK: - 그 외 업무 영역

  /// 보낸 편지함, 임시 보관함 등 그 외 업무 버튼을 배치하는 영역입니다.
  /// 왼쪽 정렬로, 각 버튼은 텍스트 형태로 제공됩니다.
  Widget _otherServicesSection() => Padding(
        padding: EdgeInsets.only(left: 24.w, top: 32.h, right: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "그 외 업무",
              style: FontStyles.H1_bold_16.copyWith(color: Colors.black),
            ),
            SizedBox(height: 16.h),
            _serviceTextButton("보낸 편지함", controller.openSentLetters),
            SizedBox(height: 12.h),
            _serviceTextButton("임시 보관함", controller.openDrafts),
          ],
        ),
      );

  /// 그 외 업무용 텍스트 버튼입니다.
  /// 텍스트와 클릭 이벤트를 받으며, 좌측 정렬됩니다.
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
