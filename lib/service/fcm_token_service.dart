// lib/service/fcm_token_service.dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/service/api_service.dart';

class FcmTokenService {
  static Future<void> registerToken() async {
    final messaging = FirebaseMessaging.instance;

    // iOS 권한
    await messaging.requestPermission();

    final token = await messaging.getToken();
    if (token == null) return;

    final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
    final api = Get.find<ApiService>();

    // 서버에 최초 등록 또는 갱신
    await api.post('/fcm-tokens', {'token': token, 'platform': platform});

    // 토큰 갱신 자동 반영
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await api.put('/fcm-tokens', {'token': newToken, 'platform': platform});
    });
  }
}
