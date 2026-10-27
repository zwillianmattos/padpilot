import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/controller_info.dart';
import '../../models/input_source.dart';
import '../../models/profile.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/spacing.dart';
import '../profiles/profiles_provider.dart';
import 'action_editor.dart';
import 'action_labels.dart';
import 'controller_layout.dart';

/// Right-hand panel: an overview of every control, or the inputs of the
/// selected control with their action editors.
class ControlPanel extends ConsumerWidget {
  const ControlPanel({
    super.key,
    required this.profile,
    required this.style,
    required this.spots,
    required this.selectedSpot,
    required this.highlightedInput,
    required this.live,
    required this.onSelectSpot,
  });

  final Profile profile;
  final ControllerStyle style;
  final List<ControlSpot> spots;
  final String? selectedSpot;
  final String? highlightedInput;
  final Map<String, double> live;
  final ValueChanged<String?> onSelectSpot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spot = spots.where((s) => s.id == selectedSpot).firstOrNull;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: spot == null
          ? _Overview(key: const ValueKey('overview'), profile: profile, spots: spots, onSelect: onSelectSpot)
          : _SpotDetail(
              key: ValueKey('${spot.id}-${profile.id}'),
              profile: profile,
              spot: spot,
              highlightedInput: highlightedInput,
              live: live,
              onBack: () => onSelectSpot(null),
            ),
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({super.key, required this.profile, required this.spots, required this.onSelect});

  final Profile profile;
  final List<ControlSpot> spots;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(keyLabelsProvider).value ?? const {};
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xxl, AppSpace.sm, AppSpace.xxl, AppSpace.xxl),
      children: [
        Text(l10n.assignments, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          l10n.actionsInProfile(profile.mappings.length),
          style: TextStyle(fontSize: 12, color: context.palette.muted),
        ),
        const SizedBox(height: 16),
        for (final spot in spots)
          _OverviewRow(
            spot: spot,
            summary: [
              for (final i in spot.inputs)
                if (profile.mappingFor(i.input.key) case final m?) actionSummary(m.action, labels, l10n),
            ].join(' · '),
            onTap: () => onSelect(spot.id),
          ),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.spot, required this.summary, required this.onTap});

  final ControlSpot spot;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.md + 2, horizontal: AppSpace.sm),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: summary.isEmpty ? Colors.transparent : context.palette.text,
                border: Border.all(color: summary.isEmpty ? context.palette.border : context.palette.text, width: 2),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 130,
              child: Text(spot.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Text(
                summary.isEmpty ? context.l10n.notAssigned : summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: summary.isEmpty ? context.palette.muted : context.palette.text),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: context.palette.muted),
          ],
        ),
      ),
    );
  }
}

class _SpotDetail extends ConsumerStatefulWidget {
  const _SpotDetail({
    super.key,
    required this.profile,
    required this.spot,
    required this.highlightedInput,
    required this.live,
    required this.onBack,
  });

  final Profile profile;
  final ControlSpot spot;
  final String? highlightedInput;
  final Map<String, double> live;
  final VoidCallback onBack;

  @override
  ConsumerState<_SpotDetail> createState() => _SpotDetailState();
}

class _SpotDetailState extends ConsumerState<_SpotDetail> {
  late String? _expanded =
      widget.highlightedInput ?? (widget.spot.inputs.length == 1 ? widget.spot.inputs.first.input.key : null);

  @override
  void didUpdateWidget(_SpotDetail old) {
    super.didUpdateWidget(old);
    if (widget.highlightedInput != null && widget.highlightedInput != old.highlightedInput) {
      _expanded = widget.highlightedInput;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(keyLabelsProvider).value ?? const {};
    final l10n = context.l10n;
    final notifier = ref.read(profilesProvider.notifier);
    final hasAxis = widget.spot.inputs.any(
      (i) => i.input is StickAxisInput && widget.profile.mappingFor(i.input.key) != null,
    );
    final hasDirection = widget.spot.inputs.any(
      (i) => i.input is StickDirectionInput && widget.profile.mappingFor(i.input.key) != null,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xxl, AppSpace.xxl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              tooltip: l10n.allControls,
            ),
            Expanded(
              child: Text(widget.spot.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        if (hasAxis && hasDirection)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 0, 8),
            child: Text(l10n.bothFireWarning, style: TextStyle(fontSize: 12, color: context.palette.warning)),
          ),
        const SizedBox(height: 8),
        for (final labeled in widget.spot.inputs)
          Builder(
            builder: (context) {
              final mapping = widget.profile.mappingFor(labeled.input.key);
              // Keep the stored threshold when the mapping already exists.
              final input = mapping?.input ?? labeled.input;
              final expanded = _expanded == labeled.input.key;
              return _InputCard(
                title: labeled.label,
                summary: actionSummary(mapping?.action, labels, l10n),
                assigned: mapping != null,
                expanded: expanded,
                active: labeled.input.liveValue(widget.live) >= (labeled.input.isAnalog ? 0.25 : 0.5),
                onTap: () => setState(() => _expanded = expanded ? null : labeled.input.key),
                child: ActionEditor(
                  input: input,
                  action: mapping?.action,
                  onActionChanged: (action) => notifier.setMapping(widget.profile.id, input, action),
                  onInputChanged: (next) {
                    if (mapping != null) notifier.setMapping(widget.profile.id, next, mapping.action);
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.title,
    required this.summary,
    required this.assigned,
    required this.expanded,
    required this.active,
    required this.onTap,
    required this.child,
  });

  final String title;
  final String summary;
  final bool assigned;
  final bool expanded;
  final bool active;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: AppSpace.md, left: AppSpace.sm),
      decoration: BoxDecoration(
        color: expanded ? context.palette.background : context.palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: expanded || active ? context.palette.accent : Colors.transparent),
        boxShadow: expanded
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.lg + 2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: 12, color: context.palette.muted)),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: assigned ? FontWeight.w700 : FontWeight.w500,
                            color: assigned ? context.palette.text : context.palette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: context.palette.muted),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg + 2, 0, AppSpace.lg + 2, AppSpace.lg + 2),
              child: child,
            ),
        ],
      ),
    );
  }
}
