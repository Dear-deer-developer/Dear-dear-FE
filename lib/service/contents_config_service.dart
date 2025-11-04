import 'package:get/get.dart';

/// 관리자 페이지에서 내려주는 “라벨/구성값”을 관리하는 서비스.
/// 지금은 하드코딩 → 나중에 API 연동시 assignAll 만 하면 UI 자동 반영된다.
class ContentsConfigService extends GetxService {
  /// 상단 3대 카테고리(탭) 라벨
  final RxList<String> mainTabs = <String>[
    '콘텐츠 추천',
    '행사 알림',
    '즐겨찾기',
  ].obs;

  /// 탭별 중간 필터 라벨
  final RxMap<String, List<String>> filtersByTab = <String, List<String>>{
    '콘텐츠 추천': ['전체보기', '티켓팅·예약', '팝업', '축제'],
    '행사 알림': ['전체보기', '티켓팅·예약', '팝업', '축제'],
    '즐겨찾기': ['전체보기', '티켓팅·예약', '팝업', '축제'],
  }.obs;

  /// 관리자 페이지 값 새로고침 (추후 API 연동부)
  Future<void> refreshFromRemote() async {
    // TODO: ApiService 붙이면 아래처럼 교체
    // final api = Get.find<ApiService>();
    // final res = await api.get('/admin/contents-config'); // 응답 스펙에 맞춰 파싱
    // mainTabs.assignAll(res.data['mainTabs'].cast<String>());
    // final Map<String, dynamic> m = res.data['filtersByTab'];
    // filtersByTab.assignAll(
    //   m.map((k, v) => MapEntry(k, (v as List).cast<String>())),
    // );
  }

  List<String> filtersOfTab(String tabLabel) =>
      filtersByTab[tabLabel] ?? const [];
}
