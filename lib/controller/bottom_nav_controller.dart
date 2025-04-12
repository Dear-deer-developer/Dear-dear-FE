import 'package:dear_deer_demo/controller/calendar/calendar_controller.dart';
import 'package:dear_deer_demo/controller/contents/contents_controller.dart';
import 'package:dear_deer_demo/controller/home/home_controller.dart';
import 'package:dear_deer_demo/controller/post/post_controller.dart';
import 'package:dear_deer_demo/main.dart';
import 'package:get/get.dart';

// Page 구분 enum
enum Page { home, post, calendar, contents }

class BottomNavController extends GetxController {
  // 초기 index 값 0 -> home
  final RxInt _pageIndex = 0.obs;
  // 페이지 이동 이력 히스토리, 뒤로가기 로직에 사용
  final List<int> _history = [0];

  // index getter
  int get index => _pageIndex.value;

  // MARK: - 페이지 이동 & 스크롤 업 처리
  void changeIndex(int pageIndex) {
    var page = Page.values[pageIndex];
    try {
      if (pageIndex == _pageIndex.value) {
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
          case Page.contents:
            Get.find<ContentsController>().scrollUp();
            break;
        }
      }
    } catch (e) {
      logger.e('Scroll up failed: $e');
    }
    _moveToPage(pageIndex);
  }

  // MARK: - 페이지 이동 함수
  void _moveToPage(int value) {
    if (_history.last != value) {
      _history.add(value);
      logger.i(_history.toString());
    }
    _pageIndex(value);
  }

  // MARK: - 뒤로가기
  Future<bool> popAction() async {
    //뒤로가기 두 번 해야 종료
    if (_history.length == 1) {
      return true;
    } else {
      _history.removeLast();
      changeIndex(_history.last);
      return false;
    }
  }
}
