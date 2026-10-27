import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/controller_info.dart';
import '../../models/input_source.dart';
import '../../models/output_action.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/pill.dart';
import '../../widgets/spacing.dart';
import '../profiles/profiles_provider.dart';
import 'diagnostics_session.dart';
import 'stick_analyzer.dart';
import 'stick_plot.dart';

/// Live stick/trigger analysis for checking sensors (e.g. hall-effect mods):
/// circularity, range, resolution, rest drift and noise, plus raw HID counts.
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key, this.controller});

  final ControllerInfo? controller;

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  late final DiagnosticsSession _session = DiagnosticsSession(
    ref.read(joystickChannelProvider),
    controllerId: widget.controller?.id,
  );

  @override
  void initState() {
    super.initState();
    _session.start();
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            leading: const BackChevron(),
            title: l10n.diagnostics,
            subtitle: _Throttled(
              listenable: _session,
              builder: (_) => Row(
                children: [
                  if (widget.controller != null) ...[
                    Text(widget.controller!.name, style: TextStyle(fontSize: 13, color: p.muted)),
                    const SizedBox(width: AppSpace.md),
                  ],
                  Pill(
                    label: l10n.eventsPerSecond(_session.eventsPerSecond),
                    dot: _session.eventsPerSecond > 0 ? p.success : p.muted,
                  ),
                ],
              ),
            ),
            actions: [HeaderAction(label: l10n.resetStats, icon: Icons.restart_alt, onPressed: _session.reset)],
          ),
          Expanded(
            child: ListView(
              padding: AppSpace.pageInsets,
              children: [
                const _Steps(),
                const SizedBox(height: AppSpace.xl),
                LayoutBuilder(
                  builder: (context, box) {
                    final left = _StickCard(session: _session, side: Side.left, title: l10n.leftStick);
                    final right = _StickCard(session: _session, side: Side.right, title: l10n.rightStick);
                    if (box.maxWidth < 1040) {
                      return Column(
                        children: [
                          left,
                          const SizedBox(height: AppSpace.xl),
                          right,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: AppSpace.xl),
                        Expanded(child: right),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpace.xl),
                _TriggersCard(session: _session),
                const SizedBox(height: AppSpace.xl),
                _RawHidCard(session: _session),
                const SizedBox(height: AppSpace.md),
                Text(l10n.gcNote, style: TextStyle(fontSize: 12, color: p.muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The three-step routine, shown as numbered cards.
class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final steps = [l10n.diagStep1, l10n.diagStep2, l10n.diagStep3];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpace.lg),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpace.lg),
              decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: p.accentSoft,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: p.accent),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(child: Text(steps[i], style: const TextStyle(fontSize: 13, height: 1.4))),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Rebuilds at most ~12 times a second however fast [listenable] fires,
/// so text stats stay readable and cheap while plots repaint every sample.
class _Throttled extends StatefulWidget {
  const _Throttled({required this.listenable, required this.builder});

  final Listenable listenable;
  final WidgetBuilder builder;

  @override
  State<_Throttled> createState() => _ThrottledState();
}

class _ThrottledState extends State<_Throttled> {
  Timer? _timer;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_mark);
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (_dirty && mounted) setState(() => _dirty = false);
    });
  }

  void _mark() => _dirty = true;

  @override
  void dispose() {
    widget.listenable.removeListener(_mark);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpace.card),
    decoration: BoxDecoration(color: context.palette.surface, borderRadius: BorderRadius.circular(18)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppSpace.lg + 4),
        child,
      ],
    ),
  );
}

enum _Verdict { good, warn, bad }

_Verdict _grade(double value, {required double good, required double warn, bool higherIsBetter = false}) {
  if (higherIsBetter) {
    if (value >= good) return _Verdict.good;
    return value >= warn ? _Verdict.warn : _Verdict.bad;
  }
  if (value <= good) return _Verdict.good;
  return value <= warn ? _Verdict.warn : _Verdict.bad;
}

/// One measurement: small label, large value, optional verdict.
class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.verdict, this.hint});

  final String label;
  final String value;
  final _Verdict? verdict;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final (color, text) = switch (verdict) {
      _Verdict.good => (p.success, l10n.verdictGood),
      _Verdict.warn => (p.warning, l10n.verdictWarn),
      _Verdict.bad => (p.danger, l10n.verdictBad),
      null => (null, null),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md + 2, vertical: AppSpace.md),
      decoration: BoxDecoration(color: p.background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ),
              if (text != null)
                Text(
                  text,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.xs + 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color ?? p.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: p.muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Group title plus a two-column grid of metrics.
class _MetricGroup extends StatelessWidget {
  const _MetricGroup({required this.title, required this.metrics});

  final String title;
  final List<Widget> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: context.palette.muted,
          ),
        ),
        const SizedBox(height: AppSpace.sm + 2),
        LayoutBuilder(
          builder: (context, box) {
            final width = (box.maxWidth - AppSpace.sm) / 2;
            return Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [for (final m in metrics) SizedBox(width: width, child: m)],
            );
          },
        ),
      ],
    );
  }
}

String _signed(double v) => '${v >= 0 ? '+' : '−'}${v.abs().toStringAsFixed(3)}';

String _percent(double v, [int digits = 1]) => '${(v * 100).toStringAsFixed(digits)}%';

class _StickCard extends ConsumerStatefulWidget {
  const _StickCard({required this.session, required this.side, required this.title});

  final DiagnosticsSession session;
  final Side side;
  final String title;

  @override
  ConsumerState<_StickCard> createState() => _StickCardState();
}

class _StickCardState extends ConsumerState<_StickCard> {
  static const _calibrationSeconds = 2;
  int? _countdown;

  StickAnalyzer get _stick => widget.session.sticks[widget.side]!;

  /// The mouse-move mapping for this stick in the profile in use, if any.
  (String, InputSource, MouseMoveAction)? _mouseMapping() {
    final profile = ref.read(activeProfileProvider);
    final mapping = profile?.mappingFor(StickAxisInput(widget.side).key);
    if (profile == null || mapping == null) return null;
    if (mapping.action case final MouseMoveAction action) return (profile.id, mapping.input, action);
    return null;
  }

  Future<void> _calibrate() async {
    setState(() => _countdown = _calibrationSeconds);
    final ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && (_countdown ?? 0) > 1) setState(() => _countdown = _countdown! - 1);
    });
    await widget.session.calibrate(widget.side, duration: const Duration(seconds: _calibrationSeconds));
    ticker.cancel();
    if (mounted) setState(() => _countdown = null);
  }

  Future<void> _applyDeadzone(double deadzone) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final target = _mouseMapping();
    if (target == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noMouseMapping)));
      return;
    }
    final (profileId, input, action) = target;
    final rounded = (deadzone * 100).ceil() / 100;
    await ref.read(profilesProvider.notifier).setMapping(profileId, input, action.copyWith(deadzone: rounded));
    final name = ref.read(activeProfileProvider)?.name ?? '';
    messenger.showSnackBar(SnackBar(content: Text(l10n.deadzoneApplied((rounded * 100).round(), name))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    ref.watch(activeProfileProvider);
    final profileDeadzone = _mouseMapping()?.$3.deadzone;

    return _Card(
      title: widget.title,
      trailing: _Throttled(
        listenable: widget.session,
        builder: (_) => Text(
          '${_percent(_stick.magnitude, 0)} · ${_stick.angle.toStringAsFixed(0)}°',
          style: TextStyle(fontSize: 13, color: p.muted, fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ),
      child: _Throttled(
        listenable: widget.session,
        builder: (context) {
          final s = _stick;
          final calibration = s.calibration;
          final bits = s.resolutionBits;
          final outer = s.outerRadius;
          final error = s.circularityError;
          final enoughEdge = s.coverage >= 0.9;
          final deadzone = calibration?.suggestedDeadzone ?? profileDeadzone;
          final noise = calibration == null ? null : math.max(calibration.noiseX, calibration.noiseY);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: StickPlot(stick: s, repaint: widget.session, deadzone: deadzone),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpace.lg,
                runSpacing: AppSpace.xs,
                children: [
                  _Legend(color: p.success, label: l10n.legendEnvelope),
                  _Legend(color: p.warning, label: l10n.legendDeadzone),
                  _Legend(color: p.danger, label: l10n.legendCenter),
                  _Legend(color: p.accent, label: l10n.legendTrail),
                ],
              ),
              if (s.samples == 0) ...[
                const SizedBox(height: AppSpace.md),
                Center(
                  child: Text(l10n.waitingInput, style: TextStyle(fontSize: 12.5, color: p.accent)),
                ),
              ],
              const SizedBox(height: AppSpace.xl),
              _MetricGroup(
                title: l10n.groupSignal,
                metrics: [
                  _Metric(label: l10n.positionX, value: _signed(s.x)),
                  _Metric(label: l10n.positionY, value: _signed(s.y)),
                  _Metric(label: l10n.rangeX, value: '${_signed(s.minX)} … ${_signed(s.maxX)}'),
                  _Metric(label: l10n.rangeY, value: '${_signed(s.minY)} … ${_signed(s.maxY)}'),
                  _Metric(
                    label: l10n.resolution,
                    value: bits == null
                        ? l10n.notMeasured
                        : l10n.resolutionValue(bits.toStringAsFixed(1), s.resolutionLevels!),
                    hint: bits == null ? l10n.measuring : null,
                    verdict: bits == null ? null : _grade(bits, good: 10, warn: 8, higherIsBetter: true),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              _MetricGroup(
                title: l10n.groupCircularity,
                metrics: [
                  _Metric(
                    label: l10n.coverageShort,
                    value: _percent(s.coverage, 0),
                    hint: enoughEdge ? null : l10n.rotateMore,
                  ),
                  _Metric(
                    label: l10n.outerRadius,
                    value: outer == null ? l10n.notMeasured : outer.toStringAsFixed(3),
                    verdict: outer == null || !enoughEdge
                        ? null
                        : _grade(outer, good: 0.97, warn: 0.9, higherIsBetter: true),
                  ),
                  _Metric(
                    label: l10n.circularityError,
                    value: error == null ? l10n.notMeasured : _percent(error),
                    verdict: error == null || !enoughEdge ? null : _grade(error, good: 0.05, warn: 0.1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              _MetricGroup(
                title: l10n.groupCenter,
                metrics: [
                  _Metric(
                    label: l10n.center,
                    value: calibration == null ? l10n.notMeasured : _percent(calibration.drift, 2),
                    hint: calibration == null ? null : '(${_signed(calibration.meanX)}, ${_signed(calibration.meanY)})',
                    verdict: calibration == null ? null : _grade(calibration.drift, good: 0.02, warn: 0.05),
                  ),
                  _Metric(
                    label: l10n.noise,
                    value: noise == null ? l10n.notMeasured : noise.toStringAsFixed(4),
                    hint: calibration == null ? null : l10n.calibrationSamples(calibration.samples),
                    verdict: noise == null ? null : _grade(noise, good: 0.005, warn: 0.02),
                  ),
                  _Metric(
                    label: l10n.suggestedDeadzone,
                    value: calibration == null ? l10n.notMeasured : _percent(calibration.suggestedDeadzone, 0),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _countdown == null ? _calibrate : null,
                      icon: const Icon(Icons.center_focus_strong_outlined, size: 18),
                      label: Text(
                        _countdown == null ? l10n.calibrateCenter.toUpperCase() : l10n.calibrating(_countdown!),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: calibration == null ? null : () => _applyDeadzone(calibration.suggestedDeadzone),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n.applyDeadzone.toUpperCase()),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 11.5, color: context.palette.muted)),
    ],
  );
}

class _TriggersCard extends StatelessWidget {
  const _TriggersCard({required this.session});

  final DiagnosticsSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Card(
      title: l10n.triggers,
      child: _Throttled(
        listenable: session,
        builder: (_) => Column(
          children: [
            for (final (side, label) in [(Side.left, l10n.triggerLeft), (Side.right, l10n.triggerRight)])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                child: Builder(
                  builder: (context) {
                    final t = session.triggers[side]!;
                    final seen = t.min.isFinite;
                    return _RangeBar(
                      label: label,
                      fraction: t.value,
                      observedMin: seen ? t.min : null,
                      observedMax: t.max,
                      valueText: _percent(t.value),
                      rangeText: seen ? '${_percent(t.min)} … ${_percent(t.max)}' : l10n.notMeasured,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal bar with the live value and the observed min/max band.
class _RangeBar extends StatelessWidget {
  const _RangeBar({
    required this.label,
    required this.fraction,
    required this.valueText,
    required this.rangeText,
    this.observedMin,
    this.observedMax,
  });

  final String label;
  final double fraction;
  final double? observedMin;
  final double? observedMax;
  final String valueText;
  final String rangeText;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const tabular = [FontFeature.tabularFigures()];
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              double clamp(double v) => v.clamp(0, 1).toDouble();
              return SizedBox(
                height: 12,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: p.border, borderRadius: BorderRadius.circular(6)),
                    ),
                    if (observedMin != null && observedMax != null)
                      Positioned(
                        left: clamp(observedMin!) * w,
                        width: math.max(2, (clamp(observedMax!) - clamp(observedMin!)) * w),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: p.success.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    Positioned(
                      left: math.max(0, clamp(fraction) * w - 2),
                      width: 4,
                      top: 0,
                      bottom: 0,
                      child: Container(color: p.accent),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: AppSpace.lg),
        SizedBox(
          width: 72,
          child: Text(
            valueText,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFeatures: tabular),
          ),
        ),
        const SizedBox(width: AppSpace.lg),
        SizedBox(
          width: 210,
          child: Text(
            rangeText,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, color: p.muted, fontFeatures: tabular),
          ),
        ),
      ],
    );
  }
}

class _RawHidCard extends StatelessWidget {
  const _RawHidCard({required this.session});

  final DiagnosticsSession session;

  static const _order = ['X', 'Y', 'Z', 'Rx', 'Ry', 'Rz', 'Slider', 'Dial', 'Hat'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return _Card(
      title: l10n.rawHid,
      child: _Throttled(
        listenable: session,
        builder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.rawHidDesc, style: TextStyle(fontSize: 12.5, color: p.muted, height: 1.4)),
            if (session.raw.isEmpty) ...[
              const SizedBox(height: AppSpace.md),
              Text(l10n.rawHidEmpty, style: TextStyle(fontSize: 12.5, color: p.warning)),
            ],
            for (final device in session.raw.values) ...[
              const SizedBox(height: AppSpace.xl),
              Text(device.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpace.sm),
              for (final name in [
                ..._order.where(device.axes.containsKey),
                ...device.axes.keys.where((k) => !_order.contains(k)),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.xs + 2),
                  child: _rawRow(name, device.axes[name]!, l10n),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Shows "observed range / logical range · bits" so a sensor that never
  /// reaches its declared limits stands out.
  Widget _rawRow(String name, RawAxisStats stats, AppLocalizations l10n) {
    final a = stats.axis;
    final span = math.max(1, a.max - a.min);
    double frac(int v) => (v - a.min) / span;
    final bits = (math.log(span + 1) / math.ln2).toStringAsFixed(1);
    return _RangeBar(
      label: '${l10n.axis} $name',
      fraction: frac(a.value),
      observedMin: frac(stats.observedMin),
      observedMax: frac(stats.observedMax),
      valueText: '${a.value}',
      rangeText: '${stats.observedMin}…${stats.observedMax} / ${a.min}…${a.max} · $bits ${l10n.bits.toLowerCase()}',
    );
  }
}
