import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/spacing.dart';
import '../../widgets/hero_photo.dart';
import '../../widgets/mapping_toggle.dart';
import '../../widgets/page_header.dart';
import '../profiles/profiles_provider.dart';
import '../settings/settings_provider.dart';
import 'data/steam_api.dart';
import 'game_detail_screen.dart';
import 'game_hub_providers.dart';
import 'models/steam_game.dart';
import 'steam_account_dialog.dart';
import 'widgets/game_card.dart';
import 'widgets/steam_image.dart';

/// One horizontal row of the hub.
class _HubRow {
  const _HubRow(this.title, this.items);

  final String title;
  final List<_HubItem> items;
}

class _HubItem {
  const _HubItem({required this.appId, required this.name, this.game, this.dimmed = false, this.discount = 0});

  final int appId;
  final String name;
  final SteamGame? game;
  final bool dimmed;
  final int discount;
}

/// Netflix-style hub: a hero banner and rows grouped by what PadPilot can
/// do for each game (needs mapping, ready, native support…).
class HubScreen extends ConsumerStatefulWidget {
  const HubScreen({super.key});

  @override
  ConsumerState<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends ConsumerState<HubScreen> {
  String _query = '';

  void _open(_HubItem item) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => GameDetailScreen(appId: item.appId, name: item.name, game: item.game),
    ),
  );

  List<_HubRow> _rows(AppLocalizations l10n, List<SteamGame> library, List<FeaturedGame> featured) {
    final settings = ref.watch(gameSettingsProvider).value ?? const {};
    GameDetails? details(int id) => ref.watch(gameDetailsProvider(id)).value;
    _HubItem item(SteamGame g) =>
        _HubItem(appId: g.appId, name: g.name, game: g, dimmed: details(g.appId)?.windowsOnly ?? false);

    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      return [
        _HubRow(l10n.rowSearch, [
          for (final g in library)
            if (g.name.toLowerCase().contains(query)) item(g),
          for (final f in featured)
            if (f.name.toLowerCase().contains(query) && library.every((g) => g.appId != f.appId))
              _HubItem(appId: f.appId, name: f.name, discount: f.discountPercent),
        ]),
      ];
    }

    final visible = library.where((g) => settings[g.appId]?.hidden != true).toList();
    final installed = visible.where((g) => g.installed).toList();
    final played = visible.where((g) => g.lastPlayed != null).toList()
      ..sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));
    bool windowsOnly(SteamGame g) => details(g.appId)?.windowsOnly ?? false;
    bool bound(SteamGame g) => settings[g.appId]?.profileId != null || settings[g.appId]?.padpilotOff == true;

    final rows = <_HubRow>[
      _HubRow(l10n.rowPinned, [
        for (final g in visible)
          if (settings[g.appId]?.pinned == true) item(g),
      ]),
      _HubRow(l10n.rowContinue, [for (final g in played.take(12)) item(g)]),
      _HubRow(l10n.rowNeedsPadPilot, [
        for (final g in installed)
          if (details(g.appId) case final d? when !d.windowsOnly && d.controllerSupport != ControllerSupport.full)
            item(g),
      ]),
      _HubRow(l10n.rowReady, [
        for (final g in installed)
          if (bound(g)) item(g),
      ]),
      _HubRow(l10n.rowUnmapped, [
        for (final g in installed)
          if (!bound(g) && !windowsOnly(g)) item(g),
      ]),
      _HubRow(l10n.rowNative, [
        for (final g in installed)
          if (details(g.appId)?.controllerSupport == ControllerSupport.full && !windowsOnly(g)) item(g),
      ]),
      _HubRow(l10n.rowOwned, [
        for (final g
            in visible.where((g) => !g.installed).toList()
              ..sort((a, b) => (b.playtimeMinutes ?? 0).compareTo(a.playtimeMinutes ?? 0)))
          if (!windowsOnly(g)) item(g),
      ]),
      _HubRow(l10n.rowFeatured, [
        for (final f in [...featured.where((f) => f.mac), ...featured.where((f) => !f.mac)])
          _HubItem(appId: f.appId, name: f.name, dimmed: !f.mac, discount: f.discountPercent),
      ]),
      _HubRow(l10n.rowWindowsOnly, [
        for (final g in visible)
          if (windowsOnly(g)) item(g),
      ]),
    ];
    return rows.where((r) => r.items.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final library = ref.watch(libraryProvider);
    final featured = ref.watch(featuredGamesProvider);
    final account = ref.watch(steamAccountProvider).value;
    final steamInstalled = ref.watch(steamLibraryProvider).isInstalled;
    final games = library.value ?? const <SteamGame>[];
    final rows = _rows(l10n, games, featured.value ?? const []);

    final heroItem = rows.where((r) => r.title != l10n.rowSearch).expand((r) => r.items).firstOrNull;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            leading: const BackChevron(),
            title: l10n.gameHub,
            subtitle: _NowPlaying(fallback: l10n.gamesCount(games.length)),
            actions: [
              SizedBox(
                width: 220,
                height: 36,
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: l10n.searchGames,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: p.surface,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HeaderAction(
                label: account == null ? l10n.linkSteam : l10n.steamAccount,
                icon: account == null ? Icons.link : Icons.person_outline,
                onPressed: () => showSteamAccountDialog(context),
              ),
              const HeaderDivider(),
              const MappingToggle(),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (featured.hasError && library.hasError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, AppSpace.md),
                    child: Text(l10n.offlineError, style: TextStyle(color: p.warning, fontSize: 12)),
                  ),
                if (!steamInstalled && account == null && _query.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.lg),
                    child: _NoSteamBanner(),
                  )
                else if (heroItem != null && _query.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.sm, AppSpace.page, AppSpace.lg),
                    child: _HeroBanner(item: heroItem, onDetails: () => _open(heroItem)),
                  ),
                for (final row in rows) _Row(row: row, onOpen: _open),
                if (library.isLoading || featured.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NowPlaying extends ConsumerWidget {
  const _NowPlaying({required this.fallback});

  final String fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final game = ref.watch(focusedGameProvider);
    final override = ref.watch(gameOverrideProvider);
    final profile = ref.watch(effectiveProfileProvider);
    final text = game == null
        ? fallback
        : override?.$2.padpilotOff == true
        ? l10n.nowPlayingPaused(game.name)
        : l10n.nowPlaying(game.name, profile?.name ?? '—');
    return Text(text, style: TextStyle(fontSize: 13, color: game == null ? p.muted : p.success));
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row, required this.onOpen});

  final _HubRow row;
  final ValueChanged<_HubItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, AppSpace.xl, AppSpace.page, AppSpace.xs),
          child: Text(row.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ),
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.page, vertical: 14),
            itemCount: row.items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpace.lg + 2),
            itemBuilder: (context, i) {
              final item = row.items[i];
              return GameCard(
                appId: item.appId,
                name: item.name,
                dimmed: item.dimmed,
                discountPercent: item.discount,
                onTap: () => onOpen(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends ConsumerWidget {
  const _HeroBanner({required this.item, required this.onDetails});

  final _HubItem item;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final details = ref.watch(gameDetailsProvider(item.appId)).value;
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final settings = ref.watch(gameSettingsProvider).value?[item.appId];
    final profileName = profiles.where((x) => x.id == settings?.profileId).firstOrNull?.name;
    final canPlay = item.game != null;

    return SizedBox(
      height: 360,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SteamImage(
              urls: SteamApi.heroUrls(item.appId, headerImage: details?.headerImage),
              title: item.name,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withValues(alpha: 0.85), Colors.black.withValues(alpha: 0.1)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 90,
                    width: 360,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SteamImage(
                        urls: [SteamApi.logoUrl(item.appId)],
                        fit: BoxFit.contain,
                        fallback: Text(
                          item.name,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (details?.shortDescription.isNotEmpty == true)
                    SizedBox(
                      width: 520,
                      child: Text(
                        details!.shortDescription,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                        onPressed: () => canPlay
                            ? launchGame(ref, item.appId)
                            : ref
                                  .read(joystickChannelProvider)
                                  .openUrl('https://store.steampowered.com/app/${item.appId}'),
                        icon: Icon(canPlay ? Icons.play_arrow_rounded : Icons.storefront_outlined),
                        label: Text((canPlay ? l10n.play : l10n.openStore).toUpperCase()),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        onPressed: onDetails,
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: Text(l10n.details.toUpperCase()),
                      ),
                      if (profileName != null) ...[
                        const SizedBox(width: 14),
                        const Icon(Icons.layers_outlined, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(profileName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSteamBanner extends StatelessWidget {
  const _NoSteamBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 320,
      child: HeroPhoto(
        radius: 20,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.steamNotFound,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 560,
                  child: Text(l10n.steamNotFoundDesc, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  onPressed: () => showSteamAccountDialog(context),
                  icon: const Icon(Icons.link),
                  label: Text(l10n.linkSteam.toUpperCase()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the game through Steam. With auto-switch off, the game's profile
/// becomes the profile in use first so it's armed before the game starts.
Future<void> launchGame(WidgetRef ref, int appId) async {
  final settings = ref.read(gameSettingsProvider).value?[appId];
  final profileId = settings?.profileId;
  if (profileId != null && settings?.autoSwitch == false) {
    await ref.read(settingsProvider.notifier).setActiveProfile(profileId);
  }
  await ref.read(joystickChannelProvider).openUrl('steam://run/$appId');
}
