import 'package:get/get.dart';

/// 친구 선택 화면의 상태를 관리하는 컨트롤러입니다.
/// 친구 목록을 필터링, 탭 상태, 선택된 친구 인덱스를 관리합니다.
class SelectRecipientController extends GetxController {
  final Rxn<int> selectedIdx = Rxn<int>();

  /// 선택된 상단 탭 인덱스를 의미합니다.
  /// 0: 카카오 친구, 1: 사서함 번호, 2: 미가입자
  RxInt selectedTabIdx = 0.obs;

  /// 검색어를 의미합니다.
  final searchQuery = ''.obs;

  /// 친구 목록을 의미합니다.
  /// 현재 더미 데이터로 구성.
  final friends = List.generate(10, (index) {
    return {
      'name': '친구 이름 $index',
      'number': '0000-000$index',
      'nickname': '닉네임 $index',
    };
  }).obs;

  /// 필터링이 된 친구 목록이며, 검색 및 탭에 따라 변동됩니다.
  final filteredFriends = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();

    /// 초기 상태에는 전체 친구를 보여 줍니다.
    /// 검색어가 변경되거나 선택된 탭이 변경될 때마다 친구 목록을 필터링합니다.
    _filterFriends();
    ever(searchQuery, (_) => _filterFriends());
    ever(selectedTabIdx, (_) => _filterFriends());
  }

  /// 검색어와 탭에 따라 친구 목록을 필터링합니다.
  /// 미가입자 탭(2번) 에서는 친구 목록을 보여 주지 않습니다.
  /// 검색어가 비어 있을 경우, 전체 친구 목록을 노출합니다.
  /// 검색어가 있을 경우, 검색어가 포함된 친구들만 필터링합니다.

  void _filterFriends() {
    // 미가입자 탭일 경우 친구 목록 비우기
    if (selectedTabIdx.value == 2) {
      filteredFriends.clear();
      return;
    }

    // 검색어가 없으면 전체 친구 목록 보여줌
    if (searchQuery.value.isEmpty) {
      filteredFriends.assignAll(friends);
    } else {
      filteredFriends.assignAll(
        friends
            .where((friend) => friend['name']!
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
            .toList(),
      );
    }
  }

  void selectFriend(int? index) {
    selectedIdx.value = index;
  }

  /// 선택된 친구들 출력하고, 선택된 친구가 없는 경우 예외 메세지를 출력.
  void confirmSelection() {
    final idx = selectedIdx.value;
    if (idx != null && idx < filteredFriends.length) {
      print('선택된 친구: ${filteredFriends[idx]['name']}');
    } else {
      print('선택된 친구 없음');
    }
  }
}
