import 'package:dear_deer_demo/controller/calendar/calendar_controller.dart';
import 'package:dear_deer_demo/controller/contents/contents_controller.dart';
import 'package:dear_deer_demo/controller/home/home_controller.dart';
import 'package:dear_deer_demo/controller/post/post_controller.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:get/get.dart';

// Page 구분 enum
enum Page { home, post, calendar }

class BottomNavController extends GetxController {
  // 초기 index 값 0 -> home
  final RxInt _pageIndex = 0.obs;
  // 페이지 이동 이력 히스토리, 뒤로가기 로직에 사용
  final List<int> _history = [0];

  // index getter
  int get index => _pageIndex.value;
  // 현재 페이지(열거형) 게터
  Page get currentPage => Page.values[_pageIndex.value];

  // 인덱스 스트림 (탭 변경을 구독하기 위함)
  RxInt get rxIndex => _pageIndex;
  // Page로 직접 이동하는 헬퍼
  void goTo(Page page) => changeIndex(page.index);

  // MARK: - (탭 버튼 동작) 페이지 이동 & 스크롤 업 처리
  void changeIndex(int pageIndex) {
    // 방어 코드
    if (pageIndex < 0 || pageIndex >= Page.values.length) {
      logger.e('Invalid pageIndex: $pageIndex');
      return;
    }

    final page = Page.values[pageIndex];
    try {
      if (pageIndex == _pageIndex.value) {
        // 같은 탭 재클릭 → 해당 화면 스크롤업
        switch (page) {
          case Page.home:
            Get.find<HomeController>().scrollUp();
            break;
          case Page.post:
            Get.find<PostController>().scrollUp();
            break;
          case Page.calendar:
            Get.find<CalendarController>().scrollUp();
            break;
          // case Page.contents:
          //   Get.find<ContentsController>().scrollUp();
          //   break;
        }
      }
    } catch (e) {
      logger.e('Scroll up failed: $e');
    }
    _moveToPage(pageIndex);
  }

  // // MARK: - (프로그램적 전환) 스크롤업 없이 해당 탭으로 이동
  // void goTo(Page page) => _moveToPage(page.index);

  // // 필요하면 인덱스로도 호출 가능
  // void goToIndex(int value) => _moveToPage(value);

  // MARK: - 내부 공통 이동 로직
  void _moveToPage(int value) {
    if (_history.last != value) {
      _history.add(value);
      logger.i(_history.toString());
    }
    _pageIndex(value);
  }

  // MARK: - 뒤로가기
  Future<bool> popAction() async {
    // 뒤로가기 두 번 해야 종료
    if (_history.length == 1) {
      return true;
    } else {
      _history.removeLast();
      changeIndex(_history.last);
      return false;
    }
  }

  // MARK: - 회원가입 완료 후 홈으로 초기화
  void resetToHome() {
    _history
      ..clear()
      ..add(0);
    _pageIndex(0);
  }
}
