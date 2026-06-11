// ── ConsentLens on-device scam scanner ─────────────────────────────────────
// Rule-based, 100% local (works offline). Scans message/link text against the
// 2026 India scam taxonomy: KYC/Aadhaar block, lottery/KBC, digital arrest,
// UPI refund-PIN, courier/customs, FASTag, job-fee, OTP, plus urgency cues and
// suspicious links (reusing the domain threat heuristics).

import 'i18n.dart';
import 'threat.dart';

enum ScamLevel { safe, suspicious, dangerous }

class ScamRule {
  final String id;
  final List<String> keywords; // lowercase substrings / simple tokens
  final ScamLevel weight; // severity if this rule alone matches
  final L reason;
  final String icon; // material icon key (mapped in UI)
  final L rule; // ≤ ~8-word rule card line

  const ScamRule({
    required this.id,
    required this.keywords,
    required this.weight,
    required this.reason,
    required this.icon,
    required this.rule,
  });
}

const List<ScamRule> scamRules = [
  ScamRule(
    id: 'otp',
    keywords: ['otp', 'one time password', 'one-time password', 'verification code',
      'do not share', 'share the code', 'enter otp'],
    weight: ScamLevel.dangerous,
    icon: 'password',
    reason: L('Asks about an OTP. OTPs must never be shared.',
        'OTP की बात करता है। OTP कभी शेयर न करें।',
        'OTP ಬಗ್ಗೆ ಕೇಳುತ್ತದೆ. OTP ಎಂದಿಗೂ ಹಂಚಬೇಡಿ.'),
    rule: L('Never share an OTP with anyone.',
        'OTP किसी के साथ कभी शेयर न करें।',
        'OTP ಯಾರಿಗೂ ಎಂದಿಗೂ ಹಂಚಬೇಡಿ.'),
  ),
  ScamRule(
    id: 'kyc',
    keywords: ['kyc', 'aadhaar', 'aadhar', 'pan card', 'account blocked',
      'account suspended', 'account will be', 'sim will be blocked', 'update your',
      're-kyc', 'pan update'],
    weight: ScamLevel.dangerous,
    icon: 'account_balance',
    reason: L('Threatens to block your account/KYC. Banks never do this by SMS.',
        'खाता/KYC ब्लॉक करने की धमकी। बैंक SMS से ऐसा नहीं करते।',
        'ಖಾತೆ/KYC ನಿರ್ಬಂಧಿಸುವ ಬೆದರಿಕೆ. ಬ್ಯಾಂಕ್ SMS ನಲ್ಲಿ ಹೀಗೆ ಮಾಡುವುದಿಲ್ಲ.'),
    rule: L('Banks never block KYC over an SMS link.',
        'बैंक SMS लिंक से KYC ब्लॉक नहीं करते।',
        'ಬ್ಯಾಂಕ್ SMS ಲಿಂಕ್‌ನಿಂದ KYC ನಿರ್ಬಂಧಿಸುವುದಿಲ್ಲ.'),
  ),
  ScamRule(
    id: 'lottery',
    keywords: ['lottery', 'lucky draw', 'you won', 'you have won', 'winner',
      'kbc', 'jackpot', 'prize', 'lakh', 'crore', 'claim your', 'congratulations'],
    weight: ScamLevel.dangerous,
    icon: 'emoji_events',
    reason: L('Claims you won a prize. This is a classic trap.',
        'इनाम जीतने का दावा। यह एक आम जाल है।',
        'ಬಹುಮಾನ ಗೆದ್ದಿರಿ ಎನ್ನುತ್ತದೆ. ಇದು ಸಾಮಾನ್ಯ ಬಲೆ.'),
    rule: L("You can't win a lottery you never entered.",
        'जिस लॉटरी में भाग नहीं लिया, वह नहीं जीत सकते।',
        'ಭಾಗವಹಿಸದ ಲಾಟರಿಯನ್ನು ಗೆಲ್ಲಲಾಗದು.'),
  ),
  ScamRule(
    id: 'digital_arrest',
    keywords: ['digital arrest', 'police', 'cbi', 'narcotics', 'ncb', 'customs',
      'court', 'fir', 'arrest warrant', 'money laundering', 'illegal parcel',
      'under investigation', 'enforcement directorate'],
    weight: ScamLevel.dangerous,
    icon: 'gavel',
    reason: L('Pretends to be police/court to scare you. Police never do this online.',
        'डराने के लिए पुलिस/कोर्ट बनता है। पुलिस ऑनलाइन ऐसा नहीं करती।',
        'ಹೆದರಿಸಲು ಪೊಲೀಸ್/ನ್ಯಾಯಾಲಯ ಎಂದು ನಟಿಸುತ್ತದೆ. ಪೊಲೀಸ್ ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ಹೀಗೆ ಮಾಡುವುದಿಲ್ಲ.'),
    rule: L('Police never arrest you over a video call.',
        'पुलिस वीडियो कॉल पर गिरफ़्तार नहीं करती।',
        'ಪೊಲೀಸ್ ವೀಡಿಯೊ ಕರೆಯಲ್ಲಿ ಬಂಧಿಸುವುದಿಲ್ಲ.'),
  ),
  ScamRule(
    id: 'upi',
    keywords: ['upi', 'enter your pin', 'enter pin', 'collect request',
      'to receive', 'refund', 'cashback', 'payment pending', 'approve the request'],
    weight: ScamLevel.dangerous,
    icon: 'currency_rupee',
    reason: L('Asks you to enter UPI PIN to "receive" money. That sends money out.',
        'पैसे "पाने" के लिए UPI PIN माँगता है। इससे पैसे चले जाते हैं।',
        'ಹಣ "ಪಡೆಯಲು" UPI PIN ಕೇಳುತ್ತದೆ. ಇದರಿಂದ ಹಣ ಹೋಗುತ್ತದೆ.'),
    rule: L('UPI PIN sends money — never receives it.',
        'UPI PIN पैसे भेजता है — पाता नहीं।',
        'UPI PIN ಹಣ ಕಳುಹಿಸುತ್ತದೆ — ಪಡೆಯುವುದಿಲ್ಲ.'),
  ),
  ScamRule(
    id: 'courier',
    keywords: ['fedex', 'courier', 'parcel', 'package', 'delivery failed',
      'dtdc', 'bluedart', 'customs duty', 'shipment', 'redelivery', 'held at'],
    weight: ScamLevel.suspicious,
    icon: 'local_shipping',
    reason: L('Fake courier/parcel message asking for a fee or details.',
        'फर्जी कूरियर/पार्सल संदेश जो फ़ीस या जानकारी माँगता है।',
        'ನಕಲಿ ಕೊರಿಯರ್/ಪಾರ್ಸೆಲ್ ಸಂದೇಶ, ಶುಲ್ಕ ಅಥವಾ ಮಾಹಿತಿ ಕೇಳುತ್ತದೆ.'),
    rule: L("Couriers don't ask for fees by SMS link.",
        'कूरियर SMS लिंक से फ़ीस नहीं माँगते।',
        'ಕೊರಿಯರ್‌ಗಳು SMS ಲಿಂಕ್‌ನಿಂದ ಶುಲ್ಕ ಕೇಳುವುದಿಲ್ಲ.'),
  ),
  ScamRule(
    id: 'fastag_bill',
    keywords: ['fastag', 'electricity', 'bill', 'disconnect', 'gas kyc',
      'power will be', 'meter', 'recharge now', 'bijli'],
    weight: ScamLevel.suspicious,
    icon: 'bolt',
    reason: L('Fake bill / FASTag / disconnection threat to rush you.',
        'जल्दबाज़ी कराने के लिए फर्जी बिल/FASTag/कनेक्शन कटने की धमकी।',
        'ಅವಸರ ಮಾಡಿಸಲು ನಕಲಿ ಬಿಲ್/FASTag/ಸಂಪರ್ಕ ಕಡಿತ ಬೆದರಿಕೆ.'),
    rule: L('Pay bills only inside official apps.',
        'बिल सिर्फ़ आधिकारिक ऐप में ही भरें।',
        'ಬಿಲ್‌ಗಳನ್ನು ಅಧಿಕೃತ ಆ್ಯಪ್‌ನಲ್ಲಿ ಮಾತ್ರ ಪಾವತಿಸಿ.'),
  ),
  ScamRule(
    id: 'job',
    keywords: ['work from home', 'part time job', 'earn daily', 'earn money',
      'registration fee', 'joining fee', 'per day', 'easy income', 'task job',
      'telegram', 'like and earn'],
    weight: ScamLevel.suspicious,
    icon: 'work',
    reason: L('Too-good job that asks for a fee first.',
        'बहुत अच्छी नौकरी जो पहले फ़ीस माँगती है।',
        'ಮೊದಲು ಶುಲ್ಕ ಕೇಳುವ ತುಂಬಾ ಒಳ್ಳೆಯ ಕೆಲಸ.'),
    rule: L('Real jobs never ask you to pay first.',
        'असली नौकरी पहले पैसे नहीं माँगती।',
        'ನಿಜವಾದ ಕೆಲಸ ಮೊದಲು ಹಣ ಕೇಳುವುದಿಲ್ಲ.'),
  ),
];

// Words that add urgency/pressure — amplify the verdict.
const List<String> _urgencyCues = [
  'immediately', 'urgent', 'within 24', 'act now', 'last warning', 'right now',
  'or else', 'expire', 'expiring', 'final notice', 'turant', 'jaldi', '24 hours',
  'verify now', 'click here', 'click below', 'limited time',
];

class ScamResult {
  final ScamLevel level;
  final List<ScamRule> matched;
  final List<String> badLinks; // suspicious URLs found
  final bool urgency;
  final String? extractedText; // when scanned from an image

  const ScamResult({
    required this.level,
    required this.matched,
    required this.badLinks,
    required this.urgency,
    this.extractedText,
  });

  /// The single most relevant rule card to show / share.
  ScamRule? get topRule => matched.isEmpty ? null : matched.first;

  L spoken(String lang) {
    switch (level) {
      case ScamLevel.dangerous:
        final r = topRule;
        return L(
          'Danger. This looks like a scam. Do not click, pay, or share anything. ${r?.rule.en ?? ''}',
          'खतरा। यह ठगी लगती है। कुछ भी क्लिक, भुगतान या शेयर न करें। ${r?.rule.hi ?? ''}',
          'ಅಪಾಯ. ಇದು ಮೋಸದಂತಿದೆ. ಯಾವುದನ್ನೂ ಕ್ಲಿಕ್, ಪಾವತಿ ಅಥವಾ ಹಂಚಬೇಡಿ. ${r?.rule.kn ?? ''}',
        );
      case ScamLevel.suspicious:
        return const L(
          'Be careful. This message looks suspicious. Do not share money or details until you are sure.',
          'सावधान रहें। यह संदेश संदिग्ध लगता है। पक्का होने तक पैसे या जानकारी न दें।',
          'ಎಚ್ಚರ. ಈ ಸಂದೇಶ ಸಂಶಯಾಸ್ಪದ. ಖಚಿತವಾಗುವವರೆಗೆ ಹಣ ಅಥವಾ ಮಾಹಿತಿ ಹಂಚಬೇಡಿ.',
        );
      case ScamLevel.safe:
        return const L(
          'No common scam signs found. Still be careful with money and OTPs.',
          'कोई आम ठगी का संकेत नहीं मिला। फिर भी पैसे और OTP को लेकर सतर्क रहें।',
          'ಸಾಮಾನ್ಯ ಮೋಸದ ಚಿಹ್ನೆಗಳಿಲ್ಲ. ಆದರೂ ಹಣ ಮತ್ತು OTP ಬಗ್ಗೆ ಎಚ್ಚರವಾಗಿರಿ.',
        );
    }
  }
}

final RegExp _urlRe =
    RegExp(r'(https?://[^\s]+|www\.[^\s]+|[a-z0-9-]+\.[a-z]{2,}(/[^\s]*)?)',
        caseSensitive: false);

ScamResult scanText(String input, {String? extractedText}) {
  final text = input.toLowerCase();
  if (text.trim().isEmpty) {
    return ScamResult(
        level: ScamLevel.safe,
        matched: const [],
        badLinks: const [],
        urgency: false,
        extractedText: extractedText);
  }

  final matched = <ScamRule>[];
  for (final rule in scamRules) {
    if (rule.keywords.any((k) => text.contains(k))) matched.add(rule);
  }
  // Strongest-severity rule first so topRule is the headline.
  matched.sort((a, b) => b.weight.index.compareTo(a.weight.index));

  final urgency = _urgencyCues.any((c) => text.contains(c));

  // Extract and assess links.
  final badLinks = <String>[];
  for (final m in _urlRe.allMatches(input)) {
    final url = m.group(0)!;
    final host = hostOf(url);
    if (host.isEmpty || !host.contains('.')) continue;
    final v = assessDomain(url);
    final shortener = RegExp(r'(^|\.)(bit\.ly|tinyurl\.com|t\.co|cutt\.ly|rb\.gy|is\.gd)$')
        .hasMatch(host);
    if (v.shady || shortener) badLinks.add(host);
  }

  // Verdict.
  final hasDangerRule = matched.any((r) => r.weight == ScamLevel.dangerous);
  ScamLevel level;
  if (hasDangerRule || badLinks.isNotEmpty) {
    level = ScamLevel.dangerous;
  } else if (matched.isNotEmpty) {
    level = urgency ? ScamLevel.dangerous : ScamLevel.suspicious;
  } else if (urgency) {
    level = ScamLevel.suspicious;
  } else {
    level = ScamLevel.safe;
  }

  return ScamResult(
    level: level,
    matched: matched,
    badLinks: badLinks,
    urgency: urgency,
    extractedText: extractedText,
  );
}
