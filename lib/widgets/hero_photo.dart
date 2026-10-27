import 'package:flutter/material.dart';

/// Lifestyle photo with a dark gradient so overlaid text stays readable in
/// both themes.
class HeroPhoto extends StatelessWidget {
  const HeroPhoto({super.key, this.child, this.radius = 24, this.alignment = Alignment.center});

  static const asset = 'assets/images/hero.jpg';

  final Widget? child;
  final double radius;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(asset, fit: BoxFit.cover, alignment: alignment, filterQuality: FilterQuality.medium),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.72)],
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}
