import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/joystick_channel.dart';
import '../../core/platform/joystick_events.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/controller_info.dart';
import '../../models/profile.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/spacing.dart';
import '../../widgets/controller_artwork.dart';
import '../../widgets/mapping_toggle.dart';
import '../../widgets/page_header.dart';
import '../controllers/controllers_provider.dart';
import '../diagnostics/diagnostics_screen.dart';
import '../profiles/profiles_provider.dart';
import '../profiles/profiles_screen.dart';
import '../settings/settings_provider.dart';
import 'action_labels.dart';
import 'control_panel.dart';
import 'controller_layout.dart';

/// Device page: the controller photo with clickable hotspots and a side panel
/// to assign actions. Works without a connected controller too.
class DeviceScreen extends ConsumerStatefulWidget {
  const DeviceScreen({super.key, this.controller, this.profileId});

  final ControllerInfo? controller;

  /// Profile to open; defaults to the one in use.
  final String? profileId;

  @override
  ConsumerState<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends ConsumerState<DeviceScreen> {
  late ControllerStyle _style = widget.controller?.style ?? ControllerStyle.xbox;
  late final JoystickChannel _channel = ref.read(joystickChannelProvider);
  String? _selectedSpot;
  String? _highlightedInput;
  late String? _profileId = widget.profileId;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _channel.setLiveInput(true);
  }

  @override
  void dispose() {
    _channel.setLiveInput(false);
    if (_capturing) _channel.stopCapture();
    super.dispose();
  }

  Future<void> _toggleCapture() async {
    setState(() => _capturing = !_capturing);
    _capturing ? await _channel.startCapture() : await _channel.stopCapture();
  }

  void _onCaptured(InputCaptured event) {
    if (widget.controller != null && event.controllerId != widget.controller!.id) return;
    final spot = controlSpotsFor(_style, context.l10n).where((s) => s.contains(event.name)).firstOrNull;
    if (spot == null) return;
    setState(() {
      _capturing = false;
      _selectedSpot = spot.id;
      _highlightedInput = event.name;
    });
    _channel.stopCapture();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(joystickEventsProvider, (_, next) {
      if (next.value case final InputCaptured event when _capturing) _onCaptured(event);
    });

    final profiles = ref.watch(profilesProvider).value ?? const [];
    final active = ref.watch(activeProfileProvider);
    final profile = profiles.where((p) => p.id == _profileId).firstOrNull ?? active;
    final connected =
        widget.controller != null && ref.watch(controllersProvider).any((c) => c.id == widget.controller!.id);
    final live = ref.watch(
      liveInputProvider.select((all) {
        if (widget.controller != null) return all[widget.controller!.id] ?? const <String, double>{};
        return all.values.firstOrNull ?? const <String, double>{};
      }),
    );
    final l10n = context.l10n;
    final spots = controlSpotsFor(_style, l10n);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            leading: const BackChevron(),
            title: widget.controller?.name ?? l10n.profileEditor,
            subtitle: _ProfileSwitcher(
              profile: profile,
              profiles: profiles,
              isActive: profile != null && profile.id == active?.id,
              onSelect: (p) => setState(() {
                _profileId = p.id;
                _selectedSpot = null;
              }),
            ),
            actions: [
              if (widget.controller == null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SegmentedButton<ControllerStyle>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: ControllerStyle.xbox, label: Text('Xbox')),
                      ButtonSegment(value: ControllerStyle.playstation, label: Text('PlayStation')),
                    ],
                    selected: {_style},
                    onSelectionChanged: (s) => setState(() => _style = s.first),
                  ),
                ),
              HeaderAction(
                label: l10n.diagnosticsShort,
                icon: Icons.query_stats,
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => DiagnosticsScreen(controller: widget.controller))),
              ),
              const HeaderDivider(),
              HeaderAction(
                label: _capturing ? l10n.waitingController : l10n.detectButton,
                icon: _capturing ? Icons.sensors : Icons.touch_app_outlined,
                color: _capturing ? context.palette.accent : null,
                onPressed: _toggleCapture,
              ),
              const HeaderDivider(),
              const MappingToggle(),
            ],
          ),
          Expanded(
            child: profile == null
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpace.page),
                                child: _DeviceStage(
                                  style: _style,
                                  spots: spots,
                                  profile: profile,
                                  live: live,
                                  selected: _selectedSpot,
                                  dimmed: widget.controller != null && !connected,
                                  onSelect: (id) => setState(() {
                                    _selectedSpot = id == _selectedSpot ? null : id;
                                    _highlightedInput = null;
                                  }),
                                ),
                              ),
                            ),
                            _StatusLine(
                              capturing: _capturing,
                              connected: connected,
                              offline: widget.controller == null,
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, color: context.palette.border),
                      SizedBox(
                        width: 400,
                        child: ControlPanel(
                          profile: profile,
                          style: _style,
                          spots: spots,
                          selectedSpot: _selectedSpot,
                          highlightedInput: _highlightedInput,
                          live: live,
                          onSelectSpot: (id) => setState(() {
                            _selectedSpot = id;
                            _highlightedInput = null;
                          }),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSwitcher extends ConsumerWidget {
  const _ProfileSwitcher({
    required this.profile,
    required this.profiles,
    required this.isActive,
    required this.onSelect,
  });

  final Profile? profile;
  final List<Profile> profiles;
  final bool isActive;
  final ValueChanged<Profile> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Row(
      children: [
        PopupMenuButton<Object>(
          tooltip: l10n.switchProfile,
          position: PopupMenuPosition.under,
          onSelected: (value) {
            if (value is Profile) onSelect(value);
            if (value == #manage) {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilesScreen()));
            }
          },
          itemBuilder: (_) => [
            for (final p in profiles) PopupMenuItem(value: p, child: Text(p.name)),
            const PopupMenuDivider(),
            PopupMenuItem(value: #manage, child: Text(l10n.manageProfiles)),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.profileLabel} ', style: TextStyle(fontSize: 13, color: context.palette.muted)),
              Text(profile?.name ?? '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const Icon(Icons.expand_more, size: 18),
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (isActive)
          Text(
            l10n.inUse.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: context.palette.success,
            ),
          )
        else if (profile != null)
          TextButton(
            onPressed: () => ref.read(settingsProvider.notifier).setActiveProfile(profile!.id),
            child: Text(
              l10n.useThisProfile.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
            ),
          ),
      ],
    );
  }
}

/// Photo + hotspots, scaled to fit while keeping the photo's aspect ratio.
class _DeviceStage extends ConsumerWidget {
  const _DeviceStage({
    required this.style,
    required this.spots,
    required this.profile,
    required this.live,
    required this.selected,
    required this.dimmed,
    required this.onSelect,
  });

  final ControllerStyle style;
  final List<ControlSpot> spots;
  final Profile profile;
  final Map<String, double> live;
  final String? selected;
  final bool dimmed;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(keyLabelsProvider).value ?? const {};
    final l10n = context.l10n;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: AspectRatio(
          aspectRatio: ControllerArtwork.aspectRatio,
          child: LayoutBuilder(
            builder: (context, box) => Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ControllerArtwork(style: style, dimmed: dimmed),
                ),
                for (final spot in spots)
                  Positioned(
                    left: spot.position.dx * box.maxWidth - _Hotspot.size / 2,
                    top: spot.position.dy * box.maxHeight - _Hotspot.size / 2,
                    child: _Hotspot(
                      spot: spot,
                      assigned: spot.inputs.where((i) => profile.mappingFor(i.input.key) != null).length,
                      active: spot.inputs.any((i) => i.input.liveValue(live) >= (i.input.isAnalog ? 0.25 : 0.5)),
                      selected: selected == spot.id,
                      tooltip: _tooltip(spot, labels, l10n),
                      onTap: () => onSelect(spot.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tooltip(ControlSpot spot, Map<int, String> labels, AppLocalizations l10n) {
    final lines = [
      for (final i in spot.inputs)
        if (profile.mappingFor(i.input.key) case final m?)
          spot.inputs.length == 1
              ? actionSummary(m.action, labels, l10n)
              : '${i.label}: ${actionSummary(m.action, labels, l10n)}',
    ];
    return [
      spot.label,
      ...lines.isEmpty ? [l10n.notAssigned] : lines,
    ].join('\n');
  }
}

class _Hotspot extends StatefulWidget {
  const _Hotspot({
    required this.spot,
    required this.assigned,
    required this.active,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  static const size = 26.0;

  final ControlSpot spot;
  final int assigned;
  final bool active;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_Hotspot> createState() => _HotspotState();
}

class _HotspotState extends State<_Hotspot> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.selected || widget.active;
    final fill = highlighted
        ? context.palette.accent
        : widget.assigned > 0
        ? context.palette.text
        : Colors.white;
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 250),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: widget.active ? 1.25 : (_hover ? 1.12 : 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _Hotspot.size,
              height: _Hotspot.size,
              decoration: BoxDecoration(
                color: fill.withValues(alpha: highlighted ? 1 : 0.92),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: (highlighted ? context.palette.accent : Colors.black).withValues(
                      alpha: highlighted ? 0.45 : 0.22,
                    ),
                    blurRadius: highlighted ? 14 : 6,
                    spreadRadius: highlighted ? 3 : 0,
                  ),
                ],
              ),
              child: widget.assigned > 0 || highlighted
                  ? null
                  : Icon(Icons.add, size: 12, color: context.palette.muted),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.capturing, required this.connected, required this.offline});

  final bool capturing;
  final bool connected;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = capturing
        ? l10n.statusCapturing
        : offline
        ? l10n.statusOffline
        : connected
        ? l10n.statusConnected
        : l10n.statusDisconnected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: capturing ? context.palette.accent : context.palette.muted),
      ),
    );
  }
}
