// ── ConsentLens Trusted Apps (no permission popup) ─────────────────────────
// Lets the user mark daily-use apps they trust so the permission popup stays
// quiet for them. ConsentLens keeps watching every other app. The list is
// shared with MonitorService via SharedPreferences (popup_whitelist).

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../logic/i18n.dart';
import '../logic/native.dart';
import '../logic/store.dart';
import '../theme.dart';

class TrustedAppsScreen extends StatefulWidget {
  final String lang;
  const TrustedAppsScreen({super.key, required this.lang});

  @override
  State<TrustedAppsScreen> createState() => _TrustedAppsScreenState();
}

class _TrustedAppsScreenState extends State<TrustedAppsScreen> {
  List<InstalledApp> _apps = [];
  Map<String, Uint8List> _icons = {};
  Set<String> _selected = {};
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final apps = await Native.listApps();
    apps.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    final saved = await Store.popupWhitelist();
    final icons =
        await Native.getAppIcons(apps.map((a) => a.packageName).toList());
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _icons = icons;
      _selected = saved.toSet();
      _loading = false;
    });
  }

  Future<void> _toggle(String pkg, bool on) async {
    setState(() {
      if (on) {
        _selected.add(pkg);
      } else {
        _selected.remove(pkg);
      }
    });
    await Store.setPopupWhitelist(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final q = _query.toLowerCase();
    final shown = q.isEmpty
        ? _apps
        : _apps.where((a) => a.label.toLowerCase().contains(q)).toList();
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(title: Text(S.trustedApps.of(lang))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CLColors.pink))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: CLColors.pinkLight,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_off_rounded,
                          color: CLColors.pink, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(S.trustedAppsIntro.of(lang),
                            style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: CLColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      hintText: const L('Search apps', 'ऐप खोजें', 'ಆ್ಯಪ್ ಹುಡುಕಿ')
                          .of(lang),
                      filled: true,
                      fillColor: CLColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: CLColors.border),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (_, i) {
                      final app = shown[i];
                      final icon = _icons[app.packageName];
                      final on = _selected.contains(app.packageName);
                      return SwitchListTile(
                        dense: true,
                        secondary: icon != null
                            ? Image.memory(icon, width: 34, height: 34)
                            : const Icon(Icons.android_rounded,
                                color: CLColors.textMuted),
                        title: Text(app.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: on
                            ? Text(S.noPopupApps.of(lang),
                                style: const TextStyle(
                                    fontSize: 11, color: CLColors.green))
                            : null,
                        value: on,
                        onChanged: (v) => _toggle(app.packageName, v),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
