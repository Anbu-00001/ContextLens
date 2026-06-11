// ── ConsentLens Smart Scan (Pillar 2) ───────────────────────────────────────
// Paste a message/link OR pick a screenshot → on-device OCR → local scam rule
// engine → Safe / Suspicious / Dangerous, spoken aloud, with a shareable rule
// card. Fully offline-capable (rules + OCR are on-device).

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../logic/i18n.dart';
import '../logic/ocr.dart';
import '../logic/scam_engine.dart';
import '../logic/speech.dart';
import '../logic/store.dart';
import '../theme.dart';

class ScamScanScreen extends StatefulWidget {
  final String lang;
  const ScamScanScreen({super.key, required this.lang});

  @override
  State<ScamScanScreen> createState() => _ScamScanScreenState();
}

class _ScamScanScreenState extends State<ScamScanScreen> {
  final _input = TextEditingController();
  ScamResult? _result;
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _scanText() async {
    final text = _input.text.trim();
    if (text.isEmpty) {
      _snack(S.emptyInput.of(widget.lang));
      return;
    }
    _present(scanText(text));
  }

  Future<void> _scanImage() async {
    setState(() => _busy = true);
    try {
      final picked =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) {
        setState(() => _busy = false);
        return;
      }
      final text = await Ocr.readImage(picked.path);
      if (text.trim().isEmpty) {
        setState(() => _busy = false);
        _snack(S.ocrFailed.of(widget.lang));
        return;
      }
      _input.text = text;
      _present(scanText(text, extractedText: text));
    } catch (_) {
      _snack(S.ocrFailed.of(widget.lang));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _present(ScamResult r) async {
    setState(() => _result = r);
    if (await Store.voiceOn()) {
      Speech.speak(r.spoken(widget.lang).of(widget.lang), widget.lang);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(title: Text(S.scamScan.of(lang))),
      body: ListView(
        children: [
          // Offline-capable note (the engine + OCR are on-device).
          Container(
            margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: CLColors.greenLight,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 15, color: CLColors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(S.offlineMode.of(lang),
                      style: const TextStyle(
                          fontSize: 11.5, color: CLColors.green)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: TextField(
              controller: _input,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: S.pasteMessage.of(lang),
                filled: true,
                fillColor: CLColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: CLColors.borderMid),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: CLColors.borderMid),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _scanImage,
                    icon: const Icon(Icons.image_rounded, size: 18),
                    label: Text(S.pickScreenshot.of(lang)),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _scanText,
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: Text(S.checkNow.of(lang)),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13)),
                  ),
                ),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: CircularProgressIndicator(color: CLColors.pink)),
            ),
          if (_result != null) ...[
            _resultCard(_result!, lang),
            if (_result!.topRule != null) _ruleCard(_result!, lang),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  ({Color bg, Color fg, String emoji, String label}) _style(ScamLevel l) {
    switch (l) {
      case ScamLevel.dangerous:
        return (
          bg: CLColors.redLight,
          fg: CLColors.redDark,
          emoji: '🛑',
          label: S.resultDangerous.of(widget.lang)
        );
      case ScamLevel.suspicious:
        return (
          bg: CLColors.amberLight,
          fg: CLColors.amberDark,
          emoji: '⚠️',
          label: S.resultSuspicious.of(widget.lang)
        );
      case ScamLevel.safe:
        return (
          bg: CLColors.greenLight,
          fg: CLColors.green,
          emoji: '✅',
          label: S.resultSafe.of(widget.lang)
        );
    }
  }

  Widget _resultCard(ScamResult r, String lang) {
    final s = _style(r.level);
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: s.bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(s.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Text(s.label,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: s.fg)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up_rounded, color: s.fg),
                onPressed: () =>
                    Speech.speak(r.spoken(lang).of(lang), lang),
              ),
            ],
          ),
          if (r.level == ScamLevel.safe)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child:
                  Text(S.safeBody.of(lang), style: TextStyle(fontSize: 13, color: s.fg, height: 1.4)),
            ),
          if (r.matched.isNotEmpty || r.badLinks.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(S.whatWeFound.of(lang).toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: s.fg.withValues(alpha: 0.8))),
            const SizedBox(height: 4),
            ...r.matched.map((m) => _bullet(m.reason.of(lang), s.fg)),
            ...r.badLinks.map((h) => _bullet(
                  L('Suspicious link: $h', 'संदिग्ध लिंक: $h', 'ಸಂಶಯಾಸ್ಪದ ಲಿಂಕ್: $h')
                      .of(lang),
                  s.fg,
                )),
          ],
        ],
      ),
    );
  }

  Widget _bullet(String text, Color fg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 13, height: 1.4, color: fg))),
        ],
      ),
    );
  }

  static const Map<String, IconData> _icons = {
    'password': Icons.password_rounded,
    'account_balance': Icons.account_balance_rounded,
    'emoji_events': Icons.emoji_events_rounded,
    'gavel': Icons.gavel_rounded,
    'currency_rupee': Icons.currency_rupee_rounded,
    'local_shipping': Icons.local_shipping_rounded,
    'bolt': Icons.bolt_rounded,
    'work': Icons.work_rounded,
  };

  Widget _ruleCard(ScamResult r, String lang) {
    final rule = r.topRule!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
          child: Text(S.ruleToRemember.of(lang).toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: CLColors.textMuted)),
        ),
        // Screenshot-able / shareable rule card.
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [CLColors.pink, CLColors.pinkDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(_icons[rule.icon] ?? Icons.verified_user_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rule.rule.of(lang),
                        style: const TextStyle(
                            fontSize: 17,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('ConsentLens · SheSafe',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Share.share(
                  '${rule.rule.of(lang)}\n\n— ConsentLens (SheSafe safety tip)'),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(S.shareRule.of(lang)),
            ),
          ),
        ),
      ],
    );
  }
}
