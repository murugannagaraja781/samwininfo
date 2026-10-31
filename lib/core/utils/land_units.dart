class LandUnitConverter {
  static const double sqFtPerCent = 435.6;
  static const double sqFtPerKuzhi = 144.0; // Standard Tamil Nadu Kuzhi = 144 sq.ft (3.025 Kuzhi = 1 Cent; 300 Kuzhi = 1 Acre)
  static const double sqFtPerGround = 2400.0;
  static const double sqFtPerAcre = 43560.0; // 100 Cents = 300 Kuzhi
  static const double sqFtPerHectare = 107639.1; // 1 Hectare = 2.471 Acres = 247.105 Cents
  static const double sqFtPerGuntha = 1089.0;

  static const List<String> supportedUnits = [
    'Cents',
    'குழி (Kuzhi)',
    'Acres',
    'ஹெக்டேர் (Hectare)',
    'Sq.Ft',
    'Grounds',
  ];

  /// Converts any value in a given unit to square feet.
  static int toSqFt(double value, String unit) {
    return toSqFtExact(value, unit).round();
  }

  /// Converts any value in a given unit to exact square feet.
  static double toSqFtExact(double value, String unit) {
    final cleanUnit = unit.toLowerCase();
    if (cleanUnit.contains('cent') || cleanUnit.contains('சென்ட்')) {
      return value * sqFtPerCent;
    } else if (cleanUnit.contains('kuzhi') || cleanUnit.contains('குழி')) {
      return value * sqFtPerKuzhi;
    } else if (cleanUnit.contains('hectare') || cleanUnit.contains('ஹெக்டேர்')) {
      return value * sqFtPerHectare;
    } else if (cleanUnit.contains('acre') || cleanUnit.contains('ஏக்கர்')) {
      return value * sqFtPerAcre;
    } else if (cleanUnit.contains('ground')) {
      return value * sqFtPerGround;
    } else if (cleanUnit.contains('guntha')) {
      return value * sqFtPerGuntha;
    } else {
      return value;
    }
  }

  /// Converts square feet to a specific unit with formatted decimal.
  static double fromSqFt(int sqFt, String unit) {
    return fromSqFtDouble(sqFt.toDouble(), unit);
  }

  /// Converts double square feet to a specific unit with formatted decimal.
  static double fromSqFtDouble(double sqFt, String unit) {
    final cleanUnit = unit.toLowerCase();
    if (cleanUnit.contains('cent') || cleanUnit.contains('சென்ட்')) {
      return double.parse((sqFt / sqFtPerCent).toStringAsFixed(2));
    } else if (cleanUnit.contains('kuzhi') || cleanUnit.contains('குழி')) {
      return double.parse((sqFt / sqFtPerKuzhi).toStringAsFixed(2));
    } else if (cleanUnit.contains('hectare') || cleanUnit.contains('ஹெக்டேர்')) {
      return double.parse((sqFt / sqFtPerHectare).toStringAsFixed(3));
    } else if (cleanUnit.contains('acre') || cleanUnit.contains('ஏக்கர்')) {
      return double.parse((sqFt / sqFtPerAcre).toStringAsFixed(3));
    } else if (cleanUnit.contains('ground')) {
      return double.parse((sqFt / sqFtPerGround).toStringAsFixed(2));
    } else if (cleanUnit.contains('guntha')) {
      return double.parse((sqFt / sqFtPerGuntha).toStringAsFixed(2));
    } else {
      return double.parse(sqFt.toStringAsFixed(2));
    }
  }

  /// Direct conversion between any two units
  static double convert(double value, {required String fromUnit, required String toUnit}) {
    final sqFt = toSqFtExact(value, fromUnit);
    return fromSqFtDouble(sqFt, toUnit);
  }

  /// Returns a human-friendly multi-unit label, e.g. "10 Cents (4,356 sq.ft)" or "15 குழி (2,160 sq.ft)"
  static String formatWithConversion({
    required int sqFt,
    String? preferredUnit,
    double? unitValue,
  }) {
    if (preferredUnit != null && preferredUnit != 'Sq.Ft' && unitValue != null && unitValue > 0) {
      final unitLabel = preferredUnit.contains('Kuzhi') || preferredUnit.contains('குழி')
          ? '$unitValue குழி (Kuzhi)'
          : '$unitValue $preferredUnit';
      return '$unitLabel (~$sqFt sq.ft)';
    }

    // Auto smart presentation for Land / Farmland
    if (sqFt >= 43560) {
      final acres = (sqFt / sqFtPerAcre).toStringAsFixed(2);
      return '$acres Acres ($sqFt sq.ft)';
    } else if (sqFt >= 2400) {
      final grounds = (sqFt / sqFtPerGround).toStringAsFixed(1);
      final cents = (sqFt / sqFtPerCent).toStringAsFixed(1);
      return '$cents Cents / $grounds Grounds ($sqFt sq.ft)';
    } else if (sqFt >= 435) {
      final cents = (sqFt / sqFtPerCent).toStringAsFixed(1);
      return '$cents Cents ($sqFt sq.ft)';
    }
    return '$sqFt sq.ft';
  }

  static String formatDisplayArea({
    required int sqFt,
    String? landUnit,
    double? landUnitValue,
  }) {
    if (landUnit != null && landUnitValue != null && landUnitValue > 0) {
      if (landUnit.contains('குழி') || landUnit.toLowerCase().contains('kuzhi')) {
        return '$landUnitValue குழி';
      } else if (landUnit.toLowerCase().contains('cent')) {
        return '$landUnitValue Cent';
      } else if (landUnit.toLowerCase().contains('acre')) {
        return '$landUnitValue Acre';
      } else if (landUnit == 'Sq.Ft') {
        return '$sqFt sq.ft';
      } else {
        return '$landUnitValue $landUnit';
      }
    }
    if (sqFt >= 43560) {
      return '${(sqFt / sqFtPerAcre).toStringAsFixed(2)} Acre';
    } else if (sqFt >= 435) {
      return '${(sqFt / sqFtPerCent).toStringAsFixed(1)} Cent';
    }
    return '$sqFt sq.ft';
  }
}
