import 'package:dear_deer_demo/data/today_ex.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_add_event.dart';
import 'package:dear_deer_demo/view/calendar/calendar_bottom_sheet.dart';
import 'package:dear_deer_demo/view/calendar/calendar_view.dart';
import 'package:uuid/uuid.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final int currentYear;
  late final List<DateTime> months;
  final PageController _pageController = PageController(initialPage: 0);
  final uuid = Uuid();

  // 날짜별 일정 맵 - key: yyyy-MM-dd, value: List<CalendarEvent>
  Map<String, List<CalendarEvent>> _events = {};

  DateTime? _selectedDate;
  DateTime _today = fakeToday;

  @override
  void initState() {
    super.initState();
    currentYear = fakeToday.year;
    months = [
      DateTime(currentYear, 11),
      DateTime(currentYear, 12),
    ];
    _events = {};
    _selectedDate = _today;
  }

  String _formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return _events[_formatDateKey(date)] ?? [];
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

  void _showAddEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEvent(
        initialDate: _selectedDate ?? _today,
        onAddEvent: (date, title, memo, category) {
          _addEvent(
            date,
            CalendarEvent(
              id: uuid.v4(),
              title: title,
              memo: memo,
              category: category,
              date: date,
            ),
          );
          Navigator.pop(context);
          _showCalendarBottomSheet(date);
        },
      ),
    );
  }

  void _showCalendarBottomSheet(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CalendarBottomSheet(
        date: date,
        events: _getEventsForDate(date),
        onDeleteEvent: (event) {
          setState(() {
            final key = _formatDateKey(event.date);
            _events[key]?.removeWhere((e) => e.id == event.id);
          });
        },
        onEditEvent: _handleEditEvent,
      ),
    );
  }

  void _handleEditEvent(CalendarEvent editedEvent) {
    setState(() {
      final key = _formatDateKey(editedEvent.date);
      final eventsForKey = _events[key];
      if (eventsForKey != null) {
        final index = eventsForKey.indexWhere((e) => e.id == editedEvent.id);
        if (index != -1) {
          eventsForKey[index] = editedEvent;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _showAddEvent,
        child: const Icon(
          Icons.add,
          size: 40,
          color: Color(0xFFA14E4A),
        ),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: months.length,
          itemBuilder: (context, index) => CalendarView(
            monthDate: months[index],
            onDayTap: (date) {
              setState(() {
                _selectedDate = date;
              });
              _showCalendarBottomSheet(date);
            },
            selectedDate: _selectedDate,
            today: _today,
            getEventsForDate: _getEventsForDate,
          ),
        ),
      ),
    );
  }
}
