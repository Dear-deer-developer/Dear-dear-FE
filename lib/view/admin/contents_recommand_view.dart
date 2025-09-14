import 'package:dear_deer_demo/view/admin/contents_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/controller/admin/admin_contents_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';

class ContentsRecommandView extends StatelessWidget {
  final AdminContentsController controller = Get.find();

  final List<String> subjects = [
    '전체 보기',
    '영화 드라마',
    '음악',
    '카페',
  ];

  ContentsRecommandView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _subject(),
        Expanded(child: _contents()),
      ],
    );
  }

  // MARK: 주제 선택
  Widget _subject() => Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(subjects.length, (index) {
                final isSelected =
                    controller.selectedSubjectIndex.value == index;
                final text = subjects[index];

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
                      child: Text(text, style: FontStyles.B3_reg_15),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );

  // MARK: 콘텐츠 리스트
  Widget _contents() {
    return ListView.builder(
      itemCount: 3,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Get.to(() => const ContentsDetailView());
          },
          child: Padding(
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
                  padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                  child: Text(
                    "콘텐츠 제목 자리입니다.",
                    style: FontStyles.B2_reg_16,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4.h, bottom: 24.h),
                  child: Row(
                    children: [
                      Text(
                        "작성자: 가나다라마바",
                        style: FontStyles.S1_reg_13.copyWith(
                            color: AppColors.G_05),
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
          ),
        );
      },
    );
  }
}
