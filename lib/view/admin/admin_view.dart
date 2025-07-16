import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/admin/hidden_posts_view.dart';
import 'package:dear_deer_demo/view/admin/temp_saved_view.dart';
import 'package:dear_deer_demo/view/admin/write_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdminViewController extends GetxController {
  RxInt selectedIndex = 0.obs;
}

class AdminView extends StatelessWidget {
  final AdminViewController controller = Get.put(AdminViewController());

  AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: _appBar(),
      body: _tab(),
    );
  }

// MARK: AppBar
  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.White,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text("콘텐츠", style: FontStyles.H1_bold_17),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () {
                Get.to(() => AdminView());
              },
              child: Image.asset("assets/images/_people_G_04_48px.png",
                  width: 48.w, height: 48.h),
            ),
          ),
        ],
      );

//MARK: Tab
  /// 글 쓰기, 임시 저장글 확인, 숨긴 글 클릭 시 해당 페이지로 이동이 가능합니다.
  Widget _tab() => Container(
        width: 140.w,
        height: double.infinity,
        color: AppColors.White,
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, top: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.to(() => WriteView()),
                child: Text(
                  "글 쓰기",
                  style: FontStyles.B1_reg_15,
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () => Get.to(() => TempSavedView()),
                child: Text(
                  "임시 저장글 확인",
                  style: FontStyles.B1_reg_15,
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () => Get.to(() => HiddenPostsView()),
                child: Text(
                  "숨긴 글 확인",
                  style: FontStyles.B1_reg_15,
                ),
              ),
            ],
          ),
        ),
      );
}
