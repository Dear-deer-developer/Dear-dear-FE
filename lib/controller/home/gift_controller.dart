import 'dart:convert';

import 'package:dear_deer_demo/model/deardeer_gift.dart';
import 'package:dear_deer_demo/service/api_service.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:get/get.dart';

class GiftController extends GetxController {
  // 탭 순서
  final List<GiftCategory> categories = const [
    GiftCategory.ornament,
    GiftCategory.star,
    GiftCategory.electric,
    GiftCategory.bulb,
    GiftCategory.interior,
    GiftCategory.animal,
  ];

  // 상태
  final RxInt selectedCategoryIndex = 0.obs;
  final RxList<DeardeerGift> items = <DeardeerGift>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  GiftCategory get selectedCategory => categories[selectedCategoryIndex.value];

  @override
  void onInit() {
    super.onInit();
    _loadSelected(); // 첫 로딩
  }

  void selectCategory(int index) {
    if (index == selectedCategoryIndex.value) return;
    if (index < 0 || index >= categories.length) return;
    selectedCategoryIndex.value = index;
    _loadSelected();
  }

  Future<void> refreshSelected() => _loadSelected(force: true);

  Future<void> _loadSelected({bool force = false}) async {
    isLoading.value = true;
    error.value = null;

    try {
      final cat = selectedCategory;
      logger.d('🎁 카테고리 요청: ${giftCategoryToServer(cat)}');

      final res = await ApiService()
          .get('/gifts/category/${giftCategoryToServer(cat)}');

      if (res.statusCode == 200 && res.bodyString != null) {
        final List list = jsonDecode(res.bodyString!);
        final parsed = list
            .map((e) => DeardeerGift.fromJson(e as Map<String, dynamic>))
            .toList();

        items.assignAll(parsed);
        logger.i('${parsed.length}개 아이템 로딩 완료 (${cat.name})');
      } else {
        error.value = '서버 오류: ${res.statusCode}';
        items.clear();
        logger.w('⚠️ 서버 오류 - code: ${res.statusCode}');
      }
    } catch (err) {
      error.value = '네트워크 오류: $err';
      items.clear();
      logger.e('❌ 네트워크 오류');
    } finally {
      isLoading.value = false;
    }
  }
}
