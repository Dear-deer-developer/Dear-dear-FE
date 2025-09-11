import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/view/admin/scrap_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:dear_deer_demo/controller/admin/admin_contents_controller.dart';
import 'package:dear_deer_demo/view/admin/contents_recommand_view.dart';
import 'package:dear_deer_demo/view/admin/event_notification_view.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/admin/admin_view.dart';

class ContentsView extends StatelessWidget {
  final AdminContentsController controller = Get.put(AdminContentsController());
  ContentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: _appBar(),
      body: Column(
        children: [
          _top(controller),
          Expanded(
            child: Obx(() => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: [
                    ContentsRecommandView(), // 콘텐츠 추천 창
                    EventNotificationView(), // 행사 알림 창
                    ScrapView(), // 스크랩 창
                  ],
                )),
          ),
        ],
      ),
    );
  }

// MARK: AppBar
  /// 상단의 앱 바입니다.
  /// 우측 프로필 아이콘을 누르게 되면 관리자 페이지로 이동하게 됩니다.
  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.White,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text("콘텐츠", style: FontStyles.H2_bold_17),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () {
                Get.to(() => AdminView());
              },
              child:
                  Image.asset(ImagePath.adminIcon, width: 48.w, height: 48.h),
            ),
          ),
        ],
      );
// MARK: 상단 탭
  /// 콘텐츠 추천, 행사 알림, 스크랩 탭을 포함합니다.
  /// 각 탭을 클릭 시 해당 탭의 내용이 표시됩니다.
  /// 선택 시, 하단에 검은색 디바이더가 노출됩니다.
  /// 각 탭은 AdminContentsController의 selectedIndex를 통해 관리됩니다.
  Widget _top(AdminContentsController controller) => Obx(
        () => Padding(
          padding: EdgeInsets.only(bottom: 7.h),
          child: Row(
            children: List.generate(3, (index) {
              final titles = ["콘텐츠 추천", "행사 알림", "스크랩"];
              final isSelected = controller.selectedIndex.value == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectTab(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titles[index],
                        style: FontStyles.H3_bold_16.copyWith(
                          color: isSelected ? AppColors.Black : AppColors.G_04,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        height: 4.h,
                        width: 100.w,
                        color:
                            isSelected ? AppColors.Black : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
}
