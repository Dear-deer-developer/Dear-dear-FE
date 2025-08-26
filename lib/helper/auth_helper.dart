abstract class AuthHelper {
  /// 플랫폼(카카오 등) 로그인 -> Firebase 커스텀 토큰 로그인까지 포함
  Future<bool> login();

  /// 플랫폼(카카오 등) 로그아웃 (필요 시 Firebase 로그아웃은 서비스에서 별도로 수행)
  Future<bool> logout();

  /// 현재 Firebase 유저의 ID Token (null이면 비로그인)
  Future<String?> getToken();

  /// 로그인 여부 (ID Token 존재 여부로 단순 판별)
  Future<bool> isLoggedIn();
}
