import 'package:dear_deer_demo/app.dart';
import 'package:dear_deer_demo/controller/bottom_nav_controller.dart';
import 'package:dear_deer_demo/main.dart'
    show sharedPreferences, SharedPreferencesKeys;
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/helper/auth_helper.dart';
import 'package:dear_deer_demo/util/helper/kakao_auth_helper.dart';
import 'package:dear_deer_demo/view/home.dart';
import 'package:dear_deer_demo/view/login/sign_up_first.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginMain extends StatelessWidget {
  const LoginMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 80.h),
              child: Column(
                children: [
                  // MARK: - 아이콘
                  Image.asset(
                    ImagePath.loginIcon,
                    width: 215.w,
                    height: 215.h,
                  ),
                  SizedBox(
                    height: 251.h,
                  ),
                  // MARK: - 로그인 버튼
                  GestureDetector(
                    onTap: () async {
                      final result = await Get.find<AuthService>()
                          .login(KakaoAuthHelper());

                      if (!result.isSuccess) {
                        Get.snackbar('로그인 실패', '잠시 후 다시 시도해 주세요.');
                        return;
                      }

                      sharedPreferences.setBool(
                          SharedPreferencesKeys.isRegistered,
                          !result.isNewUser);

                      if (result.isNewUser) {
                        // 신규 → 닉네임 입력
                        Get.offAll(() => SignUpFirst());
                      } else {
                        // 기존 → home
                        Get.find<BottomNavController>().resetToHome();
                        Get.offAll(() => const App());
                      }
                    },
                    child: Image.asset(
                      ImagePath.kakaoLoginButton,
                      width: 312.w,
                      height: 48.h,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // MARK: - 로그인 함수
  Future<void> login(AuthHelper helper) async {
    final auth = Get.find<AuthService>();
    final result = await auth.login(helper);

    if (!result.isSuccess) {
      Get.snackbar("로그인 실패", "로그인에 실패했습니다. 잠시 후 다시 시도해 주세요.");
      return;
    }

    // 신규가입 여부에 따라 분기
    if (result.isNewUser) {
      // 닉네임/프로필 등록 화면
      Get.offAll(() => SignUpFirst());
    } else {
      // 메인 화면
      Get.find<BottomNavController>().resetToHome();
      Get.offAll(() => const App());
    }
  }
}
