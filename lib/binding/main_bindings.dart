import 'package:dear_deer_demo/controller/app_start_controller.dart';
import 'package:dear_deer_demo/controller/bottom_nav_controller.dart';
import 'package:dear_deer_demo/controller/calendar/calendar_controller.dart';
import 'package:dear_deer_demo/controller/contents/contents_controller.dart';
import 'package:dear_deer_demo/controller/home/alarm_controller.dart';
import 'package:dear_deer_demo/controller/home/bg_music_controller.dart';
import 'package:dear_deer_demo/controller/home/gift_controller.dart';
import 'package:dear_deer_demo/controller/home/home_controller.dart';
import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/controller/post/post_controller.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:get/get.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    // 서비스
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<BgMusicController>(BgMusicController(), permanent: true);
    Get.put<AppStartController>(AppStartController(), permanent: true);

    // 네비/탭 컨트롤러
    Get.put(BottomNavController(), permanent: true);

    // 페이지 컨트롤러 (lazy로 두어도 OK)
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => PostController());
    Get.lazyPut(() => CalendarController());
    Get.lazyPut(() => ContentsController());
    Get.lazyPut(() => GiftController());
    Get.lazyPut<AlarmController>(() => AlarmController(), fenix: true);
  }
}
