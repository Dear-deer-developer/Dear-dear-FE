import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/model/deardeer_user.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AccountSetting extends StatelessWidget {
  const AccountSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final user = auth.user.value;

    return Scaffold(
      body: _body(user),
    );
  }

  Widget _body(DeardeerUser? user) {
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
            SizedBox(
              width: 93.w,
            ),
            Text(
              '보안 설정',
              style: FontStyles.H2_bold_17,
            )
          ],
        ),
        SizedBox(
          height: 19.h,
        ),

        // MARK: 계정 정보
        Text('계정 정보', style: FontStyles.B4_bold_14),
        SizedBox(
          height: 8.h,
        ),
        Text('회원 아이디',
            style: FontStyles.S2_reg_12.copyWith(color: AppColors.G_06)),
        Text(
          user?.email ?? '-',
          style: FontStyles.B4_reg_14,
        ),

        SizedBox(height: 35.h),

        // MARK : 비밀번호 변경
        SizedBox(
          height: 48.h,
          child: Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '비밀번호 변경',
                style: FontStyles.B3_reg_15,
              ),
            ),
          ),
        ),

        // MARK : 회원 탈퇴
        SizedBox(
          height: 48.h,
          child: Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '회원 탈퇴',
                style: FontStyles.B3_reg_15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
