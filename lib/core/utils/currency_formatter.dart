import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats price in Indian Lakhs and Crores (e.g. ₹45 Lakhs, ₹1.25 Cr)
  static String formatIndian(double amount) => formatIndianPrice(amount);

  static String formatIndianPrice(double amount, {bool isRental = false}) {
    if (amount <= 0) return 'Price on Request';

    if (isRental) {
      final formatter = NumberFormat('#,##,###', 'en_IN');
      return '₹${formatter.format(amount.toInt())}/mo';
    }

    if (amount >= 10000000) {
      final crores = amount / 10000000;
      // If round number, show 1 or 2 decimals
      if (crores == crores.roundToDouble()) {
        return '₹${crores.toStringAsFixed(0)} Cr';
      } else {
        return '₹${crores.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} Cr';
      }
    } else if (amount >= 100000) {
      final lakhs = amount / 100000;
      if (lakhs == lakhs.roundToDouble()) {
        return '₹${lakhs.toStringAsFixed(0)} Lakhs';
      } else {
        return '₹${lakhs.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} Lakhs';
      }
    } else {
      final formatter = NumberFormat('#,##,###', 'en_IN');
      return '₹${formatter.format(amount.toInt())}';
    }
  }

  /// Format compact (e.g. ₹45L, ₹1.2Cr)
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      final crores = amount / 10000000;
      return '₹${crores.toStringAsFixed(crores >= 10 ? 1 : 2).replaceAll(RegExp(r'\.?0+$'), '')} Cr';
    } else if (amount >= 100000) {
      final lakhs = amount / 100000;
      return '₹${lakhs.toStringAsFixed(lakhs >= 10 ? 0 : 1).replaceAll(RegExp(r'\.?0+$'), '')}L';
    }
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return '₹${formatter.format(amount.toInt())}';
  }

  /// Calculates and formats price per sq.ft
  static String formatPerSqFt(double totalPrice, int areaSqFt) {
    if (areaSqFt <= 0 || totalPrice <= 0) return '';
    final perSqFt = (totalPrice / areaSqFt).round();
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return '₹${formatter.format(perSqFt)} / sq.ft';
  }

  /// Formats raw number with Indian comma separators
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return formatter.format(number);
  }
}
