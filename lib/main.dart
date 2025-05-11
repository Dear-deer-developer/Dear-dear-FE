import 'package:dear_deer_demo/app.dart';
import 'package:dear_deer_demo/controller/bottom_nav_controller.dart';
import 'package:dear_deer_demo/controller/calendar/calendar_controller.dart';
import 'package:dear_deer_demo/controller/contents/contents_controller.dart';
import 'package:dear_deer_demo/controller/home/home_controller.dart';
import 'package:dear_deer_demo/controller/post/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';

// MARK: - logger 설정
Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // 메서드 호출 표시 개수
    errorMethodCount: 0, // 에러 시 표시되는 호출 스택 개수
    lineLength: 50, // 한 줄에 표시할 최대 문자 수
    colors: true, // 색상 사용 여부
    printEmojis: true, // 이모지 사용 여부
    printTime: false, // 로그에 시간 표시
  ),
);

void main() async {
  // Widget 시스템 초기화 ( 플랫폼 채널 사용 등 사전 준비 )
  WidgetsFlutterBinding.ensureInitialized();
  // 상태바, UI 표시 설정
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  // 가로모드 X
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // 앱 내 정보 한국으로 변경
  await initializeDateFormatting('ko_KR', null);
  // 디버깅 체크 로그
  logger.d('Debug check');

  // MARK: - 컨트롤러 등록
  /*
  Get.put(CustomCalendarController()); // ksh calendar controller
  Get.put(CalendarController());
  */
  /// 바텀 네비게이션 컨트롤러
  /// bot_nav는 항상 필요하므로 Get.put 사용
  /// 컨트롤러 lazyPut 등록
  Get.put(BottomNavController());

  Get.lazyPut(() => HomeController());
  Get.lazyPut(() => PostController());
  Get.lazyPut(() => CalendarController());
  Get.lazyPut(() => ContentsController());

  // 임시 유저 로그인 값 할당
  // bool isLogined = false; // 값 없음
  bool isLogined = true; // 값 있음
  runApp(App(isLogined: isLogined));
}
