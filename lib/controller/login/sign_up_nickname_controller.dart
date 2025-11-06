import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SignupNicknameController extends GetxController {
  final nickCtrl = TextEditingController();
  final nick = ''.obs; // 입력값
  final loading = false.obs; // 하단 버튼 로딩

  // 2~8자, 영문/숫자/완성형 한글만 허용 (공백/특수문자/이모지 불가)
  final _allow = RegExp(r'^[A-Za-z0-9\uAC00-\uD7A3]{2,8}$');

  void onChanged(String v) => nick.value = v.trim();

  int get len => nick.value.length;
  bool get isValid => _allow.hasMatch(nick.value);

  String? get helperError {
    if (nick.value.isEmpty) return null;
    if (len < 2 || len > 8) return '최소 2글자, 최대 8글자까지 입력 가능합니다.';
    if (!RegExp(r'^[A-Za-z0-9\uAC00-\uD7A3]+$').hasMatch(nick.value)) {
      return '영문, 한글, 숫자만 입력 가능해요. (특수문자, 공백, 이모지 불가)';
    }
    return null;
  }

  @override
  void onClose() {
    nickCtrl.dispose();
    super.onClose();
  }
}
