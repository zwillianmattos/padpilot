import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_theme.dart';
import 'data/steam_api.dart';
import 'game_hub_providers.dart';

Future<void> showSteamAccountDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _SteamAccountDialog());

/// Optional Steam Web API link: key + SteamID64 (pre-filled from the local
/// Steam login when available), validated live before saving.
class _SteamAccountDialog extends ConsumerStatefulWidget {
  const _SteamAccountDialog();

  @override
  ConsumerState<_SteamAccountDialog> createState() => _SteamAccountDialogState();
}

class _SteamAccountDialogState extends ConsumerState<_SteamAccountDialog> {
  final _key = TextEditingController();
  final _id = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _notice;

  @override
  void initState() {
    super.initState();
    ref.read(steamLibraryProvider).signedInSteamId().then((id) {
      if (id != null && mounted && _id.text.isEmpty) _id.text = id;
    });
  }

  @override
  void dispose() {
    _key.dispose();
    _id.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await ref.read(steamAccountProvider.notifier).link(apiKey: _key.text.trim(), steamId: _id.text.trim());
      final owned = await ref.refresh(ownedGamesProvider.future);
      if (!mounted) return;
      if (owned.isEmpty) {
        setState(() => _notice = l10n.privateProfileHint);
      } else {
        Navigator.of(context).pop();
      }
    } on SteamApiException catch (e) {
      setState(() => _error = e.unauthorized || e.statusCode == null ? l10n.invalidKey : l10n.linkFailed(e.message));
    } catch (e) {
      setState(() => _error = l10n.linkFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final account = ref.watch(steamAccountProvider).value;

    return AlertDialog(
      title: Text(l10n.steamAccount),
      content: SizedBox(
        width: 440,
        child: account != null
            ? Text(l10n.linkedAs(account.personaName ?? account.steamId))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.linkSteamDesc, style: TextStyle(fontSize: 13, color: p.muted)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _key,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.apiKey,
                      suffixIcon: TextButton(
                        onPressed: () =>
                            ref.read(joystickChannelProvider).openUrl('https://steamcommunity.com/dev/apikey'),
                        child: Text(l10n.getApiKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _id,
                    decoration: InputDecoration(labelText: l10n.steamId),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: p.danger, fontSize: 12)),
                  ],
                  if (_notice != null) ...[
                    const SizedBox(height: 12),
                    Text(_notice!, style: TextStyle(color: p.warning, fontSize: 12)),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel.toUpperCase())),
        if (account != null)
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.danger, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(steamAccountProvider.notifier).unlink();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.unlink.toUpperCase()),
          )
        else
          FilledButton(
            onPressed: _busy ? null : _link,
            child: _busy
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.link.toUpperCase()),
          ),
      ],
    );
  }
}
