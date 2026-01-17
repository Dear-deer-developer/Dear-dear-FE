import 'package:dear_deer_demo/model/deardeer_gift.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:get/get.dart';

enum GiftTab {
  ornament, // 오너먼트
  star, // 별
  light, // 전구 (조명)
  wall, // 벽 소품
  floor, // 바닥
}

extension GiftTabExt on GiftTab {
  String get labelKo {
    switch (this) {
      case GiftTab.ornament:
        return '오너먼트';
      case GiftTab.star:
        return '별';
      case GiftTab.light:
        return '전구';
      case GiftTab.wall:
        return '벽 소품';
      case GiftTab.floor:
        return '바닥';
    }
  }
}

class GiftController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // 탭 순서
  final List<GiftTab> tabs = const [
    GiftTab.ornament,
    GiftTab.star,
    GiftTab.light,
    GiftTab.wall,
    GiftTab.floor,
  ];

  // 상태
  final RxInt selectedTabIndex = 0.obs;
  final RxList<DeardeerGift> items = <DeardeerGift>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  GiftTab get selectedTab => tabs[selectedTabIndex.value];

  @override
  void onInit() {
    super.onInit();
    _loadSelected(); // 첫 로딩
  }

  void selectTab(int index) {
    if (index == selectedTabIndex.value) return;
    if (index < 0 || index >= tabs.length) return;
    selectedTabIndex.value = index;
    _loadSelected();
  }

  /// force는 지금 API 캐시를 쓰는 구조가 아니면 의미가 크진 않지만,
  /// "캘린더 → 선물함 도착 확인" 같은 흐름에서 명시적으로 호출하려고 유지.
  Future<void> refreshSelected({bool force = true}) =>
      _loadSelected(force: force);

  /// 캘린더 reward로 받은 선물이 선물함(items)에 "도착"했는지 확인
  /// - giftId 있으면 id로 우선 매칭
  /// - giftId 없으면 giftName으로 차선 매칭
  bool hasGiftInBox({int? giftId, String? giftName}) {
    if (giftId != null) {
      return items.any((g) => g.id == giftId);
    }
    final name = (giftName ?? '').trim();
    if (name.isNotEmpty) {
      return items.any((g) => g.name.trim() == name);
    }
    return false;
  }

  /// UI 탭을 서버 카테고리 묶음으로 매핑
  List<GiftCategory> _tabToCategories(GiftTab tab) {
    switch (tab) {
      case GiftTab.ornament:
        return [GiftCategory.ornament];
      case GiftTab.star:
        return [GiftCategory.star];
      case GiftTab.light:
        // 전구 탭 = electric + bulb
        return [GiftCategory.electric, GiftCategory.bulb];
      case GiftTab.wall:
        // 벽 소품 = interior (가랜드, 벽 장식 등)
        return [GiftCategory.interior];
      case GiftTab.floor:
        // 바닥 = animal (강아지, 고양이 등)
        return [GiftCategory.animal];
    }
  }

  Future<void> _loadSelected({bool force = false}) async {
    final prevCount = items.length;

    isLoading.value = true;
    error.value = null;

    try {
      final tab = selectedTab;
      final catList = _tabToCategories(tab);

      logger.d('🎁 탭 선택: ${tab.labelKo}, 카테고리: $catList (force=$force)');

      final List<DeardeerGift> all = [];

      // 탭 → 여러 카테고리면 반복해서 호출
      for (final cat in catList) {
        final serverName = giftCategoryToServer(cat);
        logger.d('🎁 카테고리 요청: $serverName');

        // ✅ ApiService의 getJson 사용 (baseUrl + JWT + 401 처리)
        final json = await _api.getJson('/gifts/category/$serverName');

        if (json is List) {
          logger.i(
              '🎁 응답 수신: tab=${tab.labelKo}, cat=$serverName, count=${json.length}');

          // ✅ 파싱
          final parsed = json
              .map((e) => DeardeerGift.fromJson(e as Map<String, dynamic>))
              .toList();

          // ✅ "새 선물"만 로그 (isNew=true)
          final newOnes = parsed.where((g) => g.isNew).toList();
          if (newOnes.isNotEmpty) {
            logger.i(
                '🆕 새 선물 발견: tab=${tab.labelKo}, cat=$serverName, newCount=${newOnes.length}');
            for (final g in newOnes) {
              logger.i(
                '🆕 id=${g.id}, name=${g.name}, category=${giftCategoryToServer(g.category)}, imageUrl=${g.imageUrl}',
              );
            }
          }

          // ✅ 샘플 로그(최대 3개) - 필요 없으면 지워도 됨
          for (final g in parsed.take(3)) {
            logger.d(
              '🎁 sample: id=${g.id}, name=${g.name}, category=${giftCategoryToServer(g.category)}, isNew=${g.isNew}',
            );
          }

          all.addAll(parsed);
        } else {
          logger.w('⚠️ 응답이 List가 아님: $json');
        }
      }

      items.assignAll(all);

      logger.i('✅ items 반영 완료: tab=${tab.labelKo}, total=${items.length}');

      final diff = items.length - prevCount;
      if (diff > 0) {
        logger.i('📦 선물함 아이템 증가: +$diff (tab=${tab.labelKo})');
      } else {
        logger.d('📦 선물함 아이템 변동 없음 (tab=${tab.labelKo})');
      }
    } catch (err) {
      error.value = '네트워크 오류: $err';
      items.clear();
      logger.e('❌ 네트워크 오류: $err');
    } finally {
      isLoading.value = false;
    }
  }
}
