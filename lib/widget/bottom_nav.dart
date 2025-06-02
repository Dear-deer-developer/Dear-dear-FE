import 'package:dear_deer_demo/controller/bottom_nav_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BottomNav extends GetView<BottomNavController> {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 87.h,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // 색상
              spreadRadius: -1.r, // 그림자 확산 범위
              blurRadius: 4.r, // 그림자의 흐림 정도, 값이 클수록 흐릿해지면서 가장자리가 부드러워짐
              offset: Offset(0, -1.h), // 그림자 위치 y축으로 아래로 1만큼 감.
            ),
          ],
        ),
        // ios기기에서 발생하는 오버플로 현상 해결
        child: OverflowBox(
          maxHeight: double.infinity,
          child: BottomNavigationBar(
            currentIndex: controller.index,
            onTap: controller.changeIndex,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedItemColor: AppColors.mainRed,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(fontSize: 8.sp),
            unselectedLabelStyle: TextStyle(fontSize: 8.sp),
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon:
                    Image.asset(ImagePath.homeIcon, width: 24.w, height: 24.h),
                activeIcon: Image.asset(ImagePath.homeIconSelected,
                    width: 24.w, height: 24.h),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(ImagePath.postBoxIcon,
                    width: 24.w, height: 24.h),
                activeIcon: Image.asset(ImagePath.postBoxIconSelected,
                    width: 24.w, height: 24.h),
                label: '우체국',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(ImagePath.calendarIconS,
                    width: 24.w, height: 24.h),
                activeIcon: Image.asset(ImagePath.calendarIconSelected,
                    width: 24.w, height: 24.h),
                label: '캘린더',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(ImagePath.contentIcon,
                    width: 24.w, height: 24.h),
                activeIcon: Image.asset(ImagePath.contentIconSelected,
                    width: 24.w, height: 24.h),
                label: '콘텐츠',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
