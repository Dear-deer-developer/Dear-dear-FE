import 'package:get/get.dart';

class CategoryController extends GetxController {
  // RxSet 선언 (중복 불가 집합)
  RxSet<int> selectedIndices = <int>{}.obs;

  // 선택 토글 함수
  void toggleSelection(int index) {
    final tempSet = selectedIndices.toSet(); // 현재 상태 복사
    if (tempSet.contains(index)) {
      tempSet.remove(index); // 있으면 제거 (해제)
    } else {
      tempSet.add(index); // 없으면 추가 (선택)
    }
    selectedIndices.value = tempSet; // 상태 변경 명시적으로 알림
  }
}
