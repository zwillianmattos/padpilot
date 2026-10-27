import 'package:flutter/material.dart';

import '../models/controller_info.dart';

/// Product photo for a controller style. Both photos are 1200×~830.
class ControllerArtwork extends StatelessWidget {
  const ControllerArtwork({super.key, required this.style, this.dimmed = false});

  static const aspectRatio = 1200 / 830;

  final ControllerStyle style;
  final bool dimmed;

  static String assetFor(ControllerStyle style) => switch (style) {
    ControllerStyle.xbox => 'assets/controllers/xbox.png',
    ControllerStyle.playstation => 'assets/controllers/dualsense.png',
  };

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(assetFor(style), fit: BoxFit.contain, filterQuality: FilterQuality.medium);
    if (!dimmed) return image;
    return Opacity(
      opacity: 0.35,
      child: ColorFiltered(colorFilter: const ColorFilter.matrix(_grayscale), child: image),
    );
  }

  static const _grayscale = <double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];
}
