import 'package:flutter/material.dart';

abstract class C {
  // ── Ecken ──────────────────────────────────────────────────────────────────
  static const red      = Color(0xFFE94B3C);
  static const redDark  = Color(0xFFB91C1C);
  static const blue     = Color(0xFF3B82F6);
  static const blueDark = Color(0xFF1E40AF);

  // ── Hintergrund ───────────────────────────────────────────────────────────
  static const bg       = Color(0xFF0F172A);
  static const surface  = Color(0xFF1E293B);
  static const surface2 = Color(0xFF334155);
  static const border   = Color(0xFF475569);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const text      = Color(0xFFF1F5F9);
  static const textMuted = Color(0xFF94A3B8);

  // ── Akzente ───────────────────────────────────────────────────────────────
  static const gold    = Color(0xFFFBBF24);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);
  static const info    = Color(0xFF06B6D4);

  // ── Gradient: Boxer-Ausweis ───────────────────────────────────────────────
  static const gradientBoxer = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientRed = LinearGradient(
    colors: [Color(0xFFE94B3C), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBlue = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGold = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
