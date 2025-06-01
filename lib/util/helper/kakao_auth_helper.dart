import 'package:dear_deer_demo/social/create_firebase_custom_token.dart';
import 'package:dear_deer_demo/util/helper/auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoAuthHelper extends AuthHelper {
  @override
  Future<String?> getToken() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    return user?.getIdToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    return firebase_auth.FirebaseAuth.instance.currentUser != null;
  }

  @override
  Future<bool> login() async {
    try {
      // 1. 카카오 로그인
      OAuthToken kakaoToken = await UserApi.instance.loginWithKakaoAccount();

      // 2. Firebase Custom Token 요청
      final firebaseToken = await createFirebaseCustomToken(
        loginType: 'kakaoCustomAuth',
        accessToken: kakaoToken.accessToken,
      );

      // 3. Firebase 로그인
      await firebase_auth.FirebaseAuth.instance
          .signInWithCustomToken(firebaseToken);
      return true;
    } catch (e) {
      print("카카오 로그인 실패: $e");
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    await UserApi.instance.logout();
    await firebase_auth.FirebaseAuth.instance.signOut();
    return true;
  }
}
