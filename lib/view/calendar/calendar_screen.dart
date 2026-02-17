import 'package:dear_deer_demo/controller/calendar/calendar_controller.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/controller/calendar/schedule_controller.dart';
import 'package:dear_deer_demo/model/calendar/schedule.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_view.dart';
import 'package:dear_deer_demo/view/calendar/calendar_bottom_sheet.dart';
import 'package:dear_deer_demo/view/calendar/calendar_add_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_meta.dart';
import 'package:dear_deer_demo/view/calendar/reward_arrived_dialog.dart';
import 'package:dear_deer_demo/data/calendar/reward_assets.dart';

class CalendarScreen extends StatelessWidget {
  CalendarScreen({super.key});

  final CalendarController _calendar = Get.find();
  final ScheduleController _sc = Get.find();

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int _monthVersion(DateTime m) {
    final yyyymm = m.year * 100 + m.month;
    return _sc.monthlyVersion[yyyymm] ?? 0;
  }

  List<CalendarEvent> _eventsFor(DateTime d) {
    final key = _dateOnly(d);
    final schedules = _sc.monthly[key] ?? const <Schedule>[];

    return schedules
        .map((s) => CalendarEvent(
              id: 'm-${s.id}',
              title: s.title,
              memo: s.memo,
              category:
                  CalendarCategoryMeta.labelFromServer(s.category) ?? '기타',
              date: s.date,
            ))
        .toList();
  }

  List<CalendarEvent> _dailyUi() {
    return _sc.daily
        .map((s) => CalendarEvent(
              id: 'd-${s.id}',
              title: s.title,
              memo: s.memo,
              category:
                  CalendarCategoryMeta.labelFromServer(s.category) ?? '기타',
              date: s.date,
            ))
        .toList();
  }

  ScheduleCategory _enumFromUiLabel(String label) =>
      CalendarCategoryMeta.serverFromUi(
        CalendarCategoryMeta.uiFromLabel(label),
      );

  int? _scheduleIdFromEvent(CalendarEvent e) {
    if (e.id.startsWith('d-')) {
      return int.tryParse(e.id.substring(2));
    }
    final parts = e.id.split('-');
    return parts.isNotEmpty ? int.tryParse(parts.last) : null;
  }

  Future<void> _openAddSheet(BuildContext context) async {
    final result = await showModalBottomSheet<AddEventResult>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEvent(
        initialDate: _calendar.selectedDate.value,
      ),
    );

    if (result == null) return;

    final draft = Schedule(
      id: 0,
      title: result.title,
      memo: result.memo,
      category: _enumFromUiLabel(result.uiCategory),
      date: _dateOnly(result.date),
    );

    await _sc.addEvent(draft);
    await _calendar.changeDate(draft.date);

    await _openDailyBottomSheet(context, draft.date);
  }

  Future<void> _openDailyBottomSheet(
      BuildContext context, DateTime date) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CalendarBottomSheet(
        date: date,
        events: _dailyUi(),
        onDeleteEvent: (evt) async {
          final id = _scheduleIdFromEvent(evt);
          if (id == null) return;
          await _sc.removeEvent(id);
          await _sc.loadDaily(_calendar.selectedDate.value);
        },
        onEditEvent: (evt) async {
          final id = _scheduleIdFromEvent(evt);
          if (id == null) return;

          final changed = Schedule(
            id: id,
            title: evt.title,
            memo: evt.memo,
            category: _enumFromUiLabel(evt.category),
            date: _dateOnly(evt.date),
          );

          final updated = await _sc.editEvent(id, changed);
          await _calendar.changeDate(updated.date);
        },
        onAddPressed: () async {
          Navigator.of(context).pop();
          await _openAddSheet(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleTextStyle =
        FontStyles.C2_reg_24.copyWith(color: AppColors.White);
    final weekdayTextStyle =
        FontStyles.S2_reg_12.copyWith(color: AppColors.White);
    final dayNumberTextStyle = FontStyles.C1_bold_14;

    // 🔹 reward listener (Stateless에서 안전하게 사용)
    ever(_calendar.pendingReward, (reward) async {
      if (reward == null) return;

      final fallback = 'assets/images/rewards/santa_letter.png';
      final asset = rewardAssetFor(reward.giftName) ?? fallback;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => RewardArrivedDialog(
          reward: reward,
          assetFor: (name) => rewardAssetFor(name) ?? asset,
          onGoPressed: () {},
        ),
      );

      _calendar.pendingReward.value = null;
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          right: 8,
          bottom: MediaQuery.of(context).padding.bottom + 80.h,
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () => _openAddSheet(context),
          child: const Icon(
            Icons.add_rounded,
            color: Color(0xFFA14E4A),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: SafeArea(
        child: Obx(() {
          final _ = _sc.monthly.length;
          final __ = _sc.daily.length;

          return PageView.builder(
            controller: _calendar.pageController,
            itemCount: _calendar.months.length,
            onPageChanged: (i) async {
              final m = _calendar.months[i];
              await _sc.loadMonthly(m.year, m.month);
            },
            itemBuilder: (context, index) {
              final monthDate = _calendar.months[index];
              final version = _monthVersion(monthDate);

              return CalendarView(
                key: ValueKey(
                    'cv-${monthDate.year}-${monthDate.month}-$version'),
                monthDate: monthDate,
                selectedDate: _calendar.selectedDate.value,
                today: DateTime.now(),
                getEventsForDate: _eventsFor,
                onDayTap: (date) async {
                  await _calendar.changeDate(_dateOnly(date));
                  await _openDailyBottomSheet(
                      context, _calendar.selectedDate.value);
                },
                dataVersion: version,
                titleStyle: titleTextStyle,
                weekdayStyle: weekdayTextStyle,
                dayNumberStyle: dayNumberTextStyle,
              );
            },
          );
        }),
      ),
    );
  }
}
