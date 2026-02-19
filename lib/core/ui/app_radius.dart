import 'package:flutter/material.dart';

/// Centralized border radius. Use for cards, buttons, inputs, chips.
class AppRadius {
  AppRadius._();

  /// 8 — chips, small elements
  static const double sm = 8;

  /// 12 — inputs, list tiles, sidebar tiles
  static const double md = 12;

  /// 16 — cards, modals
  static const double lg = 16;

  /// 20 — large cards, sheets
  static const double xl = 20;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
}
