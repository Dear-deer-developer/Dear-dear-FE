import 'package:dear_deer_demo/view/calendar/ycr_calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class LoginMain extends StatelessWidget {
  const LoginMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 80.h),
              child: Column(
                children: [
                  // 캘린더 연습 - 성현
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r)),
                    width: 300.w,
                    height: 45.h,
                    child: const Center(child: Text("캘린더 연습 성현")),
                  ),
                  // 캘린더 연습 - 채림
                  ElevatedButton(
                    onPressed: () {
                      Get.to(YcrCalendar());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      minimumSize: Size(300.w, 45.h),
                    ),
                    child: const Text(
                      "캘린더 연습 채림",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // 캘린더 연습 - 성은
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10.r)),
                    width: 300.w,
                    height: 45.h,
                    child: const Center(child: Text("캘린더 연습 성은")),
                  ),
                  // 임시 로그인 버튼
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(10.r)),
                    width: 300.w,
                    height: 45.h,
                    child: const Center(child: Text("로그인 테스트")),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
