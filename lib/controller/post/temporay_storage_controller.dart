import 'package:get/get.dart';

class TemporaryStorageController extends GetxController {
  var isDeleteMode = false.obs; // 삭제 모드 여부
  var selectedItems = <int>{}.obs; // 선택된 항목 인덱스 집합 (Set)
  var items = List.generate(3, (index) => index).obs; // 더미 아이템 리스트

  // 삭제 모드 토글 (on/off)
  void toggleDeleteMode() {
    isDeleteMode.value = !isDeleteMode.value;
    if (!isDeleteMode.value) {
      selectedItems.clear(); // 삭제 모드 해제 시 선택 초기화
    }
  }

  // 특정 아이템 선택/해제 토글
  void toggleItemSelection(int index) {
    if (selectedItems.contains(index)) {
      selectedItems.remove(index);
    } else {
      selectedItems.add(index);
    }
  }

  // 선택된 아이템 삭제 후 상태 초기화
  void confirmDelete() {
    items.removeWhere((itemIndex) => selectedItems.contains(itemIndex));
    selectedItems.clear();
    isDeleteMode.value = false;
  }

  // 현재 아이템 개수 반환 (items 리스트 기준)
  int get itemCount => items.length;
}
