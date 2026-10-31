import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hr' : 'hrs'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'Yesterday';
      return '$days days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday = now.day == dateTime.day &&
        now.month == dateTime.month &&
        now.year == dateTime.year;

    if (isToday) {
      return DateFormat('hh:mm a').format(dateTime);
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE, hh:mm a').format(dateTime);
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('d MMMM yyyy').format(dateTime);
  }
}
