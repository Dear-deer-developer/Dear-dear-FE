import 'package:dear_deer_demo/controller/post/letter_received_controller.dart';
import 'package:dear_deer_demo/view/letter/letter_recived.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReceivedLetterList extends StatelessWidget {
  const ReceivedLetterList({super.key});

  @override
  Widget build(BuildContext context) {
    // 받은 편지 컨트롤러
    final controller = Get.put(LetterReceivedController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _message(),
            _letterList(controller),
          ],
        ),
      ),
    );
  }

  // MARK: - AppBar
  AppBar _appbar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "내 사서함",
          style: FontStyles.H2_bold_17,
        ),
      );

  // MARK: - 상단 안내 문구
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

  // MARK: - 받은 편지 리스트
  Widget _letterList(LetterReceivedController controller) {
    return Obx(() {
      // 로딩 중
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 데이터 없음
      if (controller.receivedLetters.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: Text(
              "아직 도착한 편지가 없어요.",
              style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06),
            ),
          ),
        );
      }

      // 받은 편지 리스트 표시
      return Padding(
        padding: EdgeInsets.only(top: 30.h),
        child: Center(
          child: Column(
            children: List.generate(controller.receivedLetters.length, (index) {
              final letter = controller.receivedLetters[index];
              final senderName = letter['sender']?['nickname'] ?? '익명';
              final receiverName = letter['receiver']?['nickname'] ?? '나';
              final content = letter['content'] ?? '';

              return Padding(
                padding: EdgeInsets.only(bottom: 32.h),
                child: GestureDetector(
                  onTap: () async {
                    final detail =
                        await controller.loadLetterDetail(letter['id']);
                    if (detail != null) {
                      Get.to(() => const LetterReceived(), arguments: detail);
                    } else {
                      print('편지 상세 데이터 없음');
                    }
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

                      Positioned(
                        left: 20.w,
                        bottom: 16.h,
                        child: Text(
                          "From. $senderName",
                          style: FontStyles.L3_reg_16.merge(
                            const TextStyle(fontFamily: 'LeeSeoyun'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}
