// import 'package:dear_deer_demo/util/helper/auth_helper.dart';
// import 'package:dear_deer_demo/service/api_service.dart';
// import 'package:dear_deer_demo/social/kakao.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';

// class KakaoAuthHelper extends AuthHelper {
//   @override
//   Future<bool> login() async {
//     // 1) 카카오 SDK로 accessToken만 받음
//     final accessToken = await Kakao.loginAndGetAccessToken();
//     if (accessToken == null || accessToken.isEmpty) return false;

//     // 2) 서버에 교환 요청 → customToken 수령
//     final api = Get.find<ApiService>();
//     final customToken = await api.exchangeKakaoAccessToken(accessToken);
//     if (customToken == null || customToken.isEmpty) return false;

//     // 3) Firebase 로그인
//     final cred = await FirebaseAuth.instance.signInWithCustomToken(customToken);
//     return cred.user != null;
//   }

//   @override
//   Future<bool> logout() async {
//     await Kakao.logout();
//     return true;
//   }

//   @override
//   Future<String?> getToken() async {
//     final u = FirebaseAuth.instance.currentUser;
//     return u?.getIdToken();
//   }

//   @override
//   Future<bool> isLoggedIn() async => (await getToken()) != null;
// }
