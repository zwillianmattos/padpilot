import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../l10n/l10n.dart';
import 'app_theme.dart';
import 'spacing.dart';

/// Draggable top area of every page (the title bar is hidden), with a large
/// title on the left and small uppercase actions on the right.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.leading, this.actions = const [], this.subtitle});

  final String title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Padding(
        // Leaves room for the macOS traffic lights; Windows has a real title bar.
        padding: EdgeInsets.fromLTRB(
          AppSpace.page,
          Platform.isMacOS ? 48 : AppSpace.xl,
          AppSpace.page - AppSpace.sm,
          AppSpace.md,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.4),
                  ),
                  if (subtitle != null) ...[const SizedBox(height: 4), subtitle!],
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

/// Small uppercase text action, e.g. "+ NOVO PERFIL".
class HeaderAction extends StatelessWidget {
  const HeaderAction({super.key, required this.label, required this.icon, required this.onPressed, this.color});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label.toUpperCase()),
      style: TextButton.styleFrom(
        foregroundColor: color ?? context.palette.text,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed, this.badge});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? badge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Badge(isLabelVisible: badge != null, backgroundColor: badge, smallSize: 8, child: Icon(icon, size: 20)),
    );
  }
}

class HeaderDivider extends StatelessWidget {
  const HeaderDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 18, margin: const EdgeInsets.symmetric(horizontal: 6), color: context.palette.border);
}

/// Back chevron used on pushed pages.
class BackChevron extends StatelessWidget {
  const BackChevron({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.back,
    onPressed: () => Navigator.of(context).maybePop(),
    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
  );
}
