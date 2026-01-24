import 'package:dear_deer_demo/controller/post/letter_preview_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/service/post/block_service.dart';
import 'package:dear_deer_demo/view/letter/report_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LetterReceived extends StatelessWidget {
  const LetterReceived({super.key});

  // MARK: 날짜 포맷
  String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final utc = DateTime.parse(isoString).toUtc();
      final kst = utc.add(const Duration(hours: 9));
      return DateFormat('yyyy년 MM월 dd일').format(kst);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LetterPreviewController());
    final authService = Get.find<AuthService>();
    final nickname = authService.user.value?.nickname ?? '나';

    final args = Get.arguments ?? {};
    final content = args['content'] ?? '';
    final sentAt = args['sentAt'] ?? '';
    final sender = args['sender'] ?? {};
    final senderName = sender['nickname'] ?? '';
    final paperId = args['paperId'] ?? 1;
    final presignedUrl = args['presignedUrl'];

    final int letterId = args['id'] ?? 0;
    final int senderId = sender['id'] ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setLetterContent(content);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(letterId, senderId),
      body: _body(
        controller,
        senderName,
        formatDate(sentAt),
        _getPaperAsset(paperId),
        nickname,
        presignedUrl,
      ),
    );
  }

  // MARK: AppBar
  AppBar _appBar(int letterId, int senderId) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Text('받은 편지함', style: FontStyles.H2_bold_17),
      ),
      actions: [
        PopupMenuButton<String>(
          color: Colors.white,
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            if (value == 'report') {
              Get.to(() => ReportScreen(
                    letterId: letterId,
                    senderId: senderId,
                  ));
            } else if (value == 'block') {
              Get.dialog(
                _blockDialog(senderId),
                barrierDismissible: true,
              );
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'report',
              child: Text('신고하기', style: FontStyles.B3_reg_15),
            ),
            PopupMenuItem(
              value: 'block',
              child: Text('사용자 차단하기', style: FontStyles.B3_reg_15),
            ),
          ],
        ),
      ],
    );
  }

  // MARK: Body
  Widget _body(
    LetterPreviewController controller,
    String senderName,
    String sentAt,
    String paperAsset,
    String nickname,
    String? presignedUrl,
  ) {
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
            children: [
              _letterView(
                controller,
                senderName,
                sentAt,
                paperAsset,
                nickname,
                presignedUrl,
              ),
              const SizedBox(height: 30),
              _pageIndicator(controller),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: Letter View
  Widget _letterView(
    LetterPreviewController controller,
    String senderName,
    String sentAt,
    String paperAsset,
    String nickname,
    String? presignedUrl,
  ) {
    return SizedBox(
      height: 460.h,
      child: Obx(
        () => PageView.builder(
          controller: controller.pageController,
          itemCount: controller.pagedTexts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
              child: _letterCard(
                controller.pagedTexts[index],
                senderName,
                sentAt,
                paperAsset,
                nickname,
              ),
            );
          },
        ),
      ),
    );
  }

  // MARK: Letter Card
  Widget _letterCard(
    String text,
    String senderName,
    String sentAt,
    String paperAsset,
    String nickname,
  ) {
    return AspectRatio(
      aspectRatio: 3 / 4.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(paperAsset, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Text('Dear. $nickname', style: FontStyles.L1_reg_20),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(text, style: FontStyles.L3_reg_16),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '$sentAt\nFrom. $senderName',
                      textAlign: TextAlign.right,
                      style: FontStyles.L3_reg_16,
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

  // MARK: Indicator
  Widget _pageIndicator(LetterPreviewController controller) {
    return Obx(() {
      if (controller.pagedTexts.isEmpty) return const SizedBox();
      return SmoothPageIndicator(
        controller: controller.pageController,
        count: controller.pagedTexts.length,
        effect: const SlideEffect(
          dotWidth: 6,
          dotHeight: 6,
          activeDotColor: AppColors.mainRed,
          dotColor: AppColors.G_03,
        ),
      );
    });
  }

  // MARK: Paper
  String _getPaperAsset(int id) {
    return ImagePath.imageLetter1;
  }

  // MARK: 차단 다이얼로그
  Widget _blockDialog(int senderId) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Center(
        child: Text(
          '사용자 차단하기',
          style: FontStyles.H2_bold_17,
        ),
      ),
      content: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '상대방은 차단 여부를 알 수 없습니다.',
              style: FontStyles.B2_reg_16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '상대방이 나에게 쓰는 편지를 차단합니다.',
              style: FontStyles.B2_reg_16,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: Get.back,
                child: Text(
                  '취소',
                  textAlign: TextAlign.center,
                  style: FontStyles.B2_reg_16.copyWith(
                    color: AppColors.G_05,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  final service = BlockService();

                  final success =
                      await service.blockUser(targetUserId: senderId);

                  Get.back();

                  if (success) {
                    Get.snackbar('차단 완료', '사용자가 차단되었습니다.');
                  } else {
                    Get.snackbar('오류', '차단 중 문제가 발생했습니다.');
                  }
                },
                child: Text(
                  '차단하기',
                  textAlign: TextAlign.center,
                  style: FontStyles.B2_reg_16.copyWith(
                    color: AppColors.Black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
