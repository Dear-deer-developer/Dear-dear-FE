import 'package:dear_deer_demo/controller/custom_calender_controller.dart';
import 'package:dear_deer_demo/view/calender_test.dart/date_registration_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomCalender extends StatefulWidget {
  const CustomCalender({super.key});

  @override
  State<CustomCalender> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalender> {
  // GetX를 통해 등록된 CustomCalenderController 인스턴스를 가져옴
  final CustomCalenderController controller =
      Get.find<CustomCalenderController>();

  // PageView를 위한 PageController 선언
  late PageController _pageController;
  // 현재 달을 초기 페이지로 설정 (달은 1부터 시작하므로 -1)
  int initialPage = 0;
  // 초기 날짜를 오늘로 설정하며, 하루의 시각은 1일 00:00:00으로 초기화
  DateTime initDate = DateTime.now().copyWith(
      day: 1, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  @override
  void initState() {
    super.initState();
    initialPage = controller.now.month - 1;
    // PageController를 현재 달의 인덱스로 초기화
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 전체 화면 높이를 가져와서 PageView의 높이로 사용 (또는 원하는 고정값 사용)
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 120, // 총 페이지 갯수 ( 120개 == 120개월 -> 10년)
        itemBuilder: (context, index) {
          DateTime pageDate =
              DateTime(initDate.year, initDate.month + (index - initialPage));
          return _CalendarItem(pageDate);
        },
      ),
    );
  }
}

// _CalendarItem: 하나의 달(월) 캘린더 페이지를 구성하는 위젯
class _CalendarItem extends StatelessWidget {
  final DateTime date;
  List<_CustomRow> rows = [];

  // 생성자: 전달받은 날짜를 기준으로 캘린더 레이아웃(행)을 구성
  _CalendarItem(this.date) {
    // 요일 이름 리스트: 일, 월, 화, 수, 목, 금, 토
    List<String> str = ['일', '월', '화', '수', '목', '금', '토'];
    // 요일 이름들을 Center 위젯으로 감싸고 _CustomRow에 추가 (텍스트 스타일은 기본값, 색상만 Colors.black)
    rows.add(_CustomRow(List.generate(
        str.length,
        (index) => Center(
                child: Text(
              str[index],
              style: const TextStyle(color: Colors.black),
            )))));

    // DateTime.weekday의 순서와 맞추기 위한 요일 순서 재정렬
    List<int> weeks = [7, 1, 2, 3, 4, 5, 6];
    // 해당 달의 마지막 날짜 계산 (12월인 경우 다음 해 1월 0일 사용)
    int endDay = date.month < 12
        ? DateTime(date.year, date.month + 1, 0).day
        : DateTime(date.year + 1, 1, 0).day;
    int currentDay = 1;
    // 해당 달의 모든 날짜를 한 주씩 구성
    while (currentDay <= endDay) {
      List<Widget> list = [];
      // 한 주(7일) 구성
      for (int i = 0; i < 7; i++) {
        DateTime currentDate = date.copyWith(day: currentDay);
        if (currentDay > endDay) {
          // 마지막 날 이후는 빈 칸 위젯(_BlankDay) 추가
          list.add(_BlankDay(date.copyWith(day: endDay)));
        } else if (currentDate.weekday != weeks[i]) {
          // 해당 요일이 아니면 빈 칸 위젯 추가
          list.add(_BlankDay(date.copyWith(day: 1)));
        } else {
          // 일치하면 날짜 위젯(_DayWidget) 추가 후 currentDay 증가
          list.add(_DayWidget(currentDate));
          currentDay++;
        }
      }
      // 한 주를 _CustomRow로 감싸서 rows에 추가
      rows.add(_CustomRow(list));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단에 연도와 월을 표시하는 Row
        Center(
          child: Center(
            child: Text(
              '${date.year}년 ${date.month}월',
              style: TextStyle(color: Colors.black, fontSize: 25.sp),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        // 구성된 행들을 모두 표시
        ...rows
      ],
    );
  }
}

// _CustomRow: 행(Row) 내의 위젯들을 균등하게 배치하는 위젯
class _CustomRow extends StatelessWidget {
  final List<Widget> items;

  const _CustomRow(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 부모 가로 길이를 7로 나누어 각 셀의 너비 계산
        final cellWidth = constraints.maxWidth / 7;
        return Row(
          children: items.map((widget) {
            return Padding(
              padding: EdgeInsets.only(bottom: 13.h),
              child: SizedBox(
                // 각 칸의 크기
                width: cellWidth,
                height: 55.h,
                child: widget,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// _BlankDay: 캘린더에서 날짜가 없는 빈 칸을 표시하는 위젯
class _BlankDay extends GetView<CustomCalenderController> {
  final DateTime date;

  const _BlankDay(this.date);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 두 날짜(selectedDt1, selectedDt2)가 모두 선택되었는지 확인
      bool selectedCompletely = controller.selectedDt1.value != null &&
          controller.selectedDt2.value != null;
      if (!selectedCompletely) {
        return const SizedBox();
      }
      DateTime later = controller.selectedDt1.value!;
      DateTime earlier = controller.selectedDt2.value!;

      if (later.month == earlier.month) {
        return const SizedBox();
      }

      if (later.isBefore(controller.selectedDt2.value!)) {
        later = controller.selectedDt2.value!;
        earlier = controller.selectedDt1.value!;
      }

      // 날짜(day)가 20보다 작으면 앞쪽, 20 이상이면 뒤쪽으로 간주하여 범위에 포함되면 색상 처리
      if (date.day < 20) {
        if (earlier.isBefore(date) &&
            (later.isAfter(date) || later.isAtSameMomentAs(date))) {
          return Container(
              height: 26.h,
              decoration: const BoxDecoration(color: Colors.black));
        }
      } else {
        if (later.isAfter(date) &&
            (earlier.isBefore(date) || earlier.isAtSameMomentAs(date))) {
          return Container(
              height: 26.h,
              decoration: const BoxDecoration(color: Colors.black));
        }
      }
      return const SizedBox();
    });
  }
}

// MARK: - _DayWidget: 실제 날짜를 표시하고 터치 이벤트를 통해 날짜 선택/해제 로직을 처리하는 위젯
class _DayWidget extends GetView<CustomCalenderController> {
  final DateTime date;

  const _DayWidget(this.date);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 컨트롤러의 현재 날짜 (오늘)와 비교하기 위해 오늘 날짜의 연,월,일만 추출합니다.
      final today = DateTime(
          controller.now.year, controller.now.month, controller.now.day);
      final currentDate = DateTime(date.year, date.month, date.day);

      // 기본 텍스트 색상은 Colors.black로 설정합니다.
      Color textColor = Colors.black;

      // 만약 현재 날짜가 오늘이라면 무조건 검정색을 사용합니다.
      if (today == currentDate) {
        textColor = Colors.purple;
      } else {
        // 오늘 날짜가 아니라면 기존 로직에 따라 활성화 여부, 요일 등으로 색상 결정
        bool isEnabled = controller.now.isBefore(date);
        if (!isEnabled) {
          textColor = Colors.black; // 필요에 따라 비활성화된 경우 다른 색상을 사용할 수 있습니다.
        } else {
          // 예시: 토요일이면 파란색, 일요일이면 빨간색, 그 외에는 검정색
          if (date.weekday == 6) {
            textColor = Colors.blue;
          } else if (date.weekday == 7) {
            textColor = Colors.red;
          } else {
            textColor = Colors.black;
          }
        }
      }

      bool selectedCompletely = controller.selectedDt1.value != null &&
          controller.selectedDt2.value != null;
      bool selected = controller.selectedDt1.value == date ||
          controller.selectedDt2.value == date;
      bool isContained = false;
      if (selectedCompletely) {
        DateTime later = controller.selectedDt1.value!;
        DateTime earlier = controller.selectedDt2.value!;
        if (later.isBefore(controller.selectedDt2.value!)) {
          later = controller.selectedDt2.value!;
          earlier = controller.selectedDt1.value!;
        }
        if (earlier.isBefore(date) && date.isBefore(later)) {
          isContained = true;
        }
      }

      bool amILater = false;
      if (selected) {
        // 선택된 경우에도 오늘 날짜는 무조건 검정색을 유지합니다.
        if (!((date.year == today.year) &&
            (date.month == today.month) &&
            (date.day == today.day))) {
          if (selectedCompletely) {
            if (controller.selectedDt1.value == date) {
              amILater = controller.selectedDt2.value!.isBefore(date);
            } else {
              amILater = controller.selectedDt1.value!.isBefore(date);
            }
          }
        }
      }

      return GestureDetector(
          onTap: () {
            if (!controller.now.isBefore(date)) return;
            // 기존 날짜 선택/해제 로직 - 선택 상태 업데이트
            if (controller.selectedDt1.value == null) {
              controller.selectedDt1.value = date;
            } else if (controller.selectedDt1.value == date) {
              // 이미 선택된 경우 아무 동작 없음
            } else if (controller.selectedDt2.value == null) {
              controller.selectedDt2.value = date;
            } else if (controller.selectedDt1.value == date) {
              controller.selectedDt1.value = null;
            } else if (controller.selectedDt2.value == date) {
              controller.selectedDt2.value = null;
            } else {
              controller.selectedDt1.value = date;
              controller.selectedDt2.value = null;
            }

            // === 새로 추가된 오버레이 호출 부분 ===
            // 날짜 칸을 선택하면 등록 페이지 오버레이를 띄웁니다.
            // 이 오버레이는 별도의 위젯(DateRegistrationPage)로 작성되어 있으며,
            // Get.dialog를 이용해 모달 형태로 화면 위에 표시됩니다.
            Get.dialog(
              DateRegistrationOverlay(date: date), // 선택된 날짜를 인자로 전달
              barrierColor: Colors.black.withOpacity(0.5), // 배경 어둡게 처리
              transitionDuration:
                  const Duration(milliseconds: 300), // 전환 애니메이션 설정
            );
          },
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            height: 40,
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 선택된 날짜 범위에 포함되면 배경색 처리
                Positioned(
                    left: 0,
                    right: 0,
                    child: Visibility(
                        visible: isContained,
                        child: Container(
                            height: 36,
                            decoration:
                                const BoxDecoration(color: Colors.yellow)))),
                // 후순위 선택 날짜의 경우 좌우에 배경 표시
                Positioned(
                    left: amILater ? 0 : null,
                    right: amILater ? null : 0,
                    child: Visibility(
                        visible: selected && selectedCompletely,
                        child: Container(
                            height: 36,
                            width: 26,
                            decoration:
                                const BoxDecoration(color: Colors.black)))),
                // 선택된 날짜이면 원형 배경 표시
                Visibility(
                    visible: selected,
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle))),
                // 날짜 텍스트 (오늘 날짜는 무조건 검정색으로 표시)
                Text('${date.day}', style: TextStyle(color: textColor))
              ],
            ),
          ));
    });
  }
}
