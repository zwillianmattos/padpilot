import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/profile.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/spacing.dart';
import '../../widgets/page_header.dart';
import '../controllers/controllers_provider.dart';
import '../mapping_editor/device_screen.dart';
import '../settings/settings_provider.dart';
import 'profiles_provider.dart';

XTypeGroup _jsonType(AppLocalizations l10n) => XTypeGroup(label: l10n.profileFileType, extensions: const ['json']);

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final active = ref.watch(activeProfileProvider);
    final notifier = ref.read(profilesProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            leading: const BackChevron(),
            title: l10n.profiles,
            actions: [
              HeaderAction(
                label: l10n.newProfile,
                icon: Icons.add,
                onPressed: () async {
                  final name = await _askName(context, title: l10n.newProfile, initial: l10n.defaultProfileName);
                  if (name == null) return;
                  final profile = await notifier.create(name);
                  if (context.mounted) _edit(context, ref, profile);
                },
              ),
              const HeaderDivider(),
              HeaderAction(
                label: l10n.import,
                icon: Icons.file_download_outlined,
                onPressed: () async {
                  final file = await openFile(acceptedTypeGroups: [_jsonType(l10n)]);
                  if (file == null) return;
                  try {
                    final profile = await notifier.import(file.path);
                    if (context.mounted) _toast(context, l10n.imported(profile.name));
                  } catch (_) {
                    if (context.mounted) _toast(context, l10n.invalidProfileFile);
                  }
                },
              ),
              const HeaderDivider(),
              HeaderAction(
                label: l10n.restoreSamples,
                icon: Icons.restart_alt,
                onPressed: () async {
                  await notifier.restoreSamples();
                  if (context.mounted) _toast(context, l10n.samplesRestored);
                },
              ),
            ],
          ),
          Expanded(
            child: profiles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorLoadingProfiles('$e'))),
              data: (list) => GridView.extent(
                padding: AppSpace.pageInsets,
                maxCrossAxisExtent: 300,
                mainAxisSpacing: AppSpace.xl - 4,
                crossAxisSpacing: AppSpace.xl - 4,
                childAspectRatio: 1.5,
                children: [
                  for (final p in list)
                    _ProfileCard(
                      profile: p,
                      active: p.id == active?.id,
                      onOpen: () => _edit(context, ref, p),
                      onAction: (action) => _handle(context, ref, p, action),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _edit(BuildContext context, WidgetRef ref, Profile profile) {
    final controller = ref.read(controllersProvider).firstOrNull;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceScreen(controller: controller, profileId: profile.id),
      ),
    );
  }

  static Future<void> _handle(BuildContext context, WidgetRef ref, Profile profile, _CardAction action) async {
    final notifier = ref.read(profilesProvider.notifier);
    final l10n = context.l10n;
    switch (action) {
      case _CardAction.use:
        await ref.read(settingsProvider.notifier).setActiveProfile(profile.id);
      case _CardAction.rename:
        final name = await _askName(context, title: l10n.renameProfile, initial: profile.name);
        if (name != null) await notifier.rename(profile, name);
      case _CardAction.duplicate:
        await notifier.duplicate(profile, name: l10n.copyName(profile.name));
      case _CardAction.export:
        final location = await getSaveLocation(
          suggestedName: '${profile.name}.json',
          acceptedTypeGroups: [_jsonType(l10n)],
        );
        if (location == null) return;
        await notifier.export(profile, location.path);
        if (context.mounted) _toast(context, l10n.profileExported);
      case _CardAction.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteProfileTitle(profile.name)),
            content: Text(l10n.cannotBeUndone),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel.toUpperCase())),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: context.palette.danger),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete.toUpperCase()),
              ),
            ],
          ),
        );
        if (ok == true) await notifier.delete(profile);
    }
  }

  static Future<String?> _askName(BuildContext context, {required String title, required String initial}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        void submit() {
          final name = controller.text.trim();
          if (name.isNotEmpty) Navigator.pop(context, name);
        }

        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 360,
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.name),
              onSubmitted: (_) => submit(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel.toUpperCase())),
            FilledButton(onPressed: submit, child: Text(l10n.save.toUpperCase())),
          ],
        );
      },
    );
  }

  static void _toast(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

enum _CardAction { use, rename, duplicate, export, delete }

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({required this.profile, required this.active, required this.onOpen, required this.onAction});

  final Profile profile;
  final bool active;
  final VoidCallback onOpen;
  final ValueChanged<_CardAction> onAction;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final l10n = context.l10n;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpace.card - 2),
          decoration: BoxDecoration(
            color: _hover ? context.palette.background : context.palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.active ? context.palette.accent : (_hover ? context.palette.border : Colors.transparent),
              width: widget.active ? 2 : 1,
            ),
            boxShadow: _hover
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 6))]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sports_esports_outlined,
                    color: widget.active ? context.palette.accent : context.palette.muted,
                  ),
                  const Spacer(),
                  if (widget.active)
                    Text(
                      l10n.inUse.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: context.palette.accent,
                      ),
                    ),
                  PopupMenuButton<_CardAction>(
                    tooltip: l10n.moreActions,
                    icon: const Icon(Icons.more_horiz, size: 18),
                    onSelected: widget.onAction,
                    itemBuilder: (_) => [
                      if (!widget.active) PopupMenuItem(value: _CardAction.use, child: Text(l10n.useThisProfile)),
                      PopupMenuItem(value: _CardAction.rename, child: Text(l10n.rename)),
                      PopupMenuItem(value: _CardAction.duplicate, child: Text(l10n.duplicate)),
                      PopupMenuItem(value: _CardAction.export, child: Text(l10n.exportMenu)),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: _CardAction.delete,
                        child: Text(l10n.delete, style: TextStyle(color: context.palette.danger)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(l10n.actionsCount(p.mappings.length), style: TextStyle(fontSize: 12, color: context.palette.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
