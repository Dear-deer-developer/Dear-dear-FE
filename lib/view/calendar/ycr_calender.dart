import 'package:dear_deer_demo/view/calendar/ycr_event_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/controller/calender/ycr_calender_controller.dart';

class YcrCalendar extends StatefulWidget {
  @override
  State<YcrCalendar> createState() => _YcrCalendarState();
}

class _YcrCalendarState extends State<YcrCalendar> {
  final YcrCalenderController controller = Get.put(YcrCalenderController());

  final DateTime now = DateTime.now(); // 고정 값으로 두어 현재 날짜가 있는 달만 불러오게 설정

  final List<String> daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${now.year}년 ${now.month}월'),
      ),
      body: _schedule(),
    );
  }

  /// MARK: 캘린더 UI
  Widget _schedule() {
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    int daysInMonth = DateTime(now.year, now.month + 1, 0)
        .day; // 다음 달의 0 일이 이번 달의 마지막 날이기에, 30 일 31 일 구분 없이 0 으로 통일
    int firstWeekday = firstDayOfMonth.weekday % 7;
    int totalCells = firstWeekday + daysInMonth;

    return Column(
      children: [
        _buildDaysOfWeekHeader(),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            // index 의 앞이 빈 날이면 빈 칸을 출력, 빈 날이 아니라면 실제 날짜를 출력
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return Container();
              } else {
                int day = index - firstWeekday + 1;
                return _buildDayCard(context, day);
              }
            },
          ),
        ),
      ],
    );
  }

  // MARK: 요일
  Widget _buildDaysOfWeekHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: daysOfWeek
          .map((day) => Text(
                day,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ))
          .toList(),
    );
  }

  // MARK: 날짜
  Widget _buildDayCard(BuildContext context, int day) {
    return GestureDetector(
      onTap: () => _showBottomSheet(context, day),
      child: Card(
        elevation: 2,
        color: day == now.day ? Colors.pink : Colors.white,
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 16,
              color: day == now.day ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // MARK: 바텀 시트
  void _showBottomSheet(BuildContext context, int day) {
    // 선택한 날짜를 controller 에 업데이트 후 반응형 변수에 저장하여 디데이 계산
    final selected = DateTime(now.year, now.month, day);
    controller.updateSelectedDate(selected);
    controller.focusedDate.value = selected;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$day일',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Obx(() {
                  final daysToChristmas = controller.daysToChristmas.value;

                  return Row(
                    children: [
                      Text(
                        "D-$daysToChristmas일",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () => _showAddEventBottomSheet(context),
                          child: const Icon(
                            Icons.add_circle,
                            size: 20,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            // 선택된 날짜에서 일정 가져오기
            // 일젇이 없다면 텍스트 문구를 출력하고, 일정이 있다면 추가한 이벤트를 리스트로 출력
            // 일정을 클릭하게 된다면, 삭제 다이얼로그가 노출되면서 일정 삭제를 가능하게 유도
            Obx(() {
              final events =
                  controller.events[controller.selectedDate.value] ?? [];

              if (events.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 27, left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "일정이 없습니다.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(top: 27, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: events.map((event) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("삭제하시겠습니까?"),
                            content: Text("\"$event\" 일정을 삭제할까요?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context), // 취소
                                child: const Text("취소"),
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.deleteEvent(
                                      controller.selectedDate.value, event);
                                  Navigator.pop(context); // 다이얼로그 닫기
                                  Get.back(); // 바텀시트 닫기
                                },
                                child: const Text(
                                  "삭제",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "$event",
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddEventBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => YcrEventBottomSheet(),
    );
  }
}
