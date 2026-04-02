import 'package:intl/intl.dart';

class AppUtils {
  static String formatCurrency(double amount, {bool showSign = false}) {
    final formatter = NumberFormat('#,##0.00', 'en_NG');
    final formatted = '₦${formatter.format(amount)}';
    if (showSign) return '+$formatted';
    return formatted;
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    } else if (txDate == yesterday) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, yyyy · hh:mm a').format(date);
    }
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }
}
