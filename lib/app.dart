
import 'package:dear_deer_demo/view/admin/contents_view.dart';

import 'package:dear_deer_demo/view/%08letter/select_recipient.dart';

import 'package:dear_deer_demo/view/login/login_main.dart';
import 'package:dear_deer_demo/view/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  final bool isLogined;
  const App({super.key, required this.isLogined});

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
          ),
          // 로그인 정보가 없으면 LoginMain() 페이지로, 있으면 Home() 페이지로 이동
          home: isLogined ? const MainView() : const LoginMain(),

          debugShowCheckedModeBanner: false, // Debug 배너 없애기
        );
      },
    );
  }
}
