import 'package:get/get.dart';

class SignUpController extends GetxController {
  var nickname = ''.obs;

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

  // 컨트롤러 종료 시 상태 초기화
  @override
  void onClose() {
    clearNickname();
    super.onClose();
  }
}
