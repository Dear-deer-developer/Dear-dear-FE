import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/calendar/calendar_controller.dart';

// 기존 CalendarController를 쓰고 있지만, 현재 파일에서는 표시만 담당
final calendarController = Get.find<CalendarController>();

class CalendarBottomSheet extends StatelessWidget {
  final DateTime date;
  final List<CalendarEvent> events;
  final void Function(String) onDeleteEvent; // 아직 UI에서 미사용

  const CalendarBottomSheet({
    super.key,
    required this.date,
    required this.events,
    required this.onDeleteEvent,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('d.').format(date);
    final String weekDay = DateFormat('E', 'ko').format(date);
    final Duration dDay = DateTime(date.year, 12, 25).difference(date);
    final int dDayCount = dDay.inDays;

    return FractionallySizedBox(
      child: Container(
        height: 300.h,
        padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
        decoration: const BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들바
            Center(
              child: Container(
                width: 40,
                height: 5,
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
                Text("$formattedDate $weekDay",
                    style:
                        FontStyles.B3_bold_15.copyWith(color: AppColors.Black)),
                Text("D-${dDayCount >= 0 ? dDayCount : 0}",
                    style:
                        FontStyles.B3_bold_15.copyWith(color: AppColors.Black)),
              ],
            ),
            const SizedBox(height: 30),
            // 일정 목록
            events.isEmpty
                ? Text("등록된 일정이 없습니다.",
                    style: FontStyles.B2_reg_16.copyWith(color: AppColors.G_03))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: events
                        .map(
                          (event) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3.w,
                                  height: 40.h,
                                  margin:
                                      EdgeInsets.only(right: 10.w, top: 2.h),
                                  decoration: BoxDecoration(
                                    color: _categoryColor(event.category),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(event.title,
                                          style: FontStyles.B3_bold_15.copyWith(
                                              color: AppColors.Black)),
                                      SizedBox(height: 4.h),
                                      Text(event.memo,
                                          style: FontStyles.B5_reg_13.copyWith(
                                              color: AppColors.G_06)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  )
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case '약속':
        return Colors.red;
      case '팝업':
        return Colors.green;
      case '티켓팅&예약':
        return Colors.yellow;
      case '기타':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}
