import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/view/admin/admin_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ContentsDetailView extends StatelessWidget {
  const ContentsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: _appBar(),
      body: Column(
        children: [
          _photo(),
          _context(),
        ],
      ),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.White,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text("숨긴 글 확인", style: FontStyles.H1_bold_17),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Image.asset(ImagePath.vector, width: 24.w, height: 24.h),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => AdminView());
                  },
                  child: Image.asset(ImagePath.adminIcon,
                      width: 48.w, height: 48.h),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _photo() => Padding(
        padding: EdgeInsets.only(top: 16.h, bottom: 34.h),
        child: Container(
          width: double.infinity,
          height: 356.h,
          color: Colors.grey,
        ),
      );

  Widget _context() => Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 24.w, top: 8.h, bottom: 4.h),
              child: Text(
                "콘텐츠 제목 자리입니다.",
                style: FontStyles.H1_bold_22,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 24.w, top: 4.h, bottom: 24.h),
              child: Row(
                children: [
                  Text(
                    "작성자: 가나다라마바",
                    style: FontStyles.S1_reg_13.copyWith(color: AppColors.G_05),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Text(
                      "조회수: 1.3만   스크랩 수: 10만",
                      style:
                          FontStyles.S1_reg_13.copyWith(color: AppColors.G_05),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 24.w),
              child: Text(
                "본문 자리입니다.",
                style: FontStyles.B1_reg_16,
              ),
            ),
          )
        ],
      );
}
