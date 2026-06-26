import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/media/exercise_media.dart';
import '../notifications/notifications_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _bytes = 0;
  String? _status;

  @override
  void initState() {
    super.initState();
    _refreshSize();
  }

  Future<void> _refreshSize() async {
    final b = await ref.read(mediaCacheProvider).sizeBytes();
    if (mounted) setState(() => _bytes = b);
  }

  Future<void> _clear() async {
    await ref.read(mediaCacheProvider).clear();
    if (mounted) setState(() => _status = 'Caché vaciada');
    await _refreshSize();
  }

  Future<void> _predownload() async {
    final cache = ref.read(mediaCacheProvider);
    final catalog = await ref.read(catalogProvider.future);
    var done = 0;
    for (final ex in catalog) {
      for (final cand in mediaCandidates(
          gifKey: ex.gifKey, staticImages: ex.staticImages)) {
        if (cand.kind == MediaKind.text) break;
        var ok = true;
        for (final url in cand.urls) {
          final f = await cache.getIfCached(url) ?? await cache.fetch(url);
          if (f == null) {
            ok = false;
            break;
          }
        }
        if (ok) break;
      }
      done++;
      if (mounted) {
        setState(() => _status = 'Descargando… $done/${catalog.length}');
      }
    }
    if (mounted) setState(() => _status = 'Descarga completa ($done)');
    await _refreshSize();
  }

  @override
  Widget build(BuildContext context) {
    final mb = (_bytes / (1024 * 1024)).toStringAsFixed(1);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            key: const Key('open-notifications'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const NotificationsSettingsScreen()),
            ),
          ),
          const Divider(height: 32),
          Text('Caché de animaciones',
              style: Theme.of(context).textTheme.titleMedium),
          Text('Tamaño actual: $mb MB'),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('predownload'),
            onPressed: _predownload,
            icon: const Icon(Icons.download),
            label: const Text('Pre-descargar todo (wifi recomendado)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('clear-cache'),
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Vaciar caché'),
          ),
          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!),
          ],
        ],
      ),
    );
  }
}
