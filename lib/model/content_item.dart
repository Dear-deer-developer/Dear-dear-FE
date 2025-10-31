// 상위 카테고리
enum MainTab { contents, event, bookmark }

// 하위 카테고리 (아이템이 실제로 가지는 값) — 전체보기 없음!
class Subtype {
  // 콘텐츠 추천
  static const movieDrama = '영화 · 드라마';
  static const music = '음악';
  static const cafe = '카페';

  // 행사 알림
  static const ticket = '티켓팅 & 예약';
  static const popup = '팝업';
  static const festival = '축제';
}

// UI 필터 키 (화면에서 쓰는 선택지) — 여기엔 전체보기(2종) 포함
class FilterKey {
  // 콘텐츠 추천 탭에서의 전체보기
  static const contentsAll = '전체보기(콘텐츠)';
  // 행사 알림 탭에서의 전체보기
  static const eventAll = '전체보기(행사)';

  // 개별 하위분류 (라벨 재사용)
  static const movieDrama = Subtype.movieDrama;
  static const music = Subtype.music;
  static const cafe = Subtype.cafe;
  static const ticket = Subtype.ticket;
  static const popup = Subtype.popup;
  static const festival = Subtype.festival;
}

// 아이템 모델 (전체보기는 절대 들어가지 않음)
class ContentItem {
  final String id;
  final String title;
  final MainTab origin; // 상위 카테고리 출처
  final String subtype; // 하위 카테고리 (위 Subtype 중 하나)
  bool isFavorite;

  // 선택: 기존 예시 호환 필드
  final String? subtitle;
  final String? author;
  final String? thumbnailUrl;
  final int? views;
  final int? scraps;

  ContentItem({
    required this.id,
    required this.title,
    required this.origin,
    required this.subtype,
    this.isFavorite = false,
    this.subtitle,
    this.author,
    this.thumbnailUrl,
    this.views,
    this.scraps,
  });

  ContentItem copyWith({
    bool? isFavorite,
    String? title,
    String? subtitle,
    String? author,
    String? thumbnailUrl,
    int? views,
    int? scraps,
  }) {
    return ContentItem(
      id: id,
      title: title ?? this.title,
      origin: origin,
      subtype: subtype, // 전체보기는 저장하지 않음
      isFavorite: isFavorite ?? this.isFavorite,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      views: views ?? this.views,
      scraps: scraps ?? this.scraps,
    );
  }
}
