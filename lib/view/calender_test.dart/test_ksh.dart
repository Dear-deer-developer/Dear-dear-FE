import 'package:dear_deer_demo/widget/custom_calender.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CalenderTestKsh extends StatelessWidget {
  const CalenderTestKsh({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        // MARK: - calender widget
        children: [
          // 상단 위젯
          Positioned(
            left: 0,
            child: Row(
              children: [
                // 뒤로가기 버튼
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    width: 25.w,
                    height: 25.h,
                  ),
                ),
                // 여백
                SizedBox(width: 140.w),
                // Text
                Text(
                  '달력',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
          const CustomCalender(),
        ],
      ),
    );
  }
}
