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
  static String get nicknameDeletdButton =>
      'assets/images/nickname_delete_button.png';
  static String get loginIcon => 'assets/images/main_icon_login_page.png';

  // MARK: - Bot_nav_icon
  static String get homeOn => 'assets/images/home_on.png';
  static String get homeOff => 'assets/images/home_off.png';
  static String get postOn => 'assets/images/post_on.png';
  static String get postOff => 'assets/images/post_off.png';
  static String get calenderOn => 'assets/images/calender_on.png';
  static String get calenderOff => 'assets/images/calender_off.png';
  static String get contentsOn => 'assets/images/contents_on.png';
  static String get contentsOff => 'assets/images/contents_off.png';
}
