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
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _head(),
        SizedBox(
          height: 19.h,
        ),
        _tree(),
        Expanded(child: _ornament()),
      ],
    );
  }

  Widget _head() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, left: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Image.asset(
              ImagePath.backIcon,
              width: 48.w,
              height: 48.h,
            ),
          ),
          SizedBox(width: 103.w),
          Text(
            '선물함',
            textAlign: TextAlign.center,
            style: FontStyles.H2_bold_17, // H2로 변경해야함.
          ),
        ],
      ),
    );
  }

  Widget _tree() {
    return Container(
      width: 360.w,
      height: 306.h,
      decoration: const BoxDecoration(
        color: Color(0xffD9D9D9),
      ),
    );
  }

// MARK: - 오너먼트
  Widget _ornament() {
    return Obx(() {
      return Column(
        children: [
          // 카테고리 탭
          SizedBox(
            height: 59.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, i) {
                final isSelected = i == controller.selectedCategoryIndex.value;
                return GestureDetector(
                  onTap: () => controller.selectCategory(i),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.mainGreen : AppColors.G_02,
                        width: 1.w,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.categories[i].name.toUpperCase(),
                      style: isSelected
                          ? FontStyles.B3_bold_15
                          : FontStyles.B3_reg_15,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),

          // 아이템 그리드
          Expanded(
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : (controller.error.value != null)
                    ? Center(child: Text(controller.error.value!))
                    : (controller.items.isEmpty)
                        ? const Center(child: Text('아이템 없음'))
                        : GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,
                              childAspectRatio: 148.w / 120.h,
                            ),
                            itemCount: controller.items.length,
                            itemBuilder: (context, i) {
                              final g = controller.items[i];
                              return _giftCard(
                                  name: g.name, imageUrl: g.imageUrl);
                            },
                          ),
          ),
        ],
      );
    });
  }

  Widget _giftCard({required String name, required String imageUrl}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_02, width: 1.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(imageUrl,
              width: 56.w, height: 56.w, fit: BoxFit.contain),
          SizedBox(height: 8.h),
          Text(name,
              style: FontStyles.B3_reg_15, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
