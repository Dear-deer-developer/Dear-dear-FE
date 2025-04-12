import 'package:dear_deer_demo/controller/home/home_controller.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        _topWidget(),
        // 임시 홈 배경화면
        Expanded(
          child: Image.asset(
            ImagePath.homeBgImage,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  Widget _topWidget() {
    return Padding(
      padding:
          EdgeInsets.only(left: 24.w, right: 20.w, top: 14.h, bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 94.w,
            height: 38.h,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
            ),
          ),
          // 프로필 이미지
          Container(
            width: 36.w,
            height: 36.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD9D9D9),
            ),
          ),
        ],
      ),
    );
  }
}
