import 'package:dear_deer_demo/controller/home/alarm_controller.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AlarmMain extends GetView<AlarmController> {
  const AlarmMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _head(),
        SizedBox(
          height: 19.h,
        ),
      ],
    );
  }

  Widget _head() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, left: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Image.asset(
              ImagePath.backIcon,
              width: 48.w,
              height: 48.h,
            ),
          ),
          SizedBox(width: 69.w),
          Text(
            '크리스마스 알람',
            textAlign: TextAlign.center,
            style: FontStyles.L1_reg_20,
          ),
          SizedBox(
            height: 19.h,
          ),
        ],
      ),
    );
  }
}
