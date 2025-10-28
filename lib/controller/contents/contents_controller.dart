// lib/controller/contents/contents_controller.dart
import 'package:dear_deer_demo/model/content_item.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

enum MainCategory { recommend, event, bookmark }

class ContentsController extends GetxController {
  // ===== 스크롤 제어 (바텀네비 scrollUp에서 사용) =====
  final ScrollController scrollController = ScrollController();
  void scrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeIn,
    );
  }

  // ===== 탭/필터 상태 =====
  final Rx<MainCategory> mainCategory = MainCategory.recommend.obs;

  // 피그마 기준 4필터 (현재 하드코딩, 추후 관리자/Config로 교체 예정)
  static const List<String> _defaultFilters = ['전체보기', '티켓팅·예약', '팝업', '축제'];
  final RxInt filterIndex = 0.obs;

  List<String> get filters => _defaultFilters;

  // ===== 리스트/로딩/페이징 =====
  final RxList<ContentItem> items = <ContentItem>[].obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  bool hasMore = true;
  int _page = 1;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetch(reset: true);

    // 끝 근처에서 자동 더불러오기
    scrollController.addListener(() {
      if (!hasMore || isLoadingMore.value) return;
      final p = scrollController.position;
      if (p.pixels >= p.maxScrollExtent - 200) {
        fetch();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // ===== 이벤트 핸들러 =====
  void selectMainTab(int index) {
    final selected = MainCategory.values[index];
    if (selected == mainCategory.value) return;
    mainCategory.value = selected;
    filterIndex.value = 0;
    fetch(reset: true);
    scrollUp();
  }

  void selectFilter(int index) {
    if (index == filterIndex.value) return;
    filterIndex.value = index;
    fetch(reset: true);
    scrollUp();
  }

  // ===== 데이터 로드 (현재 더미, 추후 Repository로 치환) =====
  Future<void> fetch({bool reset = false}) async {
    if (reset) {
      isRefreshing.value = true;
      _page = 1;
      hasMore = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      // TODO: 나중에 API 연동 (mainCategory, filters[filterIndex], page, size)
      await Future.delayed(const Duration(milliseconds: 250));

      final list = List.generate(_pageSize, (i) {
        final seed = (_page - 1) * _pageSize + i;
        return ContentItem(
          id: 'c-$seed-${mainCategory.value.name}-${filters[filterIndex.value]}',
          title: '올해 크리스마스, 영화가 "메리 크리스마스" 인사해 줄 거예요!',
          subtitle: '🎄 올해 크리스마스, 영화가 "메리 크리스마스"...',
          author: '쥬니쥬니 에디터',
          views: 13000 + seed * 17,
          scraps: 100000 + seed * 31,
          thumbnailUrl: 'https://picsum.photos/seed/$seed/600/400',
        );
      });

      if (reset) {
        items.assignAll(list);
      } else {
        items.addAll(list);
      }

      _page++;
      hasMore = _page <= 5; // 더미 기준 5페이지까지만
    } finally {
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }
}
