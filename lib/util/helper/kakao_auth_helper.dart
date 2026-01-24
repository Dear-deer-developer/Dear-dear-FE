// import 'dart:convert';

// import 'package:dear_deer_demo/main.dart';
// import 'package:dear_deer_demo/util/helper/auth_helper.dart';
// import 'package:dear_deer_demo/util/logger.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get_connect/connect.dart';
// import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

// class KakaoAuthHelper implements AuthHelper {
//   static const String _baseUrl = 'http://dearxmas.com';

//   String? _firebaseIdToken;

//   @override
//   Future<bool> login() async {
//     try {
//       // 1 카카오 로그인
//       OAuthToken token;
//       if (await isKakaoTalkInstalled()) {
//         token = await UserApi.instance.loginWithKakaoTalk();
//       } else {
//         token = await UserApi.instance.loginWithKakaoAccount();
//       }
//       final kakaoAccessToken = token.accessToken;
//       logger.i("카카오 accessToken: $kakaoAccessToken");

//       // 2 백엔드로 카카오 accessToken 전달 → customToken 수신
//       final getx = GetConnect()..httpClient.baseUrl = _baseUrl;
//       final res = await getx.post(
//         '/auth/kakao',
//         {'accessToken': kakaoAccessToken},
//         contentType: 'application/json',
//       );

//       // 성공 여부 판단 상태코드
//       final code = res.statusCode ?? 0;
//       if (!(code >= 200 && code < 300) || res.bodyString == null) {
//         logger.e("POST /auth/kakao 실패: ${res.statusCode} / ${res.bodyString}");
//         return false;
//       }

//       // 응답 파싱
//       String? customToken;
//       final body = res.body;

//       if (body is Map) {
//         customToken = (body['customToken'] ?? body['firebaseToken']) as String?;
//       } else {
//         // 혹시 문자열로 온다면
//         final parsed = jsonDecode(res.bodyString!);
//         customToken =
//             parsed['customToken'] ?? parsed['firebaseToken'] as String?;
//       }

//       if (customToken == null || customToken.isEmpty) {
//         logger.e("customToken 파싱 실패: ${res.bodyString}");
//         return false;
//       }
//       logger.i("Firebase Custom Token: $customToken");

//       // 3 Firebase 커스텀 토큰 로그인
//       final cred =
//           await FirebaseAuth.instance.signInWithCustomToken(customToken);
//       _firebaseIdToken = await cred.user?.getIdToken();
//       logger.d('Firebase customToken 로그인 성공');
//       logger.i("Firebase UID: ${cred.user?.uid}");
//       logger.i("Firebase ID Token: $_firebaseIdToken");

//       // 4 백엔드에 Firebase ID Token 전달
//       // await _postIdToken(_firebaseIdToken!);

//       return true;
//     } catch (e) {
//       logger.e('KakaoAuthHelper.login 에러: $e');
//       return false;
//     }
//   }

//   @override
//   Future<bool> logout() async {
//     try {
//       // 카카오 로그아웃 (필수는 아니지만 정리 차 호출)
//       try {
//         await UserApi.instance.logout();
//       } catch (_) {}
//       await FirebaseAuth.instance.signOut();
//       _firebaseIdToken = null;
//       return true;
//     } catch (e) {
//       logger.e("KakaoAuthHelper.logout 예외: $e");
//       return false;
//     }
//   }

//   @override
//   Future<String?> getToken() async {
//     _firebaseIdToken ??= await FirebaseAuth.instance.currentUser?.getIdToken();
//     return _firebaseIdToken;
//   }

//   @override
//   Future<bool> isLoggedIn() async {
//     return FirebaseAuth.instance.currentUser != null;
//   }
// }
