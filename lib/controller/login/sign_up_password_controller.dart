import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SignupPasswordController extends GetxController {
  final pwCtrl = TextEditingController();
  final pw2Ctrl = TextEditingController();

  final pw = ''.obs;
  final pw2 = ''.obs;

  final showPw = false.obs;
  final showPw2 = false.obs;

  // 규칙: 8~12자, 영문/숫자/특수문자 모두 포함
  final _pwRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^\w\s]).{8,12}$');

  bool get isPwValid => _pwRegex.hasMatch(pw.value);
  bool get isMatch => pw.value.isNotEmpty && pw.value == pw2.value;

  bool get canNext => isPwValid && isMatch;

  void onPwChanged(String v) => pw.value = v;
  void onPw2Changed(String v) => pw2.value = v;

  void clearPw() {
    pwCtrl.clear();
    pw.value = '';
  }

  void clearPw2() {
    pw2Ctrl.clear();
    pw2.value = '';
  }

  @override
  void onClose() {
    pwCtrl.dispose();
    pw2Ctrl.dispose();
    super.onClose();
  }
}
