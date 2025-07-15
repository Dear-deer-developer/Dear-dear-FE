import 'package:dear_deer_demo/controller/admin/content_recommand_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';

class ContentsRecommandView extends StatelessWidget {
  final ContentsRecommandController controller =
      Get.put(ContentsRecommandController());
  ContentsRecommandView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.White,
        appBar: _appBar(),
        body: Column(
          children: [
            _middle(controller),
            _subject(),
            Expanded(child: _contents()),
          ],
        ));
  }

  AppBar _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text("콘텐츠", style: FontStyles.H1_bold_17),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () {
                // Get.to(() => AdminView());
              },
              child: CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.G_04,
                child: Icon(
                  Icons.person,
                  size: 18.sp,
                  color: AppColors.White,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _middle(ContentsRecommandController controller) => Obx(
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
                        style: FontStyles.H1_bold_16.copyWith(
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

  Widget _subject() => Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(controller.subjects.length, (index) {
                final isSelected =
                    controller.selectedSubjectIndex.value == index;
                final text = controller.subjects[index];

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () => controller.selectSubject(index),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color:
                              isSelected ? AppColors.mainRed : AppColors.G_02,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(text, style: FontStyles.B1_reg_15),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );

  Widget _contents() {
    // if (controller.selectedIndex.value == 0) {
    return ListView.builder(
      itemCount: 3,
      padding: EdgeInsets.symmetric(horizontal: 24.w), // 리스트 전체 좌우 여백
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 312.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.G_03,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 4.h), // 좌측 패딩 제거
                child: Text(
                  "콘텐츠 제목 자리입니다.",
                  style: FontStyles.B1_reg_16,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h, bottom: 24.h), // 좌측 패딩 제거
                child: Row(
                  children: [
                    Text(
                      "작성자: 가나다라마바",
                      style:
                          FontStyles.S1_reg_13.copyWith(color: AppColors.G_05),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text(
                        "조회수: 1.3만   스크랩 수: 10만",
                        style: FontStyles.S1_reg_13.copyWith(
                            color: AppColors.G_05),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
