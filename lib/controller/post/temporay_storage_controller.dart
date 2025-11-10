import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dear_deer_demo/service/post/temporary_storage_service.dart';
import 'package:dear_deer_demo/service/auth_service.dart';

class TemporaryStorageController extends GetxController {
  final _service = Get.put(TemporaryStorageService());
  final _auth = Get.find<AuthService>();

  final items = <Map<String, dynamic>>[].obs; // 임시보관함 편지 리스트
  final selectedItems = <int>{}.obs; // 선택된 편지 id 집합
  final isDeleteMode = false.obs; // 삭제 모드 on/off
  final isLoading = false.obs; // 로딩 상태

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

      final normalized = <Map<String, dynamic>>[];

      for (final e in list) {
        final map = Map<String, dynamic>.from(e as Map);

        // receiver 안전하게 추출
        String receiverNickname = '익명';
        if (map['receiver'] != null) {
          final receiverData = Map<String, dynamic>.from(map['receiver']);
          receiverNickname = receiverData['nickname'] ?? '익명';
        }

        // 시간 포맷 변환
        String formattedTime = '';
        final updatedAt = map['updatedAt'];
        if (updatedAt != null) {
          try {
            final utc = DateTime.parse(updatedAt);
            final local = utc.toLocal();
            formattedTime = DateFormat('yyyy년 M월 d일 HH:mm').format(local);
          } catch (_) {}
        }

        // 표시용 필드 추가
        map['displayTitle'] = 'dear. $receiverNickname';
        map['formattedTime'] = formattedTime;

        normalized.add(map);
      }

      print('정제된 데이터: $normalized');
      items.assignAll(normalized);
    } catch (e) {
      print('fetchDraftLetters 실패: $e');
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// 삭제 모드 토글
  void toggleDeleteMode() {
    isDeleteMode.toggle();
    if (!isDeleteMode.value) selectedItems.clear();
  }

  /// 항목 선택 토글
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
    if (selectedItems.isEmpty) {
      Get.snackbar('알림', '삭제할 편지를 선택해주세요.');
      return;
    }

    try {
      final ids = selectedItems.toList();
      print('삭제 요청 IDs: $ids');

      // Swagger 명세에 맞는 쿼리 방식 호출
      final res = await _service.deleteDraftLetters(ids);
      print('삭제 결과: $res');

      // UI 즉시 반영
      items.removeWhere((e) => ids.contains(e['id']));
      items.refresh();

      // 서버 싱크 재확인
      await Future.delayed(const Duration(seconds: 2));
      await fetchDraftLetters();

      Get.snackbar('완료', '${ids.length}개의 편지를 삭제했습니다.');
    } catch (e) {
      print('삭제 중 오류: $e');
      Get.snackbar('오류', '삭제 중 문제가 발생했습니다.');
    } finally {
      selectedItems.clear();
      isDeleteMode.value = false;
    }
  }

  int get itemCount => items.length;
}
