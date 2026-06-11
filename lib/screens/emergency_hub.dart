// ── ConsentLens Emergency Response Hub ──────────────────────────────────────
// Crisis screen: one-tap 1930, a complaint-template generator for
// cybercrime.gov.in, and a WhatsApp reporting path. Minimal friction.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../logic/i18n.dart';
import '../logic/safety_resources.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class EmergencyHubScreen extends StatelessWidget {
  final String lang;
  const EmergencyHubScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(title: Text(S.emergencyHub.of(lang))),
      body: ListView(
        children: [
          // ── Big one-tap 1930 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Material(
              color: CLColors.red,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => launchHelp('tel:1930'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.call1930.of(lang),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(S.call1930Sub.of(lang),
                                style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.3,
                                    color: Colors.white.withValues(alpha: 0.9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Prepare report ──
          Card(
            margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: ExpansionTile(
              shape: const Border(),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: CLColors.amberLight,
                    borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.description_rounded,
                    color: CLColors.amber, size: 20),
              ),
              title: Text(S.prepareReport.of(lang),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(S.prepareReportSub.of(lang),
                  style: const TextStyle(fontSize: 11, color: CLColors.textMuted)),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              children: [_ReportForm(lang: lang)],
            ),
          ),

          // ── WhatsApp report ──
          Card(
            margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: CLColors.greenLight,
                    borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.chat_rounded,
                    color: CLColors.green, size: 20),
              ),
              title: Text(S.reportViaWhatsapp.of(lang),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(S.reportViaWhatsappSub.of(lang),
                  style: const TextStyle(fontSize: 11, color: CLColors.textMuted)),
              trailing: const Icon(Icons.open_in_new_rounded,
                  size: 18, color: CLColors.textMuted),
              onTap: () {
                final msg = Uri.encodeComponent(
                    'I received a fraud message. I am forwarding it below. Please take action.');
                launchHelp('https://wa.me/?text=$msg');
              },
            ),
          ),

          SectionLabel(S.safetyHelp.of(lang)),
          HelpResourcesList(lang: lang),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ReportForm extends StatefulWidget {
  final String lang;
  const _ReportForm({required this.lang});

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final _amount = TextEditingController();
  final _when = TextEditingController();
  final _what = TextEditingController();
  final _txn = TextEditingController();
  String? _generated;

  @override
  void dispose() {
    _amount.dispose();
    _when.dispose();
    _what.dispose();
    _txn.dispose();
    super.dispose();
  }

  String _build() {
    final amount = _amount.text.trim();
    final when = _when.text.trim();
    final what = _what.text.trim();
    final txn = _txn.text.trim();
    final b = StringBuffer();
    b.write('I wish to report an online financial fraud / cyber crime.');
    if (when.isNotEmpty) b.write(' Date of incident: $when.');
    if (amount.isNotEmpty) b.write(' Amount involved: Rs $amount.');
    if (txn.isNotEmpty) b.write(' Transaction/Reference ID: $txn.');
    if (what.isNotEmpty) b.write(' What happened: $what.');
    b.write(
        ' I request you to register my complaint and help recover/freeze the amount. '
        'Filed via National Cyber Crime Reporting Portal (cybercrime.gov.in) / helpline 1930.');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(_amount, S.reportAmount.of(lang), TextInputType.number),
        _field(_when, S.reportWhen.of(lang), TextInputType.datetime),
        _field(_txn, S.reportTxn.of(lang), TextInputType.text),
        _field(_what, S.reportWhat.of(lang), TextInputType.multiline, lines: 2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _generated = _build()),
                child: Text(S.generateReport.of(lang)),
              ),
            ),
          ],
        ),
        if (_generated != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CLColors.border),
            ),
            child: Text(_generated!,
                style: const TextStyle(fontSize: 12.5, height: 1.45)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generated!));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(S.copied.of(lang)),
                        duration: const Duration(seconds: 1)));
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: Text(S.copyReport.of(lang)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchUrl(
                      Uri.parse('https://cybercrime.gov.in'),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(S.openPortal.of(lang)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _field(TextEditingController c, String hint, TextInputType type,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        keyboardType: type,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: CLColors.borderMid),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: CLColors.borderMid),
          ),
        ),
      ),
    );
  }
}
