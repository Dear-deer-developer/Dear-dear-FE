import 'package:get/get.dart';

// 기존 컨트롤러/서비스
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

// 🔗 신규(일정 API 연동)
import 'package:dear_deer_demo/util/custom_get_connect.dart';
import 'package:dear_deer_demo/service/schedule_service.dart';
import 'package:dear_deer_demo/controller/schedule_controller.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    // ── 서비스
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<BgMusicController>(BgMusicController(), permanent: true);
    Get.put<AppStartController>(AppStartController(), permanent: true);

    // 🔗 네트워크 베이스 (GetConnect) & 일정 API/컨트롤러
    Get.put<CustomGetConnect>(CustomGetConnect(), permanent: true);
    Get.put<ScheduleService>(ScheduleService(Get.find()), permanent: true);
    Get.put<ScheduleController>(ScheduleController(Get.find()),
        permanent: true);

    // ── 네비/탭
    Get.put(BottomNavController(), permanent: true);

    // ── 페이지 컨트롤러 (lazy도 OK)
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => PostController());
    Get.lazyPut(() => CalendarController());
    Get.lazyPut(() => ContentsController());
    Get.lazyPut(() => GiftController());
    Get.lazyPut<AlarmController>(() => AlarmController(), fenix: true);
  }
}
