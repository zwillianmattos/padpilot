import 'package:flutter/widgets.dart';

/// Spacing scale shared by every screen, so gutters and gaps line up.
abstract final class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal gutter of every page body and header.
  static const page = 40.0;

  /// Inner padding of cards and grouped sections.
  static const card = 24.0;

  static const pageInsets = EdgeInsets.fromLTRB(page, lg, page, xxl + lg);
}
