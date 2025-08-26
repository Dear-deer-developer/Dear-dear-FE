import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/view/login/login_main.dart';
import 'package:dear_deer_demo/view/main_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  bool get _isLogined {
    final hasFirebaseUser = FirebaseAuth.instance.currentUser != null;
    final isRegistered = sharedPreferences.getBool('is_registered') ?? false;
    // “로그인 + 닉네임 등록 완료”가 되어야 메인으로
    return hasFirebaseUser && isRegistered;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 720), // figma 기준 사이즈, 임시 값
      builder: (_, __) {
        return GetMaterialApp(
          title: 'Dear.deer Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.bgColor,
          ),
          // 로그인 정보가 없으면 LoginMain() 페이지로, 있으면 Home() 페이지로 이동
          home: _isLogined ? const MainView() : const LoginMain(),
          debugShowCheckedModeBanner: false, // Debug 배너 없애기
        );
      },
    );
  }
}
