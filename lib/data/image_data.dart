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
  static String get homeIcon => 'assets/images/icon_home.png';
  static String get homeIconSelected => 'assets/images/icon_home_selected.png';
  static String get postBoxIcon => 'assets/images/icon_postbox.png';
  
  static String get homeBgImage => 'assets/images/temp_home.png';

  // MARK: - Login
  static String get kakaoLoginButton => 'assets/images/kakao_login_button.png';

  // MARK: - Post
  static String get postBoxIconSelected => 'assets/images/icon_postbox_selected.png';
  static String get calendarIconS => 'assets/images/icon_calendar.png';
  static String get calendarIconSelected => 'assets/images/icon_calendar_selected.png';
  static String get contentIcon => 'assets/images/icon_content.png';
  static String get contentIconSelected => 'assets/images/icon_content_selected.png';
  
  static String get deerPost => 'assets/images/post_deer.png';

  static String get letterImage => 'assets/images/letter.png';
  static String get letterBoxImage => 'assets/images/letterbox.png';

  static String get imageIcon => 'assets/images/image_icon.png';
  static String get imageIconDisabled => 'assets/images/image_icon_disable.png';

}
