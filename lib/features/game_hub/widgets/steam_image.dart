import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/app_theme.dart';
import '../game_hub_providers.dart';

/// Resolved disk files per URL list, so scrolling rows don't re-request.
final _resolved = <String, Future<File?>>{};

/// Steam artwork from the disk cache, trying [urls] in order. Shows
/// [fallback] (or a title card) while loading and when nothing exists.
class SteamImage extends ConsumerWidget {
  const SteamImage({super.key, required this.urls, this.title, this.fit = BoxFit.cover, this.fallback});

  final List<String> urls;
  final String? title;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = _resolved.putIfAbsent(urls.join('|'), () => ref.read(steamApiProvider).cachedImage(urls));
    return FutureBuilder<File?>(
      future: future,
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return fallback ?? TitleCard(title: title ?? '', loading: !snapshot.hasData && !snapshot.hasError);
        }
        return Image.file(
          file,
          fit: fit,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => fallback ?? TitleCard(title: title ?? ''),
        );
      },
    );
  }
}

/// Generated poster used when Steam has no artwork.
class TitleCard extends StatelessWidget {
  const TitleCard({super.key, required this.title, this.loading = false});

  final String title;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.accentSoft, p.surface],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: loading
              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: p.muted))
              : Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: p.text),
                ),
        ),
      ),
    );
  }
}
