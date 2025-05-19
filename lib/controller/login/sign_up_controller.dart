import 'package:get/get.dart';

class SignUpController extends GetxController {
  var nickname = ''.obs;
  var isPressed = false.obs; // 버튼 눌림 상태 관리

// 닉네임 업데이트
  void updateNickname(String value) {
    nickname(value);
  }

  // 닉네임 초기화
  void clearNickname() {
    nickname('');
  }

  // 닉네임 길이 반환
  int get nicknameLength => nickname.value.length;

  // 닉네임 유효성 검사
  bool isValidNickname() {
    return nickname.value.isNotEmpty;
  }

  // 버튼 눌림 상태 업데이트
  void setPressed(bool value) {
    isPressed(value);
  }

  // 컨트롤러 종료 시 상태 초기화
  @override
  void onClose() {
    clearNickname();
    isPressed(false); // 버튼 상태도 초기화
    super.onClose();
  }
}
