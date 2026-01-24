import 'package:get/get.dart';

class AgreementController extends GetxController {
  // 체크 상태
  final reqAgree = false.obs; // [필수] 디어디어 약관 및 동의사항
  final optAgree = false.obs; // [선택] 혜택·이벤트 정보 수신
  final allAgree = false.obs; // 전체 동의

  bool get canNext => reqAgree.value; // [다음] 활성 조건: 필수 동의

  void toggleAll(bool v) {
    allAgree.value = v;
    reqAgree.value = v;
    optAgree.value = v;
  }

  void toggleReq(bool v) {
    reqAgree.value = v;
    _syncAll();
  }

  void toggleOpt(bool v) {
    optAgree.value = v;
    _syncAll();
  }

  void _syncAll() {
    allAgree.value = reqAgree.value && optAgree.value;
  }
}
