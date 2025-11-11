import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AccountSetting extends StatelessWidget {
  const AccountSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단바
        Row(
          children: [
            Image.asset(
              ImagePath.backIcon,
              width: 48.w,
              height: 48.h,
            ),
          ],
        )
      ],
    );
  }
}
