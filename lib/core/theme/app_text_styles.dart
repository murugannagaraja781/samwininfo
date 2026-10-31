import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Helper font family
  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    try {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }

  // Headings
  static TextStyle h1 = _font(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = _font(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle h3 = _font(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle h4 = _font(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Price styling
  static TextStyle priceLarge = _font(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  static TextStyle priceMedium = _font(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.3,
  );

  static TextStyle priceSmall = _font(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  // Body
  static TextStyle bodyLarge = _font(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = _font(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle bodySmall = _font(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Labels & Captions
  static TextStyle labelLarge = _font(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = _font(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle labelSmall = _font(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  // Buttons
  static TextStyle buttonText = _font(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.2,
  );

  static TextStyle buttonTextSmall = _font(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );
}
