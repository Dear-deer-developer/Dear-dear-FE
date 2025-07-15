import 'package:get/get.dart';

class ContentsRecommandController extends GetxController {
  // 중간 탭 ("콘텐츠 추천", "행사 알림", "스크랩") 관련
  RxInt selectedIndex = 0.obs;

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  // subject 탭 ("전체 보기", "영화 드라마", "음악", "카페") 관련
  RxInt selectedSubjectIndex = 0.obs;

  final List<String> subjects = [
    '전체 보기',
    '영화 드라마',
    '음악',
    '카페',
  ];

  void selectSubject(int index) {
    selectedSubjectIndex.value = index;
  }
}
