import 'package:dear_deer_demo/controller/contents/contents_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/widget/content_card.dart';
import 'package:dear_deer_demo/widget/filter_chip_list.dart';
import 'package:dear_deer_demo/widget/main_category_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ContentsMain extends GetView<ContentsController> {
  const ContentsMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Center(child: Text('콘텐츠', style: FontStyles.B1_bold_20)),
              SizedBox(height: 12.h),

              // 상단 3분류 탭: Obx 내부에서 Rx 직접 참조
              Obx(() => MainCategoryTab(
                    currentIndex:
                        controller.mainCategory.value.index, // ✅ Rx 사용
                    onTap: controller.selectMainTab,
                  )),
              SizedBox(height: 12.h),

              // 중간 필터 칩: Obx 내부에서 Rx 직접 참조
              Obx(() => FilterChipList(
                    filters: controller.filters, // ✅ getter지만 내부에서 Rx를 씀
                    selected: controller.filterIndex.value, // ✅ Rx 사용
                    onTap: controller.selectFilter,
                  )),
              SizedBox(height: 12.h),

              // 리스트
              Expanded(child: _ContentsList(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentsList extends StatelessWidget {
  final ContentsController controller;
  const _ContentsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.items.length; // ✅ RxList 길이 직접 참조
      if (count == 0) {
        return Center(child: Text('콘텐츠가 없습니다', style: FontStyles.B3_reg_15));
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetch(reset: true),
        child: ListView.separated(
          controller: controller.scrollController,
          padding: EdgeInsets.only(bottom: 24.h),
          itemCount: count,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, i) => ContentCard(
            item: controller.items[i], // ✅ RxList 원소 직접 참조
          ),
        ),
      );
    });
  }
}
