import 'package:get/get.dart';

class CustomCalenderController extends GetxController {
  // 현재 날짜를 저장합니다. (앱 실행 시점의 날짜)
  final DateTime now = DateTime.now();

  // 사용자가 선택한 첫 번째 날짜 (반응형 변수)
  final Rxn<DateTime> selectedDt1 = Rxn<DateTime>();

  // 사용자가 선택한 두 번째 날짜 (반응형 변수)
  final Rxn<DateTime> selectedDt2 = Rxn<DateTime>();
}
