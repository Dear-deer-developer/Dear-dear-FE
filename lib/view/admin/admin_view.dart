import 'package:dear_deer_demo/controller/admin/admin_view_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/admin/write_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdminView extends StatelessWidget {
  final AdminViewController controller = Get.put(AdminViewController());
  AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: _appbar(),
      body: Column(
        children: [
          _inventory(),
          Expanded(
            child: Obx(() {
              final index = controller.selectedIndex.value;
              if (index == 0) return WriteView();
              if (index == 1) return Center(child: Text("임시 저장글 확인"));
              if (index == 2) return Center(child: Text("숨긴 글 확인"));
              return SizedBox.shrink();
            }),
          ),
        ],
      ),
    );
  }

  AppBar _appbar() => AppBar(
        backgroundColor: AppColors.White,
        elevation: 0,
        centerTitle: true,
        title: Text("관리자 페이지", style: FontStyles.H1_bold_17),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
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
        ],
      );

  Widget _inventory() => Padding(
        padding: EdgeInsets.only(left: 8.w, top: 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => controller.selectedIndex.value = 0,
              child: Text(
                "글 쓰기",
                style: FontStyles.B1_reg_15,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => controller.selectedIndex.value = 1,
              child: Text(
                "임시 저장글 확인",
                style: FontStyles.B1_reg_15,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => controller.selectedIndex.value = 2,
              child: Text(
                "숨긴 글 확인",
                style: FontStyles.B1_reg_15,
              ),
            ),
          ],
        ),
      );
}
