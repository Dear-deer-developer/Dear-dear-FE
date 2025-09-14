import 'package:dear_deer_demo/data/today_ex.dart';
import 'package:dear_deer_demo/view/calendar/calendar_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_add_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_view.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final int currentYear;
  late final List<DateTime> months;
  final PageController _pageController = PageController(initialPage: 0);

  // 날짜별 일정 맵 - key: yyyy-MM-dd, value: List<CalendarEvent>
  Map<String, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    currentYear = fakeToday.year;
    months = [
      DateTime(currentYear, 11),
      DateTime(currentYear, 12),
    ];
    _events = {};
  }

  void _addEvent(DateTime date, CalendarEvent event) {
    final key = _formatDateKey(date);
    setState(() {
      if (_events.containsKey(key)) {
        _events[key]!.add(event);
      } else {
        _events[key] = [event];
      }
    });
  }

  String _formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return _events[_formatDateKey(date)] ?? [];
  }

  void _showAddEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEvent(
        initialDate: fakeToday,
        onAddEvent: (date, title, memo, category) {
          _addEvent(
            date,
            CalendarEvent(title: title, memo: memo, category: category),
          );
          Navigator.pop(context);
          _showCalendarBottomSheet(date);
        },
      ),
    );
  }

  void _showCalendarBottomSheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => CalendarBottomSheet(
        date: date,
        events: _getEventsForDate(date),
        onDeleteEvent: (event) {
          setState(() {
            _events[_formatDateKey(date)]?.remove(event);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _showAddEvent,
        child: const Icon(Icons.add, size: 40, color: Color(0xFFA14E4A)),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: months.length,
          itemBuilder: (context, index) => CalendarView(
            monthDate: months[index],
            onDayTap: _showCalendarBottomSheet,
          ),
        ),
      ),
    );
  }
}
