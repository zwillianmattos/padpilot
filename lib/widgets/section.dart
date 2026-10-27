import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'spacing.dart';

/// Titled group of rows on a surface card, macOS-settings style. Rows are
/// separated by hairlines so each one reads as its own setting.
class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.children, this.description});

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpace.xs, bottom: AppSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: p.muted),
                ),
                if (description != null) ...[
                  const SizedBox(height: AppSpace.xs),
                  Text(description!, style: TextStyle(fontSize: 12.5, color: p.muted, height: 1.4)),
                ],
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: AppSpace.card, endIndent: AppSpace.card, color: p.border),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One setting: title and optional description on the left, control on the
/// right (or below, for wide controls).
class SettingRow extends StatelessWidget {
  const SettingRow({super.key, required this.title, this.subtitle, this.trailing, this.below});

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.card, vertical: AppSpace.lg + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(subtitle!, style: TextStyle(fontSize: 12.5, color: p.muted, height: 1.4)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: AppSpace.lg), trailing!],
            ],
          ),
          if (below != null) ...[const SizedBox(height: AppSpace.md), below!],
        ],
      ),
    );
  }
}
