import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/profile.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/spacing.dart';
import '../../widgets/pill.dart';
import '../controllers/controllers_provider.dart';
import '../mapping_editor/device_screen.dart';
import '../profiles/profiles_provider.dart';
import 'data/steam_api.dart';
import 'game_hub_providers.dart';
import 'hub_screen.dart';
import 'models/steam_game.dart';
import 'widgets/game_card.dart';
import 'widgets/steam_image.dart';

/// Game page: hero art, store info and the per-game PadPilot settings
/// (bound profile, auto-switch, off-for-this-game, pin/hide).
class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.appId, required this.name, this.game});

  final int appId;
  final String name;

  /// Null for store-only (featured) games.
  final SteamGame? game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final detailsAsync = ref.watch(gameDetailsProvider(appId));
    final details = detailsAsync.value;
    final canPlay = game != null;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 400,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SteamImage(
                  urls: SteamApi.heroUrls(appId, headerImage: details?.headerImage),
                  title: name,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent, p.background],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 24,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: Colors.black45, foregroundColor: Colors.white),
                    tooltip: l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  ),
                ),
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 420,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: SteamImage(
                            urls: [SteamApi.logoUrl(appId)],
                            fit: BoxFit.contain,
                            fallback: Text(
                              name,
                              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: p.text),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (canPlay)
                            FilledButton.icon(
                              onPressed: () => launchGame(ref, appId),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(l10n.play.toUpperCase()),
                            ),
                          if (canPlay) const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () =>
                                ref.read(joystickChannelProvider).openUrl('https://store.steampowered.com/app/$appId'),
                            icon: const Icon(Icons.storefront_outlined, size: 18),
                            label: Text(l10n.openStore.toUpperCase()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.page),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _Info(details: details, game: game, loading: detailsAsync.isLoading),
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: 380,
                  child: _PadPilotPanel(appId: appId, name: name, details: details),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.details, required this.game, required this.loading});

  final GameDetails? details;
  final SteamGame? game;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final d = details;
    final g = game;
    String hours(int minutes) => (minutes / 60).toStringAsFixed(minutes < 600 ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (d != null)
              Builder(
                builder: (context) {
                  final (color, label, _) = controllerBadge(context, d.controllerSupport);
                  return Pill(label: label, dot: color);
                },
              ),
            if (d?.windowsOnly == true) Pill(label: l10n.badgeWindowsOnly, dot: p.danger),
            if (g?.installed == true) Pill(label: l10n.badgeInstalled, dot: p.success),
            if (d?.metacritic case final score?) Pill(label: 'Metacritic $score'),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          loading ? l10n.loading : (d?.shortDescription.isNotEmpty == true ? d!.shortDescription : l10n.noDescription),
          style: TextStyle(fontSize: 14, height: 1.5, color: p.text),
        ),
        const SizedBox(height: 20),
        _Facts(
          rows: [
            if (d?.genres.isNotEmpty == true) (l10n.genres, d!.genres.join(', ')),
            if (d?.developers.isNotEmpty == true) (l10n.developer, d!.developers.join(', ')),
            if (d?.releaseDate case final date?) (l10n.releaseDate, date),
            if (d != null)
              (l10n.platforms, [if (d.mac) 'macOS', if (d.windows) 'Windows', if (d.linux) 'Linux'].join(' · ')),
            if (g?.playtimeMinutes case final m? when m > 0) (l10n.playtime, l10n.playtimeHours(hours(m))),
            if (g?.lastPlayed case final t?) (l10n.lastPlayed, MaterialLocalizations.of(context).formatMediumDate(t)),
            if (g?.sizeOnDisk case final bytes? when bytes > 0)
              (l10n.installSize, '${(bytes / (1 << 30)).toStringAsFixed(1)} GB'),
          ],
        ),
        if (d?.screenshots.isNotEmpty == true) ...[
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: d!.screenshots.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: SteamImage(urls: [d.screenshots[i]]),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(label, style: TextStyle(fontSize: 13, color: p.muted)),
                ),
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PadPilotPanel extends ConsumerWidget {
  const _PadPilotPanel({required this.appId, required this.name, required this.details});

  final int appId;
  final String name;
  final GameDetails? details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final settings = ref.watch(gameSettingsProvider).value?[appId] ?? GameSettings(appId: appId);
    final notifier = ref.read(gameSettingsProvider.notifier);
    final suggestion = settings.profileId == null ? suggestedProfileId(details, profiles) : null;
    final bound = profiles.where((x) => x.id == settings.profileId).firstOrNull;

    void update(GameSettings Function(GameSettings) change) => notifier.edit(appId, change);

    return Container(
      padding: const EdgeInsets.all(AppSpace.card),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.padpilotForGame, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Text(l10n.profileForGame, style: TextStyle(fontSize: 12, color: p.muted)),
          const SizedBox(height: 4),
          DropdownButton<String?>(
            isExpanded: true,
            value: bound?.id,
            underline: Container(height: 1, color: p.border),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.useProfileInUse)),
              for (final profile in profiles) DropdownMenuItem(value: profile.id, child: Text(profile.name)),
            ],
            onChanged: settings.padpilotOff ? null : (id) => update((s) => s.copyWith(profileId: () => id)),
          ),
          if (suggestion != null && !settings.padpilotOff)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: p.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.suggested(profiles.firstWhere((x) => x.id == suggestion).name),
                      style: TextStyle(fontSize: 12, color: p.accent),
                    ),
                  ),
                  TextButton(
                    onPressed: () => update((s) => s.copyWith(profileId: () => suggestion)),
                    child: Text(l10n.useSuggestion.toUpperCase()),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: settings.padpilotOff
                    ? null
                    : () async {
                        final base = bound ?? ref.read(activeProfileProvider);
                        final profilesNotifier = ref.read(profilesProvider.notifier);
                        final created = base == null
                            ? await profilesNotifier.create(name)
                            : await profilesNotifier.duplicate(base, name: name);
                        await notifier.edit(appId, (s) => s.copyWith(profileId: () => created.id));
                      },
                icon: const Icon(Icons.add, size: 16),
                label: Text(l10n.createProfileForGame.toUpperCase()),
              ),
              if (bound != null)
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          DeviceScreen(controller: ref.read(controllersProvider).firstOrNull, profileId: bound.id),
                    ),
                  ),
                  icon: const Icon(Icons.tune, size: 16),
                  label: Text(l10n.editProfile.toUpperCase()),
                ),
            ],
          ),
          const Divider(height: 28),
          _Toggle(
            title: l10n.autoSwitch,
            subtitle: l10n.autoSwitchDesc,
            value: settings.autoSwitch,
            onChanged: settings.padpilotOff ? null : (v) => update((s) => s.copyWith(autoSwitch: v)),
          ),
          _Toggle(
            title: l10n.padpilotOffForGame,
            subtitle: l10n.padpilotOffDesc,
            value: settings.padpilotOff,
            highlight: details?.controllerSupport == ControllerSupport.full && !settings.padpilotOff,
            onChanged: (v) => update((s) => s.copyWith(padpilotOff: v)),
          ),
          const Divider(height: 28),
          _Toggle(
            title: l10n.pinGame,
            value: settings.pinned,
            onChanged: (v) => update((s) => s.copyWith(pinned: v)),
          ),
          _Toggle(
            title: l10n.hideGame,
            value: settings.hidden,
            onChanged: (v) => update((s) => s.copyWith(hidden: v)),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.highlight = false,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final bool highlight;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        title,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: highlight ? p.success : null),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!, style: TextStyle(fontSize: 12, color: p.muted)),
      value: value,
      onChanged: onChanged,
    );
  }
}
