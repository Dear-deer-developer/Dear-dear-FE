import 'package:dear_deer_demo/controller/bottom_nav_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/view/calendar.dart';
import 'package:dear_deer_demo/view/contents/contents_main.dart';
import 'package:dear_deer_demo/view/home/home.dart';
import 'package:dear_deer_demo/view/letter/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class App extends GetView<BottomNavController> {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvoked: (didPop) => controller.popAction(),
        child: Scaffold(
          // ⚡️ 바 뒤로 본문(배경)이 비치도록
          extendBody: true,
          body: Stack(
            children: [
              SafeArea(child: _body()),
              // 🔻 떠 있는 커스텀 바텀네비
              Align(
                alignment: Alignment.bottomCenter,
                child: _FloatingBottomNav(
                  index: controller.index,
                  onTap: controller.changeIndex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return IndexedStack(
      index: controller.index,
      children: [
        const Home(),
        PostMain(),
        CalendarMain(),
        ContentsMain(),
      ],
    );
  }
}

/// MARK: - 바텀 네비게이션 (배경은 완전 투명)
class _FloatingBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _FloatingBottomNav({
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          // 부드러운 그림자
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            spreadRadius: -2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r), // 상단만 라운드
          topRight: Radius.circular(16.r),
          bottomLeft: Radius.zero, // 하단은 직각
          bottomRight: Radius.zero,
        ),
        child: Material(
          color: Colors.white, // 바 자체는 흰색
          child: SizedBox(
            height: 70.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  selected: index == 0,
                  label: '홈',
                  iconOff: ImagePath.homeOff,
                  iconOn: ImagePath.homeOn,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  selected: index == 1,
                  label: '우체국',
                  iconOff: ImagePath.postOff,
                  iconOn: ImagePath.postOn,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  selected: index == 2,
                  label: '캘린더',
                  iconOff: ImagePath.calenderOff,
                  iconOn: ImagePath.calenderOn,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  selected: index == 3,
                  label: '콘텐츠',
                  iconOff: ImagePath.contentsOff,
                  iconOn: ImagePath.contentsOn,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: - Nav item
class _NavItem extends StatelessWidget {
  final bool selected;
  final String label;
  final String iconOff;
  final String iconOn;
  final VoidCallback onTap;

  const _NavItem({
    required this.selected,
    required this.label,
    required this.iconOff,
    required this.iconOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color active = AppColors.Green03;
    const Color inactive = Color(0xFF999999);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘
              ImageData(
                path: selected ? iconOn : iconOff,
                width: 48.w,
                height: 48.h,
              ),
              SizedBox(height: 4.h),
              // 라벨
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: selected ? active : inactive,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
