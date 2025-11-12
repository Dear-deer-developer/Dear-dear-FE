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

class LetterReceived extends StatelessWidget {
  const LetterReceived({super.key});

  // MARK: 날짜 포맷 변환
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

    final arguments = Get.arguments ?? {};
    final content = arguments['content'] ?? '';
    final sentAt = arguments['sentAt'] ?? '';
    final sender = arguments['sender'] ?? {};
    final senderName = sender['nickname'] ?? '보낸 사람 없음';
    final paperId = arguments['paperId'] ?? 1;
    final presignedUrl = arguments['presignedUrl']; // 서버에서 받은 presignedUrl

    final paperAsset = _getPaperAsset(paperId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setLetterContent(content);
    });

    final formattedDate = formatDate(sentAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _AppBar(),
      body: _Body(controller, senderName, formattedDate, paperAsset, nickname,
          presignedUrl),
    );
  }

  // MARK: AppBar
  AppBar _AppBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            '받은 편지함',
            style: FontStyles.H2_bold_17,
          ),
        ),
      );

  // MARK: Body
  Widget _Body(LetterPreviewController controller, String senderName,
      String sentAt, String paperAsset, String nickname, String? presignedUrl) {
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
              _LetterView(controller, senderName, sentAt, paperAsset, nickname,
                  presignedUrl),
              const SizedBox(height: 30),
              _PageIndicator(controller),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: Letter View
  Widget _LetterView(LetterPreviewController controller, String senderName,
      String sentAt, String paperAsset, String nickname, String? presignedUrl) {
    return SizedBox(
      height: 460.h,
      child: Obx(() => PageView.builder(
            controller: controller.pageController,
            itemCount: controller.pagedTexts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
                child: _LetterCard(index, controller, senderName, sentAt,
                    paperAsset, nickname, presignedUrl),
              );
            },
          )),
    );
  }

  // MARK: Letter Card
  Widget _LetterCard(
    int index,
    LetterPreviewController controller,
    String senderName,
    String sentAt,
    String paperAsset,
    String nickname,
    String? presignedUrl,
  ) {
    return AspectRatio(
      aspectRatio: 3 / 4.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              paperAsset,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dear 문구
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        "Dear. $nickname",
                        style: FontStyles.L1_reg_20,
                      ),
                    ),
                  ),

                  // 이미지 표시 (첫 페이지에만)
                  if (index == 0 &&
                      presignedUrl != null &&
                      presignedUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        presignedUrl,
                        fit: BoxFit.cover,
                        width: 280.w,
                        height: 180.h,
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ],

                  // 본문
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        controller.pagedTexts.isNotEmpty
                            ? controller.pagedTexts[index]
                            : '',
                        style: FontStyles.L3_reg_16.merge(
                          const TextStyle(
                            fontFamily: 'LeeSeoyun',
                            height: 1.5,
                          ),
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
                        "$sentAt\nFrom. $senderName",
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
          ],
        ),
      ),
    );
  }

  // MARK: Page Indicator
  Widget _PageIndicator(LetterPreviewController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Obx(() {
          final pageCount = controller.pagedTexts.length;
          if (pageCount == 0) return const SizedBox();
          return SmoothPageIndicator(
            controller: controller.pageController,
            count: pageCount,
            effect: const SlideEffect(
              dotWidth: 6,
              dotHeight: 6,
              activeDotColor: AppColors.mainRed,
              dotColor: AppColors.G_03,
            ),
          );
        }),
      );

  // MARK: 편지지 매핑
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
