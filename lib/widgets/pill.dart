import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Tiny status chip shown under devices, e.g. "● Conectado".
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.dot, this.icon, this.background});

  final String label;
  final Color? dot;
  final IconData? icon;

  /// Defaults to the palette surface.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background ?? context.palette.surface, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[Icon(icon, size: 12, color: context.palette.muted), const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.palette.text),
          ),
        ],
      ),
    );
  }
}
