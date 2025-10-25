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

  // MARK: - 친구 목록
  /// 서버에서 받아올 때는 이 부분만 교체하면 됨
  final friends = List.generate(10, (index) {
    return {
      'name': '친구 이름 $index',
      'number': '0000-000$index',
      'nickname': '닉네임 $index',
    };
  }).obs;

  // MARK: - 필터링된 친구 목록
  /// 검색어 및 탭에 따라 변동
  final filteredFriends = <Map<String, String>>[].obs;

  // MARK: - 선택된 친구 이름
  /// UI에서 바로 쓸 수 있도록 Rx 상태
  Rxn<String> selectedName = Rxn<String>();

  @override
  void onInit() {
    super.onInit();

    /// 초기에는 전체 친구 표시
    _filterFriends();

    /// 검색어나 탭 변경 시 필터링
    ever(searchQuery, (_) => _filterFriends());
    ever(selectedTabIdx, (_) => _filterFriends());

    /// 선택 인덱스 변경 시 selectedName 갱신
    ever(selectedIdx, (_) => _updateSelectedName());
  }

  // MARK: - 친구 목록 필터링
  void _filterFriends() {
    // 링크로 보내기 탭이면 친구 목록 비움
    if (selectedTabIdx.value == 1) {
      filteredFriends.clear();
      return;
    }

    // 검색어 없으면 전체
    if (searchQuery.value.isEmpty) {
      filteredFriends.assignAll(friends);
    } else {
      filteredFriends.assignAll(
        friends
            .where((friend) =>
                friend['number']!.contains(searchQuery.value)) // 사서함 번호 검색
            .toList(),
      );
    }

    // 선택 인덱스 초기화
    selectedIdx.value = null;
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

  Map<String, String>? getSelectedFriend() {
    final idx = selectedIdx.value;
    if (idx != null && idx < filteredFriends.length) {
      return filteredFriends[idx];
    }
    return null;
  }
}
