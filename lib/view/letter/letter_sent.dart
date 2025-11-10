import 'package:dear_deer_demo/controller/post/letter_preview_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/service/post/s3_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// 보낸 편지 상세 화면
/// 서버에서 전달받은 편지 데이터(content, paperId, sentAt, receiver 등)를 기반으로
/// 편지지 형태로 렌더링하며, S3 이미지가 포함된 경우 presigned URL을 통해 표시합니다.
class LetterSent extends StatelessWidget {
  const LetterSent({super.key});

  // MARK: - 날짜 포맷 변환 함수
  /// ISO 문자열을 "yyyy년 MM월 dd일" 형식으로 변환 (UTC → KST)
  String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final utcTime = DateTime.parse(isoString).toUtc();
      final kstTime = utcTime.add(const Duration(hours: 9));
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

    // MARK: - 서버에서 받은 편지 데이터
    final arguments = Get.arguments ?? {};
    final content = arguments['content'] ?? '';
    final sentAt = arguments['sentAt'] ?? '';
    final receiver = arguments['receiver'] ?? {};
    final recipientName = receiver['nickname'] ?? '받는 사람 없음';
    final paperId = arguments['paperId'] ?? 1;
    final imageKey =
        arguments['imageKey']; // ✅ 서버에서 전달된 S3 key (예: "letters/24/uuid.jpg")

    // 날짜 포맷팅
    final formattedDate = formatDate(sentAt);

    // 본문 내용 분할 (페이지 처리용)
    controller.setLetterContent(content);

    // S3 presigned URL 요청 서비스
    final s3Service = S3Service();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _AppBar(),
      body: FutureBuilder<String?>(
        future:
            imageKey != null ? s3Service.getImagePresignedUrl(imageKey) : null,
        builder: (context, snapshot) {
          final imageUrl = snapshot.data; // presigned URL
          final paperAsset = _getPaperAsset(paperId);
          return _Body(controller, recipientName, formattedDate, paperAsset,
              nickname, imageUrl);
        },
      ),
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
  /// 배경 이미지를 포함한 편지 본문 전체 UI
  Widget _Body(LetterPreviewController controller, String recipientName,
      String sentAt, String paperAsset, String nickname, String? imageUrl) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 아래쪽 봉투 이미지
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            ImagePath.imageOpenLetter,
            width: double.infinity,
            height: 300.h,
            fit: BoxFit.contain,
          ),
        ),

        // 편지 본문 (편지지 + 내용)
        Positioned(
          bottom: 140.h,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LetterView(controller, recipientName, sentAt, paperAsset,
                  nickname, imageUrl),
              const SizedBox(height: 30),
              _PageIndicator(controller),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Letter View
  /// 페이지 단위로 편지 내용을 표시 (본문 길이에 따라 자동 페이지 분리)
  Widget _LetterView(LetterPreviewController controller, String recipientName,
      String sentAt, String paperAsset, String nickname, String? imageUrl) {
    return SizedBox(
      height: 460.h,
      child: Obx(() => PageView.builder(
            controller: controller.pageController,
            itemCount: controller.pagedTexts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
                child: _LetterCard(index, controller, recipientName, sentAt,
                    paperAsset, nickname, imageUrl),
              );
            },
          )),
    );
  }

  // MARK: - Letter Card
  /// 편지 한 장의 UI (편지지 배경 + Dear 문구 + 이미지 + 본문 + 날짜/보낸이)
  Widget _LetterCard(
    int index,
    LetterPreviewController controller,
    String recipientName,
    String sentAt,
    String paperAsset,
    String nickname,
    String? imageUrl,
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
            // MARK: Dear 문구
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  "Dear. $recipientName",
                  style: FontStyles.L1_reg_20.copyWith(fontFamily: 'LeeSeoyun'),
                ),
              ),
            ),

            // MARK: 이미지 표시 영역 (첫 페이지에만 표시)
            if (index == 0 && imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 280.w,
                  height: 180.h,
                ),
              ),
              SizedBox(height: 14.h),
            ],

            // MARK: 본문 텍스트
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

            // MARK: 날짜 및 보내는 사람
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text(
                  "$sentAt\nFrom. $nickname",
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

  // MARK: - 페이지 인디케이터
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
  /// 서버에서 전달받은 paperId를 실제 에셋 이미지로 매핑
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
