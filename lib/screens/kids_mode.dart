// ── ConsentLens Safe Handoff / Kids Mode (Feature 5.2) ─────────────────────
// Parent picks which apps the child may use (KidsSetupScreen). While Kids
// Mode is on, MonitorService watches the foreground app and covers anything
// outside the allowlist with a friendly native "ask a grown-up" overlay.
// If no apps are picked, the legacy pinned play screen is used instead.
// A 4-digit parent PIN gates every exit. Honest scoping: without device-owner
// this is a strong deterrent, not an unbreakable kiosk.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/i18n.dart';
import '../logic/native.dart';
import '../logic/store.dart';
import '../theme.dart';

// ════════════════════════════════════════════════════════════════════════
// Parent setup: choose the child's apps, then start.
// ════════════════════════════════════════════════════════════════════════
class KidsSetupScreen extends StatefulWidget {
  final String lang;
  const KidsSetupScreen({super.key, required this.lang});

  @override
  State<KidsSetupScreen> createState() => _KidsSetupScreenState();
}

class _KidsSetupScreenState extends State<KidsSetupScreen> {
  List<InstalledApp> _apps = [];
  Map<String, Uint8List> _icons = {};
  Set<String> _selected = {};
  final _pinCtrl = TextEditingController();
  bool _loading = true;
  bool _hasPerms = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final apps = await Native.listApps();
    apps.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    final saved = await Store.kidsAllowedApps();
    final pin = await Store.kidsPin();
    final usage = await Native.hasUsageAccess();
    final overlay = await Native.hasOverlayPermission();
    final icons =
        await Native.getAppIcons(apps.map((a) => a.packageName).toList());
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _icons = icons;
      _selected = saved.toSet();
      if (pin != null) _pinCtrl.text = pin;
      _hasPerms = usage && overlay;
      _loading = false;
    });
  }

  bool get _pinOk => _pinCtrl.text.length == 4;

  Future<void> _start() async {
    await Store.setKidsPin(_pinCtrl.text);
    await Store.setKidsAllowedApps(_selected.toList());
    if (_selected.isNotEmpty) {
      // The app guard needs the monitor; make sure it is running.
      await Native.startMonitor();
    }
    await Store.setKidsModeOn(_selected.isNotEmpty);
    await Native.setKidsMode(
        _selected.isNotEmpty, _selected.toList(), widget.lang);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => KidsModeScreen(lang: widget.lang)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(title: Text(S.kidsMode.of(lang))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CLColors.pink))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.chooseKidsApps.of(lang),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(S.chooseKidsAppsSub.of(lang),
                          style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: CLColors.textSec)),
                    ],
                  ),
                ),
                if (!_hasPerms && _selected.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: CLColors.redLight,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Text(S.kidsNeedsPerms.of(lang),
                            style: const TextStyle(
                                fontSize: 12, color: CLColors.redDark)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Native.openUsageAccessSettings(),
                                child: const Text('Usage',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Native.openOverlaySettings(),
                                child: const Text('Overlay',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (_selected.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(S.noAppsPicked.of(lang),
                        style: const TextStyle(
                            fontSize: 12, color: CLColors.textMuted)),
                  ),
                // Parent exit PIN — required, can be changed here.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 18, color: CLColors.pink),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _pinCtrl,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            counterText: '',
                            isDense: true,
                            labelText: S.setPin.of(lang),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: _apps.length,
                    itemBuilder: (_, i) {
                      final app = _apps[i];
                      final on = _selected.contains(app.packageName);
                      final icon = _icons[app.packageName];
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
                        value: on,
                        onChanged: (v) => setState(() {
                          if (v) {
                            _selected.add(app.packageName);
                          } else {
                            _selected.remove(app.packageName);
                          }
                        }),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_pinOk && (_selected.isEmpty || _hasPerms))
                            ? _start
                            : null,
                        icon: const Text('🧸', style: TextStyle(fontSize: 18)),
                        label: Text(
                            _pinOk ? S.startKidsMode.of(lang) : S.setPin.of(lang)),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Child screen: app grid (allowlist) or legacy pinned play screen.
// ════════════════════════════════════════════════════════════════════════
class KidsModeScreen extends StatefulWidget {
  final String lang;
  const KidsModeScreen({super.key, required this.lang});

  @override
  State<KidsModeScreen> createState() => _KidsModeScreenState();
}

class _KidsModeScreenState extends State<KidsModeScreen> {
  List<String> _allowed = [];
  Map<String, Uint8List> _icons = {};
  Map<String, String> _labels = {};
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final allowed = await Store.kidsAllowedApps();
    if (allowed.isEmpty) {
      // Legacy toy screen → pin ConsentLens itself so the child stays here.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => Native.startScreenPinning());
    } else {
      // Re-assert the guard: after a process kill the monitor may be dead even
      // though kids_mode_on persisted. Make sure it is running and flagged.
      await Native.startMonitor();
      await Native.setKidsMode(true, allowed, widget.lang);
      final apps = await Native.listApps();
      _labels = {for (final a in apps) a.packageName: a.label};
      _icons = await Native.getAppIcons(allowed);
    }
    if (!mounted) return;
    setState(() {
      _allowed = allowed;
      _ready = true;
    });
  }

  Future<bool> _tryExit() async {
    final pin = await Store.kidsPin();
    if (!mounted) return false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PinDialog(lang: widget.lang, expected: pin),
    );
    if (ok == true) {
      await Store.setKidsModeOn(false);
      await Native.setKidsMode(false, const [], widget.lang);
      await Native.kidsGuardOff();
      await Native.stopScreenPinning();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _tryExit() && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF5B3FA8),
        body: SafeArea(
          child: !_ready
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    // Top bar with a discreet exit (PIN-gated).
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.lock_rounded,
                            color: Colors.white70),
                        onPressed: () async {
                          if (await _tryExit() && mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const Spacer(),
                    const Text('🧸', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                          _allowed.isEmpty
                              ? S.kidsHi.of(lang)
                              : S.kidsPickApp.of(lang),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 26),
                    if (_allowed.isEmpty)
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _toy('🎨'),
                          _toy('🔢'),
                          _toy('⭐'),
                          _toy('🐱'),
                          _toy('🎈'),
                          _toy('🚗'),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          alignment: WrapAlignment.center,
                          children: _allowed.map(_appTile).toList(),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(S.kidsModeNote.of(lang),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Colors.white60)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _appTile(String pkg) {
    final icon = _icons[pkg];
    final label = _labels[pkg] ?? pkg;
    return GestureDetector(
      onTap: () => Native.launchApp(pkg),
      child: SizedBox(
        width: 86,
        child: Column(
          children: [
            Container(
              width: 78,
              height: 78,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20)),
              child: icon != null
                  ? Image.memory(icon)
                  : const Icon(Icons.apps_rounded, color: Color(0xFF5B3FA8)),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // Simple tappable toys — pop a friendly reaction (zero-risk play).
  Widget _toy(String emoji) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$emoji  Yay!'),
          duration: const Duration(milliseconds: 700))),
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 38))),
      ),
    );
  }
}

class _PinDialog extends StatefulWidget {
  final String lang;
  final String? expected;
  const _PinDialog({required this.lang, required this.expected});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _ctrl = TextEditingController();
  bool _error = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.enterPin.of(widget.lang)),
      content: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          errorText: _error ? S.wrongPin.of(widget.lang) : null,
        ),
        onChanged: (v) {
          if (v.length == 4) {
            if (v == widget.expected) {
              Navigator.pop(context, true);
            } else {
              setState(() => _error = true);
              _ctrl.clear();
            }
          }
        },
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
      ],
    );
  }
}
