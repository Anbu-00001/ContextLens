import 'package:flutter/material.dart';

import '../logic/i18n.dart';
import '../logic/native.dart';
import '../logic/speech.dart';
import '../logic/store.dart';
import '../theme.dart';
import 'package:flutter/services.dart';

import '../widgets/widgets.dart';
import 'emergency_hub.dart';
import 'kids_mode.dart';
import 'learn_zone.dart';
import 'safe_browser.dart';
import 'safety_screen.dart';
import 'scam_scan.dart';
import 'trusted_circle.dart';

class HomeScreen extends StatefulWidget {
  final String lang;
  final VoidCallback onNavigateToPermissions;
  const HomeScreen(
      {super.key, required this.lang, required this.onNavigateToPermissions});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _usageOk = false;
  bool _overlayOk = false;
  bool _accessibilityOk = false;
  bool _running = false;
  String _mode = 'adult';
  int? _spyCount;
  List<HistoryEntry> _recent = [];
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final usage = await Native.hasUsageAccess();
    final overlay = await Native.hasOverlayPermission();
    final accessibility = await Native.hasAccessibility();
    final running = await Native.isMonitorRunning();
    final mode = await Store.userMode();
    final history = await Store.history();
    final spyCount = await Store.lastSpyCount();
    if (!mounted) return;
    setState(() {
      _usageOk = usage;
      _overlayOk = overlay;
      _accessibilityOk = accessibility;
      _running = running;
      _mode = mode;
      _spyCount = spyCount;
      _recent = history.take(3).toList();
    });
  }

  Future<void> _toggleProtection() async {
    if (_running) {
      await Native.stopMonitor();
    } else {
      if (!_usageOk) {
        await Native.openUsageAccessSettings();
        return;
      }
      if (!_overlayOk) {
        await Native.openOverlaySettings();
        return;
      }
      await Native.requestNotificationPermission();
      await Native.startMonitor();
    }
    await Future.delayed(const Duration(milliseconds: 400));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final ready = _usageOk && _overlayOk;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(
        title: Row(
          children: [
            const CLLogo(size: 30),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('ConsentLens',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CLColors.textPrimary)),
                Text(S.tagline.of(lang),
                    style: const TextStyle(
                        fontSize: 11, color: CLColors.textMuted)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: CLColors.textSec),
            tooltip: 'Voice narration',
            onPressed: () => Speech.speak(
                '${S.appName.of(lang)}. ${S.tagline.of(lang)}', lang),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // ── Protection status ──
            Card(
              margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _running
                                ? CLColors.greenLight
                                : CLColors.redLight,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            _running
                                ? Icons.shield_rounded
                                : Icons.shield_outlined,
                            color:
                                _running ? CLColors.green : CLColors.redDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (_running
                                        ? S.protectionActive
                                        : S.protectionOff)
                                    .of(lang),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: CLColors.textPrimary),
                              ),
                              Row(
                                children: [
                                  Text('${S.currentUser.of(lang)}: ',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: CLColors.textMuted)),
                                  ModeBadge(mode: _mode, lang: lang),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _running,
                          onChanged: (_) => _toggleProtection(),
                          activeColor: CLColors.pink,
                        ),
                      ],
                    ),
                    if (!ready) ...[
                      const Divider(height: 22),
                      _setupRow(
                        ok: _usageOk,
                        title: S.usageAccess.of(lang),
                        subtitle: S.usageAccessSub.of(lang),
                        onGrant: Native.openUsageAccessSettings,
                        lang: lang,
                      ),
                      const SizedBox(height: 8),
                      _setupRow(
                        ok: _overlayOk,
                        title: S.overlayAccess.of(lang),
                        subtitle: S.overlayAccessSub.of(lang),
                        onGrant: Native.openOverlaySettings,
                        lang: lang,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Scan a message (Smart Scan, "during threat") ──
            Card(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ScamScanScreen(lang: lang))),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: CLColors.amberLight,
                            borderRadius: BorderRadius.circular(11)),
                        child: const Icon(Icons.search_rounded,
                            color: CLColors.amber, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.scamScan.of(lang),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CLColors.textPrimary)),
                            Text(S.scamScanSub.of(lang),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: CLColors.textMuted,
                                    height: 1.3)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: CLColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),

            // ── Emergency help (crisis) ──
            Card(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              color: CLColors.redLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFF3C2C2)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => EmergencyHubScreen(lang: lang))),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: CLColors.red,
                            borderRadius: BorderRadius.circular(11)),
                        child: const Icon(Icons.emergency_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.emergencyHub.of(lang),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: CLColors.redDark)),
                            Text(S.emergencyHubSub.of(lang),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: CLColors.redDark,
                                    height: 1.3)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: CLColors.redDark),
                    ],
                  ),
                ),
              ),
            ),

            // ── Website permission watch (primary web path) ──
            Card(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _setupRow(
                  ok: _accessibilityOk,
                  title: S.webMonitor.of(lang),
                  subtitle: S.webMonitorSub.of(lang),
                  onGrant: Native.openAccessibilitySettings,
                  lang: lang,
                  icon: Icons.travel_explore_rounded,
                ),
              ),
            ),

            // ── Safe Browser (fallback web path) ──
            Card(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SafeBrowserScreen(lang: lang)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: CLColors.blueLight,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.public_rounded,
                            color: CLColors.blue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.safeBrowser.of(lang),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CLColors.textPrimary)),
                            Text(S.safeBrowserSub.of(lang),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: CLColors.textMuted,
                                    height: 1.3)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: CLColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),

            // ── Spyware safety scan (women-safety hero) ──
            Card(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SafetyScreen(lang: lang)),
                ).then((_) => _refresh()),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: CLColors.redLight,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Center(
                            child: Text('🕵️',
                                style: TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.safetyScan.of(lang),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CLColors.textPrimary)),
                            Text(S.safetyScanSub.of(lang),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: CLColors.textMuted,
                                    height: 1.3)),
                          ],
                        ),
                      ),
                      if (_spyCount != null && _spyCount! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: CLColors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('$_spyCount ⚠',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        )
                      else if (_spyCount == 0)
                        const Icon(Icons.verified_user_rounded,
                            color: CLColors.green)
                      else
                        const Icon(Icons.chevron_right_rounded,
                            color: CLColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),

            // ── Identity verification ──
            Card(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Native.verifyNow();
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: CLColors.purpleLight,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.fingerprint_rounded,
                            color: CLColors.purple, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.verifyNow.of(lang),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CLColors.textPrimary)),
                            Text(S.verifySub.of(lang),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: CLColors.textMuted,
                                    height: 1.3)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: CLColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),

            // ── Learn & protect more ──
            SectionLabel(S.learnZone.of(lang)),
            _toolTile(
              emoji: '🎓',
              bg: CLColors.purpleLight,
              title: S.learnZone.of(lang),
              subtitle: S.learnZoneSub.of(lang),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => LearnZoneScreen(lang: lang))),
            ),
            _toolTile(
              emoji: '🤝',
              bg: CLColors.pinkLight,
              title: S.trustedCircle.of(lang),
              subtitle: S.trustedCircleSub.of(lang),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => TrustedCircleScreen(lang: lang))),
            ),
            _toolTile(
              emoji: '🧸',
              bg: CLColors.blueLight,
              title: S.kidsMode.of(lang),
              subtitle: S.kidsModeSub.of(lang),
              onTap: () => _launchKidsMode(context, lang),
            ),

            // ── Recent alerts ──
            SectionLabel(S.recentAlerts.of(lang)),
            if (_recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(S.noAlerts.of(lang), style: CLTextStyles.body),
              ),
            ..._recent.map((h) => Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: ListTile(
                    dense: true,
                    leading: Text(h.high ? '🚨' : '✅',
                        style: const TextStyle(fontSize: 20)),
                    title: Text(h.appName,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${h.catCount} ${S.permissions.of(lang).toLowerCase()} · ${h.timeAgo()}',
                        style: const TextStyle(
                            fontSize: 11, color: CLColors.textMuted)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            h.high ? CLColors.redLight : CLColors.greenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (h.high ? S.riskHigh : S.riskLow).of(lang),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color:
                                h.high ? CLColors.redDark : CLColors.green),
                      ),
                    ),
                    onTap: widget.onNavigateToPermissions,
                  ),
                )),
            const SizedBox(height: 14),
            const PrivacyChipsStrip(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _toolTile({
    required String emoji,
    required Color bg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
                child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CLColors.textPrimary)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11,
                            color: CLColors.textMuted,
                            height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: CLColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchKidsMode(BuildContext context, String lang) async {
    var pin = await Store.kidsPin();
    if (pin == null && context.mounted) {
      final set = TextEditingController();
      pin = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(S.setPin.of(lang)),
          content: TextField(
            controller: set,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(counterText: ''),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (set.text.length == 4) Navigator.pop(context, set.text);
              },
              child: Text(S.saveContact.of(lang)),
            ),
          ],
        ),
      );
      if (pin != null) await Store.setKidsPin(pin);
    }
    if (pin != null && context.mounted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => KidsModeScreen(lang: lang)));
    }
  }

  Widget _setupRow({
    required bool ok,
    required String title,
    required String subtitle,
    required Future<void> Function() onGrant,
    required String lang,
    IconData? icon,
  }) {
    return Row(
      children: [
        Icon(
            icon ??
                (ok ? Icons.check_circle_rounded : Icons.error_rounded),
            size: 20,
            color: ok ? CLColors.green : CLColors.amber),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: CLColors.textMuted)),
            ],
          ),
        ),
        if (!ok)
          TextButton(
            onPressed: () async {
              await onGrant();
            },
            style: TextButton.styleFrom(
              backgroundColor: CLColors.pink,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(S.grant.of(lang),
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
          )
        else
          Text(S.granted.of(lang),
              style: const TextStyle(
                  fontSize: 11,
                  color: CLColors.green,
                  fontWeight: FontWeight.w600)),
      ],
    );
  }
}
