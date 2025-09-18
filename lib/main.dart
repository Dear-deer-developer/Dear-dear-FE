import 'package:dear_deer_demo/app.dart';
import 'package:dear_deer_demo/binding/main_bindings.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'package:dear_deer_demo/util/mem_cache.dart';
import 'package:dear_deer_demo/view/login/login_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// SharedPreferences 선언 - 내부 디스크 이용
late SharedPreferences sharedPreferences;

class SharedPreferencesKeys {
  static const String isRegistered = "is_registered";
  static const String dDayData = "dday_data";

  static const String deardeerUserJson = "user_json";
  static const String firebaseToken = "token";

  // bgmusic
  static String bgMusicSelectedIndex = "bg_music_selected_index";
}

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

Future<void> main() async {
  // Widget 시스템 초기화 ( 플랫폼 채널 사용 등 사전 준비 )
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바, UI 표시 설정
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom] // 상단바 숨기기
      );

  // 가로모드 X
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 앱 내 정보 한국으로 변경
  await initializeDateFormatting('ko_KR', null);

  // 디버깅 체크 로그
  logger.d('Debug check');

  Future<void> loadLeeSeoyunFont() async {
    final loader = FontLoader('LeeSeoyun')
      ..addFont(rootBundle.load('assets/fonts/LeeSeoyun.ttf'));
    await loader.load();
  }

  // 이서연체 적용
  await loadLeeSeoyunFont();

  // Futures
  final firebaseFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final dotEnvFuture = dotenv.load();
  final sharedPrefFuture = SharedPreferences.getInstance();

  // .env 파일 로드
  await dotEnvFuture;
  logger.d('환경 변수 로드 완료');

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']);
  logger.d("Kakao SDK 초기화 완료");

  // SharedPreferences 로드
  sharedPreferences = await sharedPrefFuture;

  // Firebase 초기화 완료 대기
  await firebaseFuture;

  // 캐시 복구
  await _init();

  runApp(Phoenix(child: const MyApp()));
}

Future<void> _init() async {
  final isRegistered =
      sharedPreferences.getBool(SharedPreferencesKeys.isRegistered) ?? false;

  if (isRegistered) {
    final cachedUser =
        sharedPreferences.getString(SharedPreferencesKeys.deardeerUserJson);
    final fbUser = FirebaseAuth.instance.currentUser;

    if (fbUser != null && cachedUser != null) {
      // 메모리 캐시에 적재
      MemCache.put(MemCacheKey.deardeerUserJson, cachedUser);
      final idToken = await fbUser.getIdToken();
      MemCache.put(MemCacheKey.firebaseAuthIdToken, idToken);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 720),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        title: 'Dear.deer Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.bgColor,
        ),
        initialBinding: MainBindings(),
        home: const _RootGate(),
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final bool loggedIn = auth.user.value != null; // 캐시 복구 성공 시 true
    return loggedIn ? const App() : const LoginMain();
  }
}

// MARK: - 앱 시작 시 유저 상태 및 컨트롤러 초기화
Future<void> resetApp() async {
  Get.deleteAll(force: true);
  MemCache.clear();
  await _init();
  Phoenix.rebirth(Get.context!);
  Get.reset();
}
