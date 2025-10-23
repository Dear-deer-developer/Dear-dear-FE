import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_edit_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/calendar/calendar_controller.dart';

final calendarController = Get.find<CalendarController>();

class CalendarBottomSheet extends StatefulWidget {
  final DateTime date;
  final List<CalendarEvent> events;
  final void Function(CalendarEvent) onDeleteEvent;
  final void Function(CalendarEvent) onEditEvent;

  static const Map<String, int> categoryPriority = {
    '약속': 1,
    '팝업': 2,
    '티켓팅&예약': 3,
    '기타': 4,
  };

  const CalendarBottomSheet({
    Key? key,
    required this.date,
    required this.events,
    required this.onDeleteEvent,
    required this.onEditEvent,
  }) : super(key: key);

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  late List<CalendarEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = List.from(widget.events);
  }

  void _handleDelete(CalendarEvent event) {
    setState(() {
      _events.remove(event);
    });
    widget.onDeleteEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('d.').format(widget.date);
    final String weekDay = DateFormat('E', 'ko').format(widget.date);
    final Duration dDay =
        DateTime(widget.date.year, 12, 25).difference(widget.date);
    final int dDayCount = dDay.inDays;

    List<CalendarEvent> sortedEvents = List.from(_events);
    sortedEvents.sort((a, b) {
      int aPriority = CalendarBottomSheet.categoryPriority[a.category] ?? 100;
      int bPriority = CalendarBottomSheet.categoryPriority[b.category] ?? 100;
      return aPriority.compareTo(bPriority);
    });

    return FractionallySizedBox(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final baseHeight = 266.h;
          final perEventHeight = 35.h;
          final eventCount = sortedEvents.length;

          double calculatedHeight = baseHeight + (perEventHeight * eventCount);
          double finalHeight =
              calculatedHeight > 620.h ? 620.h : calculatedHeight;

          return Container(
            height: finalHeight,
            padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
            decoration: const BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$formattedDate $weekDay",
                      style: FontStyles.B1_bold_15.copyWith(
                          color: AppColors.Black),
                    ),
                    Text(
                      "D-${dDayCount >= 0 ? dDayCount : 0}",
                      style: FontStyles.B1_bold_15.copyWith(
                          color: AppColors.Black),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: sortedEvents.isEmpty
                      ? Text(
                          "등록된 일정이 없습니다.",
                          style: FontStyles.B1_reg_16.copyWith(
                              color: AppColors.G_03),
                        )
                      : ListView.builder(
                          itemCount: sortedEvents.length,
                          itemBuilder: (context, index) {
                            final event = sortedEvents[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final result = await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (_) => EditEventSheet(
                                        initialDate: widget.date,
                                        originalEvent: event,
                                      ),
                                    );

                                    if (result == 'deleted') {
                                      _handleDelete(event);
                                    } else if (result is CalendarEvent) {
                                      setState(() {
                                        final idx = _events.indexWhere(
                                            (e) => e.id == event.id);
                                        if (idx != -1) {
                                          _events[idx] = result;
                                        }
                                      });
                                      widget.onEditEvent(result);
                                    }
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 5.w,
                                        height: 40.h,
                                        margin: EdgeInsets.only(
                                            right: 10.w, top: 2.h),
                                        decoration: BoxDecoration(
                                          color: event.categoryColor,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event.title,
                                              style:
                                                  FontStyles.B1_reg_15.copyWith(
                                                      color: AppColors.Black),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              event.memo,
                                              style:
                                                  FontStyles.S1_reg_12.copyWith(
                                                      color: AppColors.Black),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                if (index != sortedEvents.length - 1)
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    child: Divider(
                                      color: AppColors.G_03,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
