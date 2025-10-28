import 'dart:async';
import 'package:get/get.dart';
import 'package:dear_deer_demo/model/content_item.dart';
// import 'package:dear_deer_demo/service/api_service.dart'; // 추후 사용

/// 콘텐츠 목록을 가져오는 저장소 레이어.
/// 현재는 더미(mock) 데이터를 반환하고, 추후 API로 자연스럽게 교체 가능.
class ContentsRepository extends GetxService {
  ContentsRepository();

  /// 모드 스위치: false 로 바꾸면 나중에 API 모드로 즉시 전환 가능
  bool useMock = true;

  Future<List<ContentItem>> fetch({
    required String mainTabLabel,
    required String filterLabel,
    required int page,
    required int size,
  }) async {
    if (useMock) {
      return _fetchMock(
        mainTabLabel: mainTabLabel,
        filterLabel: filterLabel,
        page: page,
        size: size,
      );
    } else {
      return _fetchRemote(
        mainTabLabel: mainTabLabel,
        filterLabel: filterLabel,
        page: page,
        size: size,
      );
    }
  }

  // ===== MOCK =====
  Future<List<ContentItem>> _fetchMock({
    required String mainTabLabel,
    required String filterLabel,
    required int page,
    required int size,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.generate(size, (i) {
      final seed = (page - 1) * size + i;
      return ContentItem(
        id: 'c-$seed-$mainTabLabel-$filterLabel',
        title: '올해 크리스마스, 영화가 "메리 크리스마스" 인사해 줄 거예요!',
        subtitle: '🎄 올해 크리스마스, 영화가 "메리 크리스마스"...',
        author: '쥬니쥬니 에디터',
        views: 13000 + seed * 17,
        scraps: 100000 + seed * 31,
        thumbnailUrl: 'https://picsum.photos/seed/$seed/600/400',
      );
    });
  }

  // ===== REMOTE (예시) =====
  Future<List<ContentItem>> _fetchRemote({
    required String mainTabLabel,
    required String filterLabel,
    required int page,
    required int size,
  }) async {
    // TODO: ApiService로 실제 서버 연동
    // final api = Get.find<ApiService>();
    // final res = await api.get('/contents', query: {
    //   'mainTab': mainTabLabel,
    //   'filter': filterLabel,
    //   'page': page,
    //   'size': size,
    // });
    // if (res.statusCode != 200) { throw Exception('fetch failed'); }
    // final data = res.body; // 스펙에 따라 파싱
    // final List list = data['items'] as List;
    // return list.map((e) => ContentItem.fromJson(e)).toList();

    // 당장은 목업 유지
    return _fetchMock(
      mainTabLabel: mainTabLabel,
      filterLabel: filterLabel,
      page: page,
      size: size,
    );
  }
}
