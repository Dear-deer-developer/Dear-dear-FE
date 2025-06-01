import 'package:dear_deer_demo/social/create_firebase_custom_token.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class Kakao {
  static Future<bool> login() async {
    final accessToken = (await _login())?.accessToken;

    try {
      if (accessToken != null) {
        final customToken = await createFirebaseCustomToken(
          accessToken: accessToken,
          loginType: 'kakaoCustomAuth',
        );
        final userCredential =
            await FirebaseAuth.instance.signInWithCustomToken(customToken);
        return userCredential.user != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<OAuthToken?> _login() async {
    // 카카오 로그인 구현 예제

    // 카카오톡 실행 가능 여부 확인
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        final token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        return token;
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return null;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          final token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          return token;
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
          return null;
        }
      }
    } else {
      try {
        final token = await UserApi.instance.loginWithKakaoAccount();
        print(await KakaoSdk.origin);
        print('카카오계정으로 로그인 성공');
        return token;
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
        return null;
      }
    }
  }

  static Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      print('로그아웃 성공, SDK에서 토큰 삭제');
    } catch (error) {
      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
  }
}
