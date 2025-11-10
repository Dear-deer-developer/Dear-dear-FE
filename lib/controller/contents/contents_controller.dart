// 1) 맨 위의 enum 삭제 또는 주석 처리
// enum MainCategory { recommend, event, bookmark }

import 'package:dear_deer_demo/model/content_item.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

// 2) model 쪽 MainTab, Subtype 사용
class ContentsController extends GetxController {
  // ===== 스크롤 제어 =====
  final ScrollController scrollController = ScrollController();
  void scrollUp() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeIn);
  }

  // ===== 탭/필터 상태 =====
  // MainTab으로 통일
  final Rx<MainTab> mainCategory = MainTab.contents.obs;
  final RxInt filterIndex = 0.obs;

  // 탭별 필터 레이블
  static const List<String> _filtersContents = [
    '전체보기',
    '영화 · 드라마',
    '음악',
    '카페',
  ];
  static const List<String> _filtersEvent = [
    '전체보기',
    '티켓팅 & 예약',
    '팝업',
    '축제',
  ];
  static const List<String> _filtersBookmark = [
    '전체보기',
    '콘텐츠 추천',
    '행사 알림',
  ];

  List<String> get filters {
    switch (mainCategory.value) {
      case MainTab.contents:
        return _filtersContents;
      case MainTab.event:
        return _filtersEvent;
      case MainTab.bookmark:
        return _filtersBookmark;
    }
  }

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
    scrollController.addListener(() {
      if (!hasMore || isLoadingMore.value) return;
      final p = scrollController.position;
      if (p.pixels >= p.maxScrollExtent - 200) fetch();
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // ===== 이벤트 핸들러 =====
  void selectMainTab(int index) {
    final selected = MainTab.values[index];
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

  // ===== 데이터 로드(더미) =====
  Future<void> fetch({bool reset = false}) async {
    if (reset) {
      isRefreshing.value = true;
      _page = 1;
      hasMore = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 250));

      final tab = mainCategory.value;
      final currentFilter = filters[filterIndex.value];

      final list = List.generate(_pageSize, (i) {
        final seed = (_page - 1) * _pageSize + i;

        // origin 결정
        final MainTab origin = () {
          if (tab == MainTab.contents) return MainTab.contents;
          if (tab == MainTab.event) return MainTab.event;
          // bookmark
          if (currentFilter == '콘텐츠 추천') return MainTab.contents;
          if (currentFilter == '행사 알림') return MainTab.event;
          return seed.isEven ? MainTab.contents : MainTab.event;
        }();

        // subtype 결정
        final String subtype = () {
          if (origin == MainTab.contents) {
            if (tab == MainTab.contents && currentFilter == '전체보기') {
              const pool = [Subtype.movieDrama, Subtype.music, Subtype.cafe];
              return pool[seed % pool.length];
            }
            if (tab == MainTab.bookmark &&
                (currentFilter == '전체보기' || currentFilter == '콘텐츠 추천')) {
              const pool = [Subtype.movieDrama, Subtype.music, Subtype.cafe];
              return pool[seed % pool.length];
            }
            return _mapLabelToSubtype(currentFilter) ?? Subtype.movieDrama;
          } else {
            if (tab == MainTab.event && currentFilter == '전체보기') {
              const pool = [Subtype.ticket, Subtype.popup, Subtype.festival];
              return pool[seed % pool.length];
            }
            if (tab == MainTab.bookmark &&
                (currentFilter == '전체보기' || currentFilter == '행사 알림')) {
              const pool = [Subtype.ticket, Subtype.popup, Subtype.festival];
              return pool[seed % pool.length];
            }
            return _mapLabelToSubtype(currentFilter) ?? Subtype.ticket;
          }
        }();

        final tabLabel = () {
          switch (tab) {
            case MainTab.contents:
              return '콘텐츠 추천';
            case MainTab.event:
              return '행사 알림';
            case MainTab.bookmark:
              return '즐겨찾기';
          }
        }();

        return ContentItem(
          id: 'c-$seed-${origin.name}-$subtype',
          title: '[$tabLabel][$subtype] 올해 크리스마스가 더 설레는 이유',
          origin: origin,
          subtype: subtype,
          isFavorite: tab == MainTab.bookmark,
          subtitle: '🎄 $tabLabel-$subtype 관련 추천/소식 모아보기',
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
      hasMore = _page <= 5;
    } finally {
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  String _mapLabelToSubtype(String label) {
    if (label == Subtype.movieDrama) return Subtype.movieDrama;
    if (label == Subtype.music) return Subtype.music;
    if (label == Subtype.cafe) return Subtype.cafe;
    if (label == Subtype.ticket) return Subtype.ticket;
    if (label == Subtype.popup) return Subtype.popup;
    if (label == Subtype.festival) return Subtype.festival;
    return Subtype.movieDrama;
  }
}
