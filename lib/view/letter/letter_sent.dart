import 'package:dear_deer_demo/controller/post/letter_preview_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LetterSent extends StatelessWidget {
  const LetterSent({super.key});

  String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final utcTime = DateTime.parse(isoString).toUtc();
      final kstTime = utcTime.add(const Duration(hours: 9)); // 한국 시간 변환
      return DateFormat('yyyy년 MM월 dd일').format(kstTime);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LetterPreviewController());
    final authService = Get.find<AuthService>();
    final nickname = authService.user.value?.nickname ?? '나';

    // 서버에서 받은 데이터
    final arguments = Get.arguments ?? {};
    final content = arguments['content'] ?? '';
    final sentAt = arguments['sentAt'] ?? '';
    final receiver = arguments['receiver'] ?? {};
    final recipientName = receiver['nickname'] ?? '받는 사람 없음';
    final paperId = arguments['paperId'] ?? 1;

    // 편지지 이미지 경로 매핑
    final paperAsset = _getPaperAsset(paperId);

    // 시간 변환 적용
    final formattedDate = formatDate(sentAt);

    // 본문 텍스트 반영
    controller.setLetterContent(content);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _AppBar(),
      body:
          _Body(controller, recipientName, formattedDate, paperAsset, nickname),
    );
  }

  // MARK: - AppBar
  AppBar _AppBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            '보낸 편지함',
            style: FontStyles.H2_bold_17,
          ),
        ),
      );

  // MARK: - Body
  Widget _Body(LetterPreviewController controller, String recipientName,
      String sentAt, String paperAsset, String nickname) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            ImagePath.imageOpenLetter,
            width: double.infinity,
            height: 300.h,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          bottom: 140.h,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LetterView(
                  controller, recipientName, sentAt, paperAsset, nickname),
              const SizedBox(height: 30),
              _PageIndicator(controller),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Letter View
  Widget _LetterView(LetterPreviewController controller, String recipientName,
      String sentAt, String paperAsset, String nickname) {
    return SizedBox(
      height: 460.h,
      child: Obx(() => PageView.builder(
            controller: controller.pageController,
            itemCount: controller.pagedTexts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
                child: _LetterCard(index, controller, recipientName, sentAt,
                    paperAsset, nickname),
              );
            },
          )),
    );
  }

  // MARK: - Letter Card
  Widget _LetterCard(
    int index,
    LetterPreviewController controller,
    String senderName,
    String sentAt,
    String paperAsset,
    String nickname,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 312.w,
        height: 460.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(paperAsset),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dear 문구
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  "Dear. $senderName",
                  style: FontStyles.L1_reg_20,
                ),
              ),
            ),

            // 본문
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  controller.pagedTexts[index],
                  style: FontStyles.L3_reg_16.merge(
                    const TextStyle(fontFamily: 'LeeSeoyun', height: 1.5),
                  ),
                ),
              ),
            ),

            // 날짜 & From
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text(
                  "$sentAt\nFrom.$nickname",
                  textAlign: TextAlign.right,
                  style: FontStyles.L3_reg_16.merge(
                    const TextStyle(fontFamily: 'LeeSeoyun'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Page Indicator
  Widget _PageIndicator(LetterPreviewController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SmoothPageIndicator(
          controller: controller.pageController,
          count: controller.pagedTexts.length,
          effect: const SlideEffect(
            dotWidth: 6,
            dotHeight: 6,
            activeDotColor: AppColors.mainRed,
            dotColor: AppColors.G_03,
          ),
        ),
      );

  // MARK: - 편지지 이미지 매핑 함수
  String _getPaperAsset(int paperId) {
    switch (paperId) {
      case 1:
        return ImagePath.imageLetter1;
      case 2:
        return ImagePath.imageLetter2;
      case 3:
        return ImagePath.imageLetter3;
      case 4:
        return ImagePath.imageLetter4;
      case 5:
        return ImagePath.imageLetter5;
      case 6:
        return ImagePath.imageLetter6;
      case 7:
        return ImagePath.imageLetter7;
      case 8:
        return ImagePath.imageLetter8;
      case 9:
        return ImagePath.imageLetter9;
      case 10:
        return ImagePath.imageLetter10;
      case 11:
        return ImagePath.imageLetter11;
      default:
        return ImagePath.imageLetter1;
    }
  }
}
