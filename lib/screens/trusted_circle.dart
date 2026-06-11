// ── ConsentLens Trusted Circle (Pillar 5: 5.1 + 5.3) ───────────────────────
// Nominate 1–2 trusted people (manual entry — no contacts permission). Alert
// them or send a weekly safety summary via an `smsto:` intent that opens the
// user's own SMS app pre-filled (no SEND_SMS permission). The trusted person
// needs nothing installed.

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../logic/i18n.dart';
import '../logic/store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class TrustedCircleScreen extends StatefulWidget {
  final String lang;
  const TrustedCircleScreen({super.key, required this.lang});

  @override
  State<TrustedCircleScreen> createState() => _TrustedCircleScreenState();
}

class _TrustedCircleScreenState extends State<TrustedCircleScreen> {
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    Store.trustedContacts().then((c) => setState(() => _contacts = c));
  }

  Future<void> _save() async => Store.saveTrusted(_contacts);

  Future<void> _sms(String number, String body) async {
    final uri = Uri.parse('smsto:$number?body=${Uri.encodeComponent(body)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _summary() async {
    final history = await Store.history();
    final week = DateTime.now().subtract(const Duration(days: 7));
    final recent = history
        .where((h) =>
            DateTime.fromMillisecondsSinceEpoch(h.timestamp).isAfter(week))
        .toList();
    final flagged = recent.where((h) => h.high).length;
    final lang = widget.lang;
    final text = L(
      'ConsentLens weekly safety update: ${recent.length} apps/messages checked this week, $flagged flagged as risky. I am staying alert. No private details shared.',
      'कंसेंटलेंस साप्ताहिक सुरक्षा अपडेट: इस हफ़्ते ${recent.length} ऐप/संदेश जाँचे, $flagged जोखिम भरे मिले। मैं सतर्क हूँ। कोई निजी जानकारी नहीं।',
      'ಕನ್ಸೆಂಟ್‌ಲೆನ್ಸ್ ವಾರದ ಸುರಕ್ಷತಾ ಅಪ್‌ಡೇಟ್: ಈ ವಾರ ${recent.length} ಆ್ಯಪ್/ಸಂದೇಶ ಪರಿಶೀಲಿಸಿದೆ, $flagged ಅಪಾಯಕಾರಿ. ನಾನು ಎಚ್ಚರವಾಗಿದ್ದೇನೆ. ಖಾಸಗಿ ವಿವರಗಳಿಲ್ಲ.',
    ).of(lang);
    if (_contacts.isNotEmpty) {
      _sms(_contacts.first['number']!, text);
    } else {
      Share.share(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(title: Text(S.trustedCircle.of(lang))),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(S.trustedCircleSub.of(lang),
                style: const TextStyle(fontSize: 13, color: CLColors.textSec)),
          ),
          // Existing contacts
          ..._contacts.asMap().entries.map((e) {
            final c = e.value;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: CLColors.pinkLight, shape: BoxShape.circle),
                      child: const Icon(Icons.person_rounded,
                          color: CLColors.pink),
                    ),
                    title: Text(c['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(c['number'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: CLColors.textMuted),
                      onPressed: () async {
                        setState(() => _contacts.removeAt(e.key));
                        await _save();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _sms(
                                c['number']!,
                                L(
                                  'Hi ${c['name']}, I added you as my safety contact on ConsentLens. You may get a message if I ever need help.',
                                  'नमस्ते ${c['name']}, मैंने आपको कंसेंटलेंस पर अपना सुरक्षा संपर्क बनाया है। ज़रूरत होने पर संदेश आ सकता है।',
                                  'ನಮಸ್ಕಾರ ${c['name']}, ನಾನು ನಿಮ್ಮನ್ನು ಕನ್ಸೆಂಟ್‌ಲೆನ್ಸ್‌ನಲ್ಲಿ ನನ್ನ ಸುರಕ್ಷತಾ ಸಂಪರ್ಕ ಮಾಡಿದ್ದೇನೆ. ಅಗತ್ಯವಿದ್ದರೆ ಸಂದೇಶ ಬರಬಹುದು.',
                                ).of(lang)),
                            icon: const Icon(Icons.sms_rounded, size: 16),
                            label: Text(S.sendIntro.of(lang),
                                style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _sms(
                                c['number']!,
                                L(
                                  '${c['name']}, I have flagged a safety concern and may need your support. Please call me. (Sent via ConsentLens)',
                                  '${c['name']}, मैंने एक सुरक्षा चिंता दर्ज की है और मुझे आपकी मदद चाहिए। कृपया कॉल करें। (कंसेंटलेंस से)',
                                  '${c['name']}, ನಾನು ಸುರಕ್ಷತಾ ಕಳವಳ ಗುರುತಿಸಿದ್ದೇನೆ, ನಿಮ್ಮ ಸಹಾಯ ಬೇಕು. ದಯವಿಟ್ಟು ಕರೆ ಮಾಡಿ. (ಕನ್ಸೆಂಟ್‌ಲೆನ್ಸ್)',
                                ).of(lang)),
                            icon: const Icon(Icons.warning_rounded, size: 16),
                            label: Text(S.alertContact.of(lang),
                                style: const TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CLColors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          if (_contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(S.noTrusted.of(lang), style: CLTextStyles.body),
            ),

          // Add new (max 2)
          if (_contacts.length < 2)
            Padding(
              padding: const EdgeInsets.all(14),
              child: OutlinedButton.icon(
                onPressed: () => _addDialog(lang),
                icon: const Icon(Icons.person_add_rounded),
                label: Text(S.addTrusted.of(lang)),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
              ),
            ),

          // Weekly summary (5.3)
          if (_contacts.isNotEmpty) ...[
            const SizedBox(height: 6),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              child: ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: CLColors.blueLight,
                      borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.summarize_rounded,
                      color: CLColors.blue, size: 20),
                ),
                title: Text(S.weeklySummary.of(lang),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(S.weeklySummarySub.of(lang),
                    style: const TextStyle(
                        fontSize: 11, color: CLColors.textMuted)),
                onTap: _summary,
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _addDialog(String lang) {
    final name = TextEditingController();
    final number = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.addTrusted.of(lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: S.contactName.of(lang)),
            ),
            TextField(
              controller: number,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: S.contactNumber.of(lang)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final n = name.text.trim();
              final num = number.text.trim();
              if (n.isEmpty || num.isEmpty) return;
              setState(() => _contacts.add({'name': n, 'number': num}));
              await _save();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(S.saveContact.of(lang)),
          ),
        ],
      ),
    );
  }
}
