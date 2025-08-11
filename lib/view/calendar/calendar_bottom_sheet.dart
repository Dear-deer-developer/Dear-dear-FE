import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/test_calendar/cse/calendar_controller.dart';

final calendarController = Get.find<CalendarController>();

class CalendarBottomSheet extends StatelessWidget {
  final DateTime date;

  const CalendarBottomSheet({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷
    final String formattedDate = DateFormat('dd.').format(date);
    final String weekDay = DateFormat('E', 'ko').format(date); // 요일
    final Duration dDay = DateTime(date.year, 12, 25).difference(date);
    final int dDayCount = dDay.inDays;

    return FractionallySizedBox(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 바텀시트 상단 핸들바
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 날짜 & D-Day
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$formattedDate $weekDay",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "🎄D-Day ${dDayCount >= 0 ? dDayCount : 0}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 일정 목록
            Obx(() {
              final events = calendarController.getEventsForDate(date);
              if (events.isEmpty) {
                return const Text(
                  "등록된 일정이 없습니다.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: events
                    .map((e) => Dismissible(
                          key: Key(e),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.redAccent,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            calendarController.deleteEvent(date, e);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "✔️$e",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ))
                    .toList(),
              );
            }),

            const Spacer(),

            // 일정 추가 버튼
            ElevatedButton(
              onPressed: () => _showAddEventDialog(context, date),
              child: const Text("일정 추가"),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 일정 추가 다이얼로그
  void _showAddEventDialog(BuildContext context, DateTime date) {
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("일정 추가"),
        content: TextField(
          controller: eventController,
          decoration: const InputDecoration(labelText: "일정 내용"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              final event = eventController.text.trim();
              if (event.isNotEmpty) {
                calendarController.addEvent(date, event);
              }
              Navigator.pop(context);
            },
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }
}
