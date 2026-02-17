import 'package:dear_deer_demo/controller/calendar/calendar_controller.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'calendar_screen.dart';

class CalendarMain extends StatelessWidget {
  CalendarMain({super.key});

  final CalendarController controller = Get.find<CalendarController>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Obx(() {
          final bgPath = controller.dayNight.isNight.value
              ? ImagePath.homeBgImagePm
              : ImagePath.homeBgImageAm;

          return Stack(
            children: [
              // === 배경 ===
              Positioned.fill(
                child: Image.asset(
                  bgPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center, // ⭐ 홈과 완전히 동일하게!
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 55.h, // ← 아래쪽 여백
                      child: Image.asset(
                        ImagePath.calendarBackground,
                        // fit: BoxFit.cover,
                      ),
                    ),

                    // 캘린더 화면
                    Positioned.fill(
                      child: CalendarScreen(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
