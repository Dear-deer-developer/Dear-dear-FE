import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

class Kakao {
  static Future<String?> loginAndGetAccessToken() async {
    kakao.OAuthToken? token;
    if (await kakao.isKakaoTalkInstalled()) {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (_) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        } catch (_) {
          return null;
        }
      }
    } else {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      } catch (_) {
        return null;
      }
    }
    return token.accessToken;
  }

  static Future<void> logout() async {
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
  }
}
