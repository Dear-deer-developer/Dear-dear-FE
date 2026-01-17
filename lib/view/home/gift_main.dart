import 'package:dear_deer_demo/controller/home/gift_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/widget/tree_slot_debug_overlay.dart';
import 'package:dear_deer_demo/widget/tree_slot_hit_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GiftMain extends GetView<GiftController> {
  const GiftMain({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Figma Rectangle 971: 상단(Y) = 108px
    // 회색 배경 시작선을 디자인 값 그대로 고정
    final double grayStartY = 108.h;

    return Scaffold(
      backgroundColor: AppColors.bgColor,

      // ✅ body 전체는 SafeArea로 감싸지 않음 (트리 top=42가 "화면 맨 위 기준"이어야 함)
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ===============================
          // 1) BACKGROUND (Method 1)
          //    - 0 ~ 108 : 흰색
          //    - 108 ~ 끝 : 회색
          // ===============================
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: grayStartY,
            child: Container(color: Colors.white),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: grayStartY,
            bottom: 0,
            child: Container(color: const Color(0xFFD9D9D9)),
          ),

          // ===============================
          // 2) HEADER
          // ✅ 헤더 콘텐츠만 SafeArea로 상태바 피함
          // ===============================
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: _head(),
            ),
          ),

          // ===============================
          // 3) TREE
          // ✅ Figma 기준: 화면 맨 위(상태바 포함)에서 42
          // ===============================
          Positioned(
            left: 0,
            right: 0,
            top: 42.h,
            child: _tree(),
          ),

          // ===============================
          // 4) BOTTOM SHEET (고정 / Obx 없음)
          // ===============================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _giftBottomSheet(),
          ),
        ],
      ),
    );
  }

  // MARK: HEADER
  // ✅ 헤더 높이 고정(48) + 좌우 패딩만
  Widget _head() {
    return SizedBox(
      height: 48.h,
      child: Padding(
        padding: EdgeInsets.only(left: 4.w, right: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: Get.back,
              child: Image.asset(
                ImagePath.backIcon,
                width: 48.w,
                height: 48.h,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '선물함',
                  style: FontStyles.H2_bold_17,
                ),
              ),
            ),
            SizedBox(width: 48.w),
          ],
        ),
      ),
    );
  }

  // MARK: TREE
  // - 프레임: 360
  // - 이미지: 370.w x 550.h (좌우 5씩 overflow)
  Widget _tree() {
    final double frameW = 1.sw; // 360
    final double imageW = 370.w;
    final double imageH = 550.h;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: frameW,
        height: imageH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Tree Image (overflow)
            Positioned(
              left: -5.w,
              top: 0,
              child: SizedBox(
                width: imageW,
                height: imageH,
                child: Image.asset(
                  ImagePath.normalTree,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // Slots (임시)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth; // 360
                  final h = c.maxHeight; // 550
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: TreeSlotHitLayer(
                          width: w,
                          height: h,
                          hitSize: 44,
                          onTapSlot: (slotId) => debugPrint('탭된 슬롯: $slotId'),
                        ),
                      ),
                      Positioned.fill(
                        child: TreeSlotDebugOverlay(
                          width: w,
                          height: h,
                          selectedSlotId: null,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: BOTTOM SHEET
  Widget _giftBottomSheet() {
    return Container(
      width: 1.sw,
      height: 230.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -4),
            blurRadius: 12.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.G_03,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Center(
              child: Text(
                '임시 바텀시트 (움직임/데이터 연동은 나중에)',
                style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
