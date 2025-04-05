import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/calendar_controller.dart';
import 'calendar_bottom_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int selectedYear = 2025;
  int selectedMonth = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$selectedYear년 $selectedMonth월"),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () => _showDatePicker(context),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildWeekDays(),
          Obx(() => _buildCalendar()), // 날짜 변경 시 자동 업데이트
        ],
      ),
    );
  }

  // 요일 표시
  Widget _buildWeekDays() {
    List<String> weekDays = ["일", "월", "화", "수", "목", "금", "토"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ))
          .toList(),
    );
  }

  // 달력 UI 구성
  Widget _buildCalendar() {
    List<Widget> days = [];
    DateTime firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    int startWeekday = firstDayOfMonth.weekday % 7;

    DateTime today = DateTime.now();

    // 시작 요일 이전의 빈 칸 추가
    for (int i = 0; i < startWeekday; i++) {
      days.add(const Expanded(child: SizedBox()));
    }

    // 날짜 셀 생성
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDay = DateTime(selectedYear, selectedMonth, i);
      bool isToday = currentDay.year == today.year &&
          currentDay.month == today.month &&
          currentDay.day == today.day;

      final events = calendarController.getEventsForDate(currentDay);
      final hasEvent = events.isNotEmpty;
      final maxEventsToShow = 3;

      days.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showBottomSheet(currentDay);
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color.fromARGB(255, 192, 198, 255)
                    : null,
                border: hasEvent
                    ? Border.all(color: const Color.fromARGB(255, 50, 47, 255), width: 2)
                    : null,
                borderRadius: BorderRadius.circular(5),
              ),
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "$i",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...events.take(maxEventsToShow).map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          event.length > 8
                              ? "${event.substring(0, 8)}.."
                              : event,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (events.length > maxEventsToShow)
                    const Text(
                      "•..",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 마지막 줄 빈 칸 채우기
    while (days.length % 7 != 0) {
      days.add(const Expanded(child: SizedBox()));
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: _splitIntoWeeks(days),
      ),
    );
  }

  // 7일씩 묶어 한 주 단위로 표시
  List<Widget> _splitIntoWeeks(List<Widget> days) {
    List<Widget> weeks = [];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.sublist(i, i + 7),
      ));
    }
    return weeks;
  }

  // 연도/월 선택 다이얼로그
  void _showDatePicker(BuildContext context) {
    int tempYear = selectedYear;
    int tempMonth = selectedMonth;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButton<int>(
                        value: tempYear,
                        items: List.generate(
                          10,
                          (index) => DropdownMenuItem(
                            value: 2020 + index,
                            child: Text("${2020 + index}년"),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => tempYear = value);
                          }
                        },
                      );
                    },
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButton<int>(
                        value: tempMonth,
                        items: List.generate(
                          12,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text("${index + 1}월"),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => tempMonth = value);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedYear = tempYear;
                  selectedMonth = tempMonth;
                });
                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // 날짜 클릭 시 바텀시트 열기
  void _showBottomSheet(DateTime selectedDate) {
    Get.bottomSheet(
      CalendarBottomSheet(date: selectedDate),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }
}
