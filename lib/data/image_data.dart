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

  static String get backIcon => 'assets/images/icon_back.png';

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

  // MARK: - Home
  static String get homeBgImagePm => 'assets/images/home_bgimage_pm.png'; // 밤
  static String get homeBgImageAm => 'assets/images/home_bgimage_am.png'; // 낮

  static String get homeTopWidget => 'assets/images/home_top_left_widget.png';

  static String get normalTree => 'assets/images/normal_room.png';

  static String get alarmIcon => 'assets/images/alarm_widget.png';
  static String get giftBoxIcon => 'assets/images/giftbox_widget.png';
  static String get bgMusicIcon => 'assets/images/bgmusic_widget.png';

  // MARK: - Background Music
  static String get cover_image_1 => 'assets/images/music_image_1.png';
  static String get cover_image_2 => 'assets/images/music_image_2.png';
  static String get cover_image_3 => 'assets/images/music_image_3.png';
  static String get cover_image_4 => 'assets/images/music_image_4.png';
  static String get cover_image_5 => 'assets/images/music_image_5.png';
  static String get cover_image_6 => 'assets/images/music_image_6.png';

  static String get musicPlayIcon => 'assets/images/music_play_icon.png';
  static String get musicStopIcon => 'assets/images/music_stop_icon.png';

  static String get musicPlayIconWhite => 'assets/images/icon_play_white.png';
  static String get musicStopIconWhite => 'assets/images/music_pause_icon.png';
  static String get musicNextIconWhite =>
      'assets/images/ic_round_skip_next.png';

  // MARK: - Setting
  static String get cameraIcon => 'assets/images/camera_icon.png';
  static String get sampleImage => 'assets/images/profile_sample_image.png';

  // MARK: - Post
  static String get postBoxIconSelected =>
      'assets/images/icon_postbox_selected.png';
  static String get calendarIconS => 'assets/images/icon_calendar.png';
  static String get calendarIconSelected =>
      'assets/images/icon_calendar_selected.png';
  static String get contentIcon => 'assets/images/icon_content.png';

  static String get contentIconSelected =>
      'assets/images/icon_content_selected.png';

  static String get deerPost => 'assets/images/post_deer.png';

  static String get letterImage => 'assets/images/letter.png';
  static String get letterBoxImage => 'assets/images/letterbox.png';

  static String get imageIcon => 'assets/images/image_icon.png';
  static String get imageIconDisabled => 'assets/images/image_icon_disable.png';

  // MARK: - Calendar
  static String get calendarBackground =>
      'assets/images/calendar_background.png';
  static String get dayBackground => 'assets/images/day.png';
  static String get nightBackground => 'assets/images/night.png';

  // MARK: Admin
  static String get adminIcon => 'assets/images/_people_G_04_48px.png';
  static String get vector => 'assets/images/Vector.png';
}
