import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final int currentYear;
  late final List<DateTime> months;

  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    currentYear = DateTime.now().year;
    months = [
      DateTime(currentYear, 11),
      DateTime(currentYear, 12),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView.builder(
        controller: _pageController,
        itemCount: months.length,
        itemBuilder: (context, index) => _buildCalendar(months[index]),
      ),
    );
  }

  Widget _buildCalendar(DateTime monthDate) {
    // final today = DateTime.now();
    final today = DateTime(2025, 11, 5);
    final year = monthDate.year;
    final month = monthDate.month;

    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    List<Widget> boxWidgets = [];
    for (int i = 0; i < startWeekday; i++) {
      boxWidgets.add(_blankCalendarBox());
    }
    for (int day = 1; day <= lastDay; day++) {
      final thisDay = DateTime(year, month, day);
      final isToday = _isSameDate(thisDay, today);
      final isPast =
          thisDay.isBefore(DateTime(today.year, today.month, today.day));

      boxWidgets.add(_calendarBox(
        day: day,
        isPast: isPast,
        isToday: isToday,
        date: thisDay,
      ));
    }
    while (boxWidgets.length % 7 != 0) {
      boxWidgets.add(_blankCalendarBox());
    }

    // 원하는 위치/비대칭 패딩 적용 (ex: 왼쪽 33, 오른쪽 58.5)
    return Padding(
      padding: EdgeInsets.only(left: 33.w, right: 58.5.w),
      child: Column(
        children: [
          SizedBox(height: 115.h), // 집 내부에서 딱 맞게 보이도록 조정
          Text(
            DateFormat('yyyy.MM').format(monthDate),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: (34.w * 7) + (5.w * 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildWeekdayBoxes(),
            ),
          ),
          SizedBox(
            width: (34.w * 7) + (5.w * 6),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: boxWidgets.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 11.h,
                crossAxisSpacing: 5.w,
                childAspectRatio: 34 / 48,
              ),
              itemBuilder: (context, index) => boxWidgets[index],
            ),
          ),
        ],
      ),
    );
  }

  // 요일 박스: 투명 배경(텍스트만)
  List<Widget> _buildWeekdayBoxes() {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return List.generate(7, (i) {
      return Container(
        width: 34.w,
        height: 48.h,
        margin: EdgeInsets.only(right: i != 6 ? 5.w : 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          days[i],
          style: FontStyles.S1_reg_12.copyWith(color: AppColors.White),
        ),
      );
    });
  }

  // 날짜 박스: 흰 배경, 오늘 상단 빨간 바, 과거 텍스트만 불투명 처리
  Widget _calendarBox({
    required int day,
    required bool isPast,
    required bool isToday,
    required DateTime date,
  }) {
    return GestureDetector(
      child: Container(
        width: 34.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: isPast ? const Color(0xFFDBB586) : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Stack(
          children: [
            if (isToday)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.mainRed,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(2.r)),
                  ),
                ),
              ),
            Container(
              alignment: Alignment(0, -0.3),
              child: Text(
                '$day',
                style: FontStyles.C1_bold_14.copyWith(
                    color: isPast
                        ? AppColors.G_07.withOpacity(0.4)
                        : AppColors.G_07),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blankCalendarBox() {
    return Container(
      width: 34.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFDBB586),
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
