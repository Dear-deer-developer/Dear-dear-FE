abstract class AuthHelper {
  Future<bool> login();
  Future<bool> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
}
