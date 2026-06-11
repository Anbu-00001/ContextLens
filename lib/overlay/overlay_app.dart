// ── ConsentLens overlay popup ───────────────────────────────────────────────
// Rendered in a second Flutter engine inside a system overlay window
// (TYPE_APPLICATION_OVERLAY), shown by MonitorService whenever the user
// opens another app. Same ConsentLens design language as the main app.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/i18n.dart';
import '../logic/risk_engine.dart';
import '../logic/speech.dart';
import '../logic/store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

const _overlayCh = MethodChannel('consentlens/overlay');

class OverlayApp extends StatefulWidget {
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  AppReport? _report;
  String _lang = 'en';
  String _userMode = 'adult';
  String _ageTab = 'adults'; // which age group's risks are expanded

  @override
  void initState() {
    super.initState();
    _overlayCh.setMethodCallHandler((call) async {
      if (call.method == 'show') {
        await _load(call.arguments as String?);
      }
      return null;
    });
    // Pull the payload in case Kotlin sent it before our handler was ready.
    _overlayCh.invokeMethod<String>('getPayload').then(_load).catchError((_) {});
  }

  Future<void> _load(String? payload) async {
    if (payload == null || payload.isEmpty) return;
    final m = (jsonDecode(payload) as Map).cast<String, dynamic>();
    final isWeb = (m['kind'] as String?) == 'web';
    final report = isWeb
        ? buildWebReport(
            m['site'] as String,
            ((m['perms'] as List?) ?? []).cast<String>(),
          )
        : buildReport(
            m['pkg'] as String,
            m['name'] as String,
            ((m['perms'] as List?) ?? []).cast<String>(),
          );
    final lang = await Store.language();
    final mode = await Store.userMode();
    final voice = await Store.voiceOn();

    setState(() {
      _report = report;
      _lang = lang;
      _userMode = mode;
      _ageTab = mode == 'child' ? 'kids' : 'adults';
    });

    await Store.addHistory(HistoryEntry(
      pkg: report.packageName,
      appName: report.appName,
      high: report.overallHigh,
      catCount: report.categories.length,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));

    if (voice) _speak(report, lang, mode);
  }

  void _speak(AppReport r, String lang, String mode) {
    var text = S.ttsSummary
        .of(lang)
        .replaceAll('{app}', r.appName)
        .replaceAll('{n}', '${r.categories.length}')
        .replaceAll('{risk}', r.overallLabel.of(lang));
    if (r.shady) {
      text = '${S.ttsThreat.of(lang)} $text';
    } else if (mode == 'child' && r.kidsFit != Fit.ok) {
      text = '${S.ttsChildWarn.of(lang)} $text';
    }
    Speech.speak(text, lang);
  }

  void _close() {
    Speech.stop();
    _overlayCh.invokeMethod('close');
  }

  @override
  Widget build(BuildContext context) {
    final r = _report;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: consentLensTheme(),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: r == null
            ? const SizedBox.shrink()
            : GestureDetector(
                onTap: _close,
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {}, // swallow taps inside the sheet
                    child: _buildSheet(r),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSheet(AppReport r) {
    final isChild = _userMode == 'child';
    final severe = r.shady || (isChild && r.kidsFit != Fit.ok);
    final maxH = MediaQuery.of(context).size.height * (severe ? 0.88 : 0.78);

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: CLColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(r, severe),
          if (r.shady) _threatBanner(r) else if (severe) _childAlertBanner(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                if (r.isWebsite && !r.shady) _websiteNote(),
                if (r.isBrowser) _browserNote(),
                _ageFitSection(r),
                SectionLabel(
                    '${r.categories.length} ${S.permsDetected.of(_lang)}'),
                if (r.categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(S.noRiskyPerms.of(_lang),
                        style: CLTextStyles.body, textAlign: TextAlign.center),
                  ),
                ...r.categories.map((c) => CategoryCard(
                    category: c, lang: _lang, userMode: _userMode)),
                const SizedBox(height: 8),
              ],
            ),
          ),
          _actions(r),
        ],
      ),
    );
  }

  Widget _header(AppReport r, bool severe) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
        color: severe ? CLColors.redLight : CLColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: const Border(bottom: BorderSide(color: CLColors.border)),
      ),
      child: Row(
        children: [
          const CLLogo(size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CLColors.textPrimary)),
                Row(
                  children: [
                    Text('${S.overallRisk.of(_lang)}: ',
                        style: const TextStyle(
                            fontSize: 11, color: CLColors.textMuted)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(
                        color: r.overallHigh
                            ? CLColors.redLight
                            : CLColors.greenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r.overallLabel.of(_lang),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: r.overallHigh
                                ? CLColors.redDark
                                : CLColors.green),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ModeBadge(mode: _userMode, lang: _lang),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: CLColors.pink),
            tooltip: 'Voice',
            onPressed: () => _speak(r, _lang, _userMode),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: CLColors.textSec),
            onPressed: _close,
          ),
        ],
      ),
    );
  }

  Widget _childAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: CLColors.red,
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              S.childAlert.of(_lang),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _threatBanner(AppReport r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CLColors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛑', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                S.dangerousSite.of(_lang),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            S.threatWarn.of(_lang),
            style: const TextStyle(
                fontSize: 13, height: 1.4, color: Colors.white),
          ),
          if (r.threatReason != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️ ${r.threatReason!.of(_lang)}',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white, height: 1.35),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _websiteNote() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CLColors.blueLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('🌐', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(S.websiteWants.of(_lang),
                style: const TextStyle(
                    fontSize: 11.5, color: CLColors.blue, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _browserNote() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CLColors.blueLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('🌐', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(S.browserNote.of(_lang),
                style: const TextStyle(
                    fontSize: 11.5, color: CLColors.blue, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _ageFitSection(AppReport r) {
    final risks = _ageRisks(r, _ageTab);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(S.suitableFor.of(_lang)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                  child: _tappableFit('kids', S.kids.of(_lang), r.kidsFit)),
              const SizedBox(width: 8),
              Expanded(
                  child: _tappableFit('teens', S.teens.of(_lang), r.teensFit)),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      _tappableFit('adults', S.adults.of(_lang), r.adultsFit)),
            ],
          ),
        ),
        if (risks.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CLColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CLColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_ageTab == 'kids'
                          ? S.risksAsKid
                          : _ageTab == 'teens'
                              ? S.risksAsTeen
                              : S.risksAsAdult)
                      .of(_lang)
                      .toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CLColors.textMuted,
                      letterSpacing: 0.7),
                ),
                const SizedBox(height: 6),
                ...risks.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(color: CLColors.pink)),
                          Expanded(child: Text(t, style: CLTextStyles.body)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tappableFit(String key, String label, Fit fit) {
    final selected = _ageTab == key;
    return GestureDetector(
      onTap: () => setState(() => _ageTab = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? CLColors.pink : Colors.transparent,
              width: 2),
        ),
        child: FitChip(label: label, fit: fit, lang: _lang),
      ),
    );
  }

  List<String> _ageRisks(AppReport r, String age) {
    final seen = <String>{};
    final out = <String>[];
    for (final c in r.categories) {
      final L l = age == 'kids'
          ? c.kidRisk
          : age == 'teens'
              ? c.teenRisk
              : c.adultRisk;
      final t = l.of(_lang);
      if (seen.add(t)) out.add(t);
    }
    return out;
  }

  Widget _actions(AppReport r) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      decoration: const BoxDecoration(
        color: CLColors.white,
        border: Border(top: BorderSide(color: CLColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _overlayCh
                    .invokeMethod('openAppDetails', {'pkg': r.packageName});
                _close();
              },
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Text(S.appSettings.of(_lang)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _close,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Text(S.gotIt.of(_lang)),
            ),
          ),
        ],
      ),
    );
  }
}
