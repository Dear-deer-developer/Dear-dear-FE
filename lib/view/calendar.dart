import 'package:dear_deer_demo/controller/calendar/calendar_controller.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'calendar/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CalendarMain extends StatelessWidget {
  CalendarMain({super.key});

  final controller = Get.put(CalendarController());

  String _getBackgroundImage() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 7 && hour < 18) {
      return ImagePath.dayBackground;
    } else {
      return ImagePath.nightBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent, // 상태바 배경 투명
        statusBarIconBrightness: Brightness.light, // 아이콘 색상 흰색 계열
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _getBackgroundImage(),
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
                child: Image.asset(ImagePath.calendarBackground,
                    fit: BoxFit.cover)),
            const Positioned.fill(
              child: CalendarScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
