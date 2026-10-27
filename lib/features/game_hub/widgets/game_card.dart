import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../widgets/app_theme.dart';
import '../../profiles/profiles_provider.dart';
import '../data/steam_api.dart';
import '../game_hub_providers.dart';
import '../models/steam_game.dart';
import 'steam_image.dart';

/// Badge colour and label for a game's controller support.
(Color, String, IconData) controllerBadge(BuildContext context, ControllerSupport support) {
  final p = context.palette;
  final l10n = context.l10n;
  return switch (support) {
    ControllerSupport.full => (p.success, l10n.badgeFull, Icons.sports_esports),
    ControllerSupport.partial => (p.warning, l10n.badgePartial, Icons.sports_esports_outlined),
    ControllerSupport.none => (p.danger, l10n.badgeNone, Icons.keyboard_alt_outlined),
  };
}

/// Portrait poster tile for the hub rows: lifts on hover and shows the
/// bound profile and controller-support badge.
class GameCard extends ConsumerStatefulWidget {
  const GameCard({
    super.key,
    required this.appId,
    required this.name,
    required this.onTap,
    this.width = 160,
    this.dimmed = false,
    this.discountPercent = 0,
  });

  final int appId;
  final String name;
  final VoidCallback onTap;
  final double width;
  final bool dimmed;
  final int discountPercent;

  @override
  ConsumerState<GameCard> createState() => _GameCardState();
}

class _GameCardState extends ConsumerState<GameCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final details = ref.watch(gameDetailsProvider(widget.appId)).value;
    final settings = ref.watch(gameSettingsProvider).value?[widget.appId];
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final profileName = profiles.where((x) => x.id == settings?.profileId).firstOrNull?.name;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: _hover ? 1.06 : 1,
          child: Opacity(
            opacity: widget.dimmed ? 0.45 : 1,
            child: SizedBox(
              width: widget.width,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: _hover ? 0.35 : 0.15),
                        blurRadius: _hover ? 22 : 8,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: p.surface),
                        SteamImage(
                          urls: SteamApi.posterUrls(widget.appId, headerImage: details?.headerImage),
                          title: widget.name,
                        ),
                        if (widget.discountPercent > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _Tag(text: context.l10n.discount(widget.discountPercent), color: p.success),
                          ),
                        if (details != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Builder(
                              builder: (context) {
                                final (color, label, icon) = controllerBadge(context, details.controllerSupport);
                                return Tooltip(
                                  message: label,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(icon, size: 14, color: color),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (profileName != null || settings?.padpilotOff == true)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    settings?.padpilotOff == true ? Icons.pause_circle_outline : Icons.layers_outlined,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      settings?.padpilotOff == true ? context.l10n.padpilotOffShort : profileName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}
