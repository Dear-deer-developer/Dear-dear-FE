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
      body: _body(),
    );
  }

  Widget _body() {
    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '콘텐츠',
                style: FontStyles.H2_bold_17,
              ),
            ),

            // 상단 3분류 탭
            Obx(
              () => MainCategoryTab(
                currentIndex: controller.mainCategory.value.index,
                onTap: controller.selectMainTab,
              ),
            ),
            SizedBox(height: 12.h),

            // 중간 필터 칩
            Obx(() => FilterChipList(
                  filters: controller.filters,
                  selected: controller.filterIndex.value,
                  onTap: controller.selectFilter,
                )),
            SizedBox(height: 12.h),

            // 리스트
            Expanded(child: _ContentsList(controller: controller)),
          ],
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
      final count = controller.items.length;
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
          itemBuilder: (context, i) => ContentCard(item: controller.items[i]),
        ),
      );
    });
  }
}
