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
    return PageView.builder(
      controller: _pageController,
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        return _buildCalendar(month);
      },
    );
  }

  Widget _buildCalendar(DateTime monthDate) {
    int year = monthDate.year;
    int month = monthDate.month;

    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int startWeekday = firstDayOfMonth.weekday % 7;
    int lastDay = DateTime(year, month + 1, 0).day;

    List<Widget> dayWidgets = [];
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }
    for (int day = 1; day <= lastDay; day++) {
      dayWidgets.add(
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text('$day', style: TextStyle(fontSize: 16.sp)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 60.h),
        Text(
          DateFormat('yyyy.MM').format(monthDate),
          style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('일'),
            Text('월'),
            Text('화'),
            Text('수'),
            Text('목'),
            Text('금'),
            Text('토'),
          ],
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 1.2,
            children: dayWidgets,
          ),
        ),
      ],
    );
  }
}
