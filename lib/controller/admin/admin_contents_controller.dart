import 'package:get/get.dart';

class AdminContentsController extends GetxController {
  // MARK: 상단 탭
  /// 콘텐츠 추천, 행사 알림, 스크랩 탭을 포함하는 인덱스입니다.
  /// 각 탭은 selectedIndex를 통해 관리됩니다.
  RxInt selectedIndex = 0.obs;

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  // MARK: 주제 선택
  /// 클릭 시 해당 탭의 테두리가 메인 레드 컬러로 변경되며, 선택되지 않은 탭은 여전히 회색 테두리를 유지합니다.
  /// 각 탭은 AdminContentsController의 selectedSubjectIndex를 통해 관리됩니다.
  /// 각 탭의 리스트는 뷰 파일에서 정의되며, 컨트롤러는 선택된 인덱스만 관리합니다.
  RxInt selectedSubjectIndex = 0.obs;

  void selectSubject(int index) {
    selectedSubjectIndex.value = index;
  }

  /// 뷰가 바뀔 때 주제 선택 인덱스를 초기화할 때 사용합니다.
  void resetSubject() {
    selectedSubjectIndex.value = 0;
  }
}
