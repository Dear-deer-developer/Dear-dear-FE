import 'dart:convert';
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

  Future<void> refreshSelected() => _loadSelected(force: true);

  /// UI 탭을 서버 카테고리 묶음으로 매핑
  /// 현재 서버 enum 을 기준으로 예시 매핑
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
    isLoading.value = true;
    error.value = null;

    try {
      final tab = selectedTab;
      final catList = _tabToCategories(tab);

      logger.d('🎁 탭 선택: ${tab.labelKo}, 카테고리: $catList');

      final List<DeardeerGift> all = [];

      // 탭 → 여러 카테고리면 반복해서 호출
      for (final cat in catList) {
        final serverName = giftCategoryToServer(cat);
        logger.d('🎁 카테고리 요청: $serverName');

        // ✅ ApiService의 getJson 사용 (baseUrl + JWT + 401 처리)
        final json = await _api.getJson('/gifts/category/$serverName');

        if (json is List) {
          all.addAll(
            json
                .map((e) => DeardeerGift.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
        } else {
          logger.w('⚠️ 응답이 List가 아님: $json');
        }
      }

      items.assignAll(all);
      logger.i('${all.length}개 아이템 로딩 완료 (${tab.labelKo})');
    } catch (err) {
      error.value = '네트워크 오류: $err';
      items.clear();
      logger.e('❌ 네트워크 오류: $err');
    } finally {
      isLoading.value = false;
    }
  }
}
