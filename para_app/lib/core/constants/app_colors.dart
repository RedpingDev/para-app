import 'package:flutter/material.dart';

/// PARA 앱 전체에서 사용하는 색상 상수
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  // ── PARA Category Colors ─────────────────────
  static const Color projects = Color(0xFF00B894);
  static const Color areas = Color(0xFF0984E3);
  static const Color resources = Color(0xFFFDCB6E);
  static const Color archive = Color(0xFF636E72);

  // ── Dark Theme ───────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF1E1E32);
  static const Color darkBorder = Color(0xFF2A2A40);

  // ── Light Theme ──────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE9ECEF);

  // ── Text ─────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF1F1F1);
  static const Color darkTextSecondary = Color(0xFFB2B2C8);
  static const Color darkTextMuted = Color(0xFF6C6C8A);
  static const Color lightTextPrimary = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  static const Color lightTextMuted = Color(0xFFB2BEC3);

  // ── Status ───────────────────────────────────
  static const Color active = Color(0xFF00B894);
  static const Color onHold = Color(0xFFFDCB6E);
  static const Color completed = Color(0xFF0984E3);
  static const Color error = Color(0xFFD63031);
  static const Color warning = Color(0xFFE17055);

  // ── Misc ─────────────────────────────────────
  static const Color inbox = Color(0xFFE17055);
  static const Color divider = Color(0xFF2A2A40);

  /// PARA 카테고리에 해당하는 색상 반환
  static Color categoryColor(ParaCategory category) {
    switch (category) {
      case ParaCategory.projects:
        return projects;
      case ParaCategory.areas:
        return areas;
      case ParaCategory.resources:
        return resources;
      case ParaCategory.archive:
        return archive;
    }
  }
}

/// PARA 카테고리 열거형
enum ParaCategory {
  projects,
  areas,
  resources,
  archive,
}
