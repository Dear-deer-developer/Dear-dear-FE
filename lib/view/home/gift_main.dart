import 'package:dear_deer_demo/controller/home/gift_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GiftMain extends GetView<GiftController> {
  const GiftMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Stack(
      children: [
        // 상단: 헤더 + 트리
        Column(
          children: [
            _head(),
            SizedBox(height: 12.h),
            _tree(),
            // 바텀시트 뒤에 가려질 여백
            SizedBox(height: 40.h),
          ],
        ),

        // 하단: 바텀시트
        Align(
          alignment: Alignment.bottomCenter,
          child: _giftBottomSheet(),
        ),
      ],
    );
  }

  Widget _head() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, left: 4.w, right: 16.w),
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
          // 오른쪽 여백 맞추기용 (뒤로가기 버튼과 균형)
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _tree() {
    // 여기는 나중에 실제 3D 트리 위젯으로 교체할 영역
    return Container(
      width: 360.w,
      height: 306.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xffD9D9D9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: Alignment.center,
      child: Text(
        '트리 영역',
        style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
      ),
    );
  }

  // === 바텀시트 ===
  Widget _giftBottomSheet() {
    return Obx(() {
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
            // 위쪽 작은 핸들
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

            // 카테고리 탭
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: controller.tabs.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, i) {
                  final isSelected = i == controller.selectedTabIndex.value;
                  final tab = controller.tabs[i];

                  return GestureDetector(
                    onTap: () => controller.selectTab(i),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.G_01,
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.mainGreen : AppColors.G_02,
                          width: 1.w,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.labelKo,
                        style: isSelected
                            ? FontStyles.B3_bold_15
                            : FontStyles.B3_reg_15.copyWith(
                                color: AppColors.G_05),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),

            // 선물 카드 리스트
            Expanded(
              child: _giftListArea(),
            ),
          ],
        ),
      );
    });
  }

  Widget _giftListArea() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error.value != null) {
      return Center(
        child: Text(
          controller.error.value!,
          style: FontStyles.B3_reg_15.copyWith(color: AppColors.mainRed),
        ),
      );
    }

    if (controller.items.isEmpty) {
      return Center(
        child: Text(
          '받은 선물이 없어요',
          style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      scrollDirection: Axis.horizontal,
      itemCount: controller.items.length,
      separatorBuilder: (_, __) => SizedBox(width: 12.w),
      itemBuilder: (context, i) {
        final g = controller.items[i];
        return _giftCard(name: g.name, imageUrl: g.imageUrl);
      },
    );
  }

  Widget _giftCard({required String name, required String imageUrl}) {
    return Container(
      width: 148.w,
      // 높이는 ListView 안에서 알아서 맞춰짐 (대략 120.h 정도 느낌)
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_02, width: 1.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            imageUrl,
            width: 56.w,
            height: 56.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 8.h),
          Text(
            name,
            style: FontStyles.B3_reg_15,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
