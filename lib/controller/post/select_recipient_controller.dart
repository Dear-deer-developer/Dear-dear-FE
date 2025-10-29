import 'package:dear_deer_demo/service/post/user_service.dart';
import 'package:get/get.dart';

/// 친구 선택 화면의 상태를 관리하는 컨트롤러입니다.
/// 친구 목록, 검색, 탭 상태, 선택된 친구, 선택된 이름을 관리합니다.
/// UI에서 선택된 친구 1명을 바로 Radio 버튼과 연동합니다.
class SelectRecipientController extends GetxController {
  // MARK: - 선택된 친구 인덱스
  /// 선택된 친구의 인덱스를 저장합니다.
  /// 선택 안 됐으면 null
  final Rxn<int> selectedIdx = Rxn<int>();

  // MARK: - 상단 탭 인덱스
  /// 0: 사서함 번호, 1: 링크로 보내기
  RxInt selectedTabIdx = 0.obs;

  // MARK: - 검색어
  final searchQuery = ''.obs;

  // MARK: - 검색 결과
  /// 서버에서 받아올 때 교체되는 실제 유저 데이터 목록
  final filteredFriends = <Map<String, String>>[].obs;

  // MARK: - 선택된 친구 이름
  /// UI에서 바로 쓸 수 있도록 Rx 상태
  Rxn<String> selectedName = Rxn<String>();

  // MARK: - 로딩 상태
  /// 서버 요청 중일 때 true
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    /// 검색어나 탭 변경 시 필터링 및 API 호출
    ever(searchQuery, (value) {
      if (selectedTabIdx.value == 0) {
        searchUserByZipCode(value);
      }
    });

    /// 선택 인덱스 변경 시 selectedName 갱신
    ever(selectedIdx, (_) => _updateSelectedName());
  }

  // MARK: - 서버에서 사서함 번호로 유저 검색
  /// zipCode(우편번호 5자리)를 입력하면, 서버에서 유저를 조회합니다.
  Future<void> searchUserByZipCode(String zipCode) async {
    if (zipCode.isEmpty) {
      filteredFriends.clear();
      return;
    }

    try {
      isLoading.value = true;

      /// UserService 호출 → 결과 반환
      final result = await UserService.searchByZipCode(zipCode);

      /// 결과가 있을 경우 리스트에 추가
      if (result != null && result['nickname'] != null) {
        filteredFriends.assignAll([
          {
            'name': result['nickname'] ?? '닉네임 없음',
            'number': zipCode,
            'id': result['id'].toString(),
          }
        ]);
      } else {
        filteredFriends.clear();
      }
    } catch (e) {
      print('사서함(우편번호) 검색 에러: $e');
      filteredFriends.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // MARK: - 선택된 친구 이름 갱신
  void _updateSelectedName() {
    final idx = selectedIdx.value;
    if (idx != null && idx < filteredFriends.length) {
      selectedName.value = filteredFriends[idx]['name'];
    } else {
      selectedName.value = null;
    }
  }

  // MARK: - 친구 선택
  void selectFriend(int? index) {
    selectedIdx.value = index;
  }

  // MARK: - 선택된 친구 반환
  Map<String, String>? getSelectedFriend() {
    final idx = selectedIdx.value;
    if (idx != null && idx < filteredFriends.length) {
      return filteredFriends[idx];
    }
    return null;
  }
}
