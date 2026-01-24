// lib/util/custom_get_connect.dart
import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // ❌ 일단 주석

class CustomGetConnect extends GetConnect {
  static const bool useFirebaseAuth = false; // 나중에 true로만 바꾸면 됨

  Future<Map<String, String>?> putTokenToHeaders(
      Map<String, String>? headers) async {
    headers ??= {};

    if (!headers.containsKey('Authorization')) {
      if (useFirebaseAuth) {
        // Firebase 모드 (나중에 쓸 때만)
        // final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        // if (token != null && token.isNotEmpty) {
        //   headers['Authorization'] = 'Bearer $token';
        // }
      } else {
        // JWT 모드 → 아무것도 안 함 (ApiService가 직접 붙임)
      }
    }
    return headers;
  }
}
