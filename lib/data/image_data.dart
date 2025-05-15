import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageData extends StatelessWidget {
  final String path;
  final double width;
  final double height;

  const ImageData(
      {super.key, required this.path, this.width = 60, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width / Get.mediaQuery.devicePixelRatio,
    );
  }
}

class ImagePath {
  //static String get 사용할이름 => 'assets/images/파일이름.png';
  static String get botNavIcon => 'assets/images/temp_bot_nav_icon.png';
  static String get homeBgImage => 'assets/images/temp_home.png';

  // MARK: - Login
  static String get kakaoLoginButton => 'assets/images/kakao_login_button.png';
}
