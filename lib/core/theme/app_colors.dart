import 'package:flutter/material.dart';

/// Centralized Color Palette for RelayCare.
/// Designed for clinical clarity, accessibility, and high contrast.
class AppColors {
  // Primary & Secondary Brand Colors (Healthcare Teal & Deep Blue)
  static const Color primary = Color(0xFF00796B); // Deep Teal
  static const Color primaryLight = Color(0xFF48A999);
  static const Color primaryDark = Color(0xFF004C40);
  static const Color secondary = Color(0xFF1E88E5); // Medical Blue
  static const Color accent = Color(0xFF26A69A);

  // Surface & Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFCBD5E1);

  // Status & Connectivity Colors
  static const Color onlineGreen = Color(0xFF16A34A);
  static const Color offlineOrange = Color(0xFFEA580C);
  static const Color syncBlue = Color(0xFF2563EB);

  // Referral Urgency Colors
  static const Color urgencyLow = Color(0xFF10B981); // Green
  static const Color urgencyMedium = Color(0xFFF59E0B); // Amber
  static const Color urgencyHigh = Color(0xFFEF4444); // Red
  static const Color urgencyEmergency = Color(0xFF991B1B); // Dark Red

  // Identity Matching Confidence Colors
  static const Color confidenceHigh = Color(0xFF15803D);
  static const Color confidenceMedium = Color(0xFFD97706);
  static const Color confidenceLow = Color(0xFFDC2626);

  // TODO: Add dark mode specific shades if dark theme is activated.
}
