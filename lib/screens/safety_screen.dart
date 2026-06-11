// ── ConsentLens Spyware Safety Scan ─────────────────────────────────────────
// Scans installed apps for the stalkerware fingerprint and presents results
// with safety-first guidance (never "uninstall now") + official help lines.

import 'package:flutter/material.dart';

import '../logic/i18n.dart';
import '../logic/native.dart';
import '../logic/speech.dart';
import '../logic/stalkerware.dart';
import '../logic/store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class SafetyScreen extends StatefulWidget {
  final String lang;
  const SafetyScreen({super.key, required this.lang});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  SpyScanResult? _result;
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    final result = await runStalkerwareScan();
    if (!mounted) return;
    setState(() {
      _result = result;
      _scanning = false;
    });
    await Store.saveScanResult(result.suspected.length);
    if (result.suspected.isNotEmpty && await Store.voiceOn()) {
      Speech.speak(S.ttsSpyWarn.of(widget.lang), widget.lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(
        title: Text(S.safetyScan.of(lang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _scanning ? null : _scan,
          ),
        ],
      ),
      body: _scanning
          ? _scanningView(lang)
          : ListView(
              children: [
                _summary(lang),
                ..._result!.suspected.map((a) => _spyCard(a, true, lang)),
                ..._result!.elevated.map((a) => _spyCard(a, false, lang)),
                const SizedBox(height: 8),
                SectionLabel(S.safetyHelp.of(lang)),
                HelpResourcesList(lang: lang),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _scanningView(String lang) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: CLColors.pink),
          const SizedBox(height: 16),
          Text(S.scanning.of(lang), style: CLTextStyles.body),
        ],
      ),
    );
  }

  Widget _summary(String lang) {
    final r = _result!;
    final clean = r.total == 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clean ? CLColors.greenLight : CLColors.redLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(clean ? '✅' : '🕵️', style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              clean
                  ? S.scanClean.of(lang)
                  : '${r.suspected.length} ${S.spySuspected.of(lang)} · ${r.elevated.length} ${S.spyElevated.of(lang)}',
              style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: clean ? CLColors.green : CLColors.redDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spyCard(ScannedApp app, bool suspected, String lang) {
    final v = _result!.verdicts[app.packageName]!;
    final accent = suspected ? CLColors.red : CLColors.amber;
    final accentDark = suspected ? CLColors.redDark : CLColors.amberDark;
    final accentLight = suspected ? CLColors.redLight : CLColors.amberLight;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent, width: suspected ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Text(suspected ? '🕵️' : '👁️',
                    style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(app.packageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CLTextStyles.siteTag),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: accentLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    (suspected ? S.spySuspected : S.spyElevated).of(lang),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: accentDark),
                  ),
                ),
              ],
            ),
          ),
          if (v.hidden)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
              child: Row(
                children: [
                  const Icon(Icons.visibility_off_rounded,
                      size: 14, color: CLColors.redDark),
                  const SizedBox(width: 6),
                  Text(S.hiddenApp.of(lang),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: CLColors.redDark)),
                ],
              ),
            ),
          // Signals
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.whySuspicious.of(lang).toUpperCase(),
                    style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: CLColors.textMuted,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                ...v.signals.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: accentDark)),
                          Expanded(
                              child: Text(s.of(lang),
                                  style: CLTextStyles.body)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          // Disclaimer
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
            child: Text(S.spyDisclaimer.of(lang),
                style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: CLColors.textMuted)),
          ),
          // Safety-first guidance (only for suspected)
          if (suspected)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CLColors.amberLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBD08A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💛', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(S.safetyFirstTitle.of(lang),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: CLColors.amberDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(S.safetyFirstBody.of(lang),
                      style: const TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: CLColors.amberDark)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showHelpSheet(lang),
                      icon: const Icon(Icons.support_agent_rounded, size: 18),
                      label: Text(S.getHelp.of(lang)),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showHelpSheet(String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CLColors.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  const Text('💛', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(S.safetyHelp.of(lang),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            HelpResourcesList(lang: lang),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
