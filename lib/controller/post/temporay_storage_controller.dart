import 'package:get/get.dart';
import 'package:dear_deer_demo/service/post/temporary_storage_service.dart';

class TemporaryStorageController extends GetxController {
  final _service = Get.put(TemporaryStorageService());

  final items = <Map<String, dynamic>>[].obs;
  final selectedItems = <int>{}.obs;
  final isDeleteMode = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDraftLetters();
  }

  /// 임시 보관함 조회
  Future<void> fetchDraftLetters() async {
    try {
      isLoading.value = true;
      final list = await _service.fetchDraftLetters();
      final normalized = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) => e['id'] != null)
          .toList();
      items.assignAll(normalized);
    } catch (e) {
      print('fetchDraftLetters 실패: $e');
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDeleteMode() {
    isDeleteMode.toggle();
    if (!isDeleteMode.value) selectedItems.clear();
  }

  void toggleItemSelection(int? id) {
    if (id == null) return;
    if (selectedItems.contains(id)) {
      selectedItems.remove(id);
    } else {
      selectedItems.add(id);
    }
  }

  /// 삭제 처리
  Future<void> confirmDelete() async {
    if (selectedItems.isEmpty) return;

    try {
      final ids = selectedItems.toList();
      final res = await _service.deleteDraftLetters(ids);
      print('🧾 삭제 결과: $res');

      // UI 즉시 반영
      items.removeWhere((e) => ids.contains(e['id']));
      items.refresh();

      // 서버 싱크 재확인 (조금 더 기다리기)
      await Future.delayed(const Duration(seconds: 2));
      await fetchDraftLetters();

      Get.snackbar('완료', '${res?['deletedCount'] ?? ids.length}개의 편지를 삭제했습니다.');
    } catch (e) {
      Get.snackbar('오류', '삭제 중 문제가 발생했습니다.');
    } finally {
      selectedItems.clear();
      isDeleteMode.value = false;
    }
  }

  int get itemCount => items.length;
}
