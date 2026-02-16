class CalendarSeasonConfig {
  final int year;
  final int startMonth;
  final int endMonth;

  const CalendarSeasonConfig({
    required this.year,
    required this.startMonth,
    required this.endMonth,
  });

  List<DateTime> get months {
    return List.generate(
      endMonth - startMonth + 1,
      (i) => DateTime(year, startMonth + i),
    );
  }
}
