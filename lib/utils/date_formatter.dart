/// Utility class untuk format tanggal
/// Menghilangkan duplikasi date formatting di seluruh codebase
class DateFormatter {
  // Constants untuk months dan days
  static const List<String> monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> daysFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> daysShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Format: "DD/MM/YYYY"
  /// Contoh: "25/12/2024"
  static String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  /// Format: "DD/MM/YYYY HH:mm"
  /// Contoh: "25/12/2024 14:30"
  static String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  /// Format: "Monday, Jan 1"
  /// Contoh: "Monday, Dec 25"
  static String getFormattedDate() {
    final now = DateTime.now();
    return '${daysFull[now.weekday - 1]}, ${monthsShort[now.month - 1]} ${now.day}';
  }

  /// Format: "DD Month YYYY"
  /// Contoh: "25 Dec 2024"
  static String formatDateWithMonth(DateTime date) {
    return '${date.day} ${monthsShort[date.month - 1]} ${date.year}';
  }

  /// Format dengan label "Today", "Tomorrow", "Yesterday"
  /// Contoh: "Today (25/12/2024)" atau "Tomorrow (26/12/2024)"
  static String formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);

    if (taskDay == today) {
      return "Hari Ini (${formatDate(date)})";
    } else if (taskDay == today.add(const Duration(days: 1))) {
      return "Besok (${formatDate(date)})";
    } else if (taskDay == today.subtract(const Duration(days: 1))) {
      return "Kemarin (${formatDate(date)})";
    } else {
      return formatDate(date);
    }
  }

  /// Format untuk section date dengan "Tomorrow" label
  /// Contoh: "Tomorrow Mon, Dec 26" atau "Mon, Dec 26"
  static String formatSectionDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow ${daysShort[date.weekday - 1]}, ${monthsShort[date.month - 1]} ${date.day}';
    }

    return '${daysShort[date.weekday - 1]}, ${monthsShort[date.month - 1]} ${date.day}';
  }

  /// Format untuk next week range
  /// Contoh: "Dec 30 - Jan 5"
  static String getNextWeekRange() {
    final now = DateTime.now();
    final nextWeekStart = now.add(Duration(days: 7 - now.weekday));
    final nextWeekEnd = nextWeekStart.add(const Duration(days: 6));

    return '${monthsShort[nextWeekStart.month - 1]} ${nextWeekStart.day} - ${monthsShort[nextWeekEnd.month - 1]} ${nextWeekEnd.day}';
  }

  /// Format date string dari ISO format
  /// Contoh: "2024-12-25" -> "25/12/2024"
  static String formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return formatDate(date);
    } catch (e) {
      return dateString;
    }
  }
}
