// lib/repository/contents_repository.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:dear_deer_demo/model/content_item.dart';

/// 콘텐츠 목록을 가져오는 저장소 레이어.
/// 현재는 더미(mock) 데이터를 반환하고, 추후 API로 자연스럽게 교체 가능.
class ContentsRepository extends GetxService {
  ContentsRepository();

  /// 모드 스위치: false 로 바꾸면 나중에 API 모드로 즉시 전환 가능
  bool useMock = true;

  Future<List<ContentItem>> fetch({
    required MainTab mainTab, // ✅ enum으로 받도록 변경
    required String filterLabel,
    required int page,
    required int size,
  }) async {
    if (useMock) {
      return _fetchMock(
        mainTab: mainTab,
        filterLabel: filterLabel,
        page: page,
        size: size,
      );
    } else {
      return _fetchRemote(
        mainTab: mainTab,
        filterLabel: filterLabel,
        page: page,
        size: size,
      );
    }
  }

  // ===== MOCK =====
  Future<List<ContentItem>> _fetchMock({
    required MainTab mainTab,
    required String filterLabel,
    required int page,
    required int size,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return List.generate(size, (i) {
      final seed = (page - 1) * size + i;

      // 1) origin 결정
      final MainTab origin = () {
        if (mainTab == MainTab.contents) return MainTab.contents;
        if (mainTab == MainTab.event) return MainTab.event;
        // bookmark 탭
        if (filterLabel == '콘텐츠 추천') return MainTab.contents;
        if (filterLabel == '행사 알림') return MainTab.event;
        // 즐겨찾기 전체보기: 콘텐츠/행사 섞어서
        return seed.isEven ? MainTab.contents : MainTab.event;
      }();

      // 2) subtype 결정
      final String subtype = () {
        if (origin == MainTab.contents) {
          // 콘텐츠 추천 탭의 전체보기: 영화·드라마/음악/카페 풀
          if (mainTab == MainTab.contents && filterLabel == '전체보기') {
            const pool = [Subtype.movieDrama, Subtype.music, Subtype.cafe];
            return pool[seed % pool.length];
          }
          // 즐겨찾기-콘텐츠 추천 or 섞인 경우의 랜덤 픽
          if (mainTab == MainTab.bookmark &&
              (filterLabel == '전체보기' || filterLabel == '콘텐츠 추천')) {
            const pool = [Subtype.movieDrama, Subtype.music, Subtype.cafe];
            return pool[seed % pool.length];
          }
          // 특정 하위 필터 라벨을 그대로 매핑
          return _labelToSubtype(filterLabel) ?? Subtype.movieDrama;
        } else {
          // 행사 알림 탭의 전체보기: 티켓팅·예약/팝업/축제 풀
          if (mainTab == MainTab.event && filterLabel == '전체보기') {
            const pool = [Subtype.ticket, Subtype.popup, Subtype.festival];
            return pool[seed % pool.length];
          }
          // 즐겨찾기-행사 알림 or 섞인 경우의 랜덤 픽
          if (mainTab == MainTab.bookmark &&
              (filterLabel == '전체보기' || filterLabel == '행사 알림')) {
            const pool = [Subtype.ticket, Subtype.popup, Subtype.festival];
            return pool[seed % pool.length];
          }
          // 특정 하위 필터 라벨 매핑
          return _labelToSubtype(filterLabel) ?? Subtype.ticket;
        }
      }();

      // 3) 표시용 타이틀(디버깅/시각 확인용)
      final tabLabel = () {
        switch (mainTab) {
          case MainTab.contents:
            return '콘텐츠 추천';
          case MainTab.event:
            return '행사 알림';
          case MainTab.bookmark:
            return '즐겨찾기';
        }
      }();

      // 4) 더미 아이템 생성
      return ContentItem(
        id: 'c-$seed-${origin.name}-$subtype',
        title: '[$tabLabel][$subtype] 올해 크리스마스가 더 설레는 이유',
        origin: origin,
        subtype: subtype,
        isFavorite: mainTab == MainTab.bookmark, // 즐겨찾기 탭이면 true로 가정
        subtitle: '🎄 $tabLabel-$subtype 관련 추천/소식 모아보기',
        author: '쥬니쥬니 에디터',
        views: 13000 + seed * 17,
        scraps: 100000 + seed * 31,
        thumbnailUrl: 'https://picsum.photos/seed/$seed/600/400',
      );
    });
  }

  // ===== REMOTE (예시) =====
  Future<List<ContentItem>> _fetchRemote({
    required MainTab mainTab,
    required String filterLabel,
    required int page,
    required int size,
  }) async {
    // TODO: ApiService 연동 시 여기에 실제 호출 작성
    // final api = Get.find<ApiService>();
    // final res = await api.get('/contents', query: {
    //   'mainTab': mainTab.name,        // contents / event / bookmark
    //   'filter': filterLabel,          // '전체보기' or '영화 · 드라마' ...
    //   'page': page,
    //   'size': size,
    // });
    // if (res.statusCode != 200) throw Exception('fetch failed');
    // final List data = ...; // 파싱
    // return data.map((e) => ContentItem.fromJson(e)).toList();

    // 당장은 목업 유지
    return _fetchMock(
      mainTab: mainTab,
      filterLabel: filterLabel,
      page: page,
      size: size,
    );
  }

  // ===== 라벨 → Subtype 매핑 =====
  String? _labelToSubtype(String label) {
    // 콘텐츠 추천
    if (label == Subtype.movieDrama) return Subtype.movieDrama;
    if (label == Subtype.music) return Subtype.music;
    if (label == Subtype.cafe) return Subtype.cafe;

    // 행사 알림
    if (label == Subtype.ticket) return Subtype.ticket;
    if (label == Subtype.popup) return Subtype.popup;
    if (label == Subtype.festival) return Subtype.festival;

    // '전체보기' 등은 여기서 null 반환 (상위 로직에서 풀 포함 처리)
    return null;
  }
}
