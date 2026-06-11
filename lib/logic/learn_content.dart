// ── ConsentLens Learning Sandbox content (Pillar 3 + Photo-Misuse 1.3) ─────
// All content is trilingual and on-device. Illustrated with emojis so it works
// for low-literacy users; every lesson can be narrated by TTS.

import 'i18n.dart';

// ── Micro-lessons (illustrated stories, narrated) — Features 3.1 + 1.3 ─────
class StoryCard {
  final String emoji;
  final L text;
  const StoryCard(this.emoji, this.text);
}

class MicroLesson {
  final String id;
  final String emoji;
  final L title;
  final List<StoryCard> cards;
  final List<L> steps; // "What to do"
  const MicroLesson({
    required this.id,
    required this.emoji,
    required this.title,
    required this.cards,
    required this.steps,
  });

  /// Full narration text for TTS.
  L narration() {
    String join(String Function(L) pick) =>
        cards.map((c) => pick(c.text)).join(' ');
    return L(join((l) => l.en), join((l) => l.hi), join((l) => l.kn));
  }
}

const List<MicroLesson> microLessons = [
  // Feature 1.3 — Photo Misuse Awareness
  MicroLesson(
    id: 'photo_misuse',
    emoji: '📸',
    title: L('How photos get misused', 'फ़ोटो का गलत इस्तेमाल कैसे होता है',
        'ಫೋಟೋ ದುರ್ಬಳಕೆ ಹೇಗೆ'),
    cards: [
      StoryCard('🖼️', L('You post a normal photo in a group.',
          'आप एक ग्रुप में सामान्य फ़ोटो डालते हैं।',
          'ನೀವು ಗುಂಪಿನಲ್ಲಿ ಸಾಮಾನ್ಯ ಫೋಟೋ ಹಾಕುತ್ತೀರಿ.')),
      StoryCard('👤', L('A stranger downloads it without asking.',
          'एक अजनबी बिना पूछे उसे डाउनलोड कर लेता है।',
          'ಅಪರಿಚಿತ ಕೇಳದೆ ಅದನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡುತ್ತಾನೆ.')),
      StoryCard('🩹', L('They edit it into a fake, harmful image (morphing).',
          'वे उसे नकली, हानिकारक तस्वीर में बदल देते हैं (मॉर्फिंग)।',
          'ಅವರು ಅದನ್ನು ನಕಲಿ, ಹಾನಿಕಾರಕ ಚಿತ್ರವಾಗಿ ಬದಲಿಸುತ್ತಾರೆ (ಮಾರ್ಫಿಂಗ್).')),
      StoryCard('🛡️', L('You can stop it — report and it gets removed.',
          'आप इसे रोक सकते हैं — रिपोर्ट करें और हटवा दें।',
          'ನೀವು ತಡೆಯಬಹುದು — ವರದಿ ಮಾಡಿ ತೆಗೆಸಬಹುದು.')),
    ],
    steps: [
      L('Take a screenshot — do not delete the proof.',
          'स्क्रीनशॉट लें — सबूत न हटाएँ।',
          'ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ತೆಗೆಯಿರಿ — ಪುರಾವೆ ಅಳಿಸಬೇಡಿ.'),
      L('Report on cybercrime.gov.in or call 1930.',
          'cybercrime.gov.in पर रिपोर्ट करें या 1930 पर कॉल करें।',
          'cybercrime.gov.in ನಲ್ಲಿ ವರದಿ ಮಾಡಿ ಅಥವಾ 1930 ಗೆ ಕರೆ ಮಾಡಿ.'),
      L('Block the person and tell someone you trust.',
          'उस व्यक्ति को ब्लॉक करें और किसी भरोसेमंद को बताएँ।',
          'ಆ ವ್ಯಕ್ತಿಯನ್ನು ಬ್ಲಾಕ್ ಮಾಡಿ, ನಂಬುವವರಿಗೆ ತಿಳಿಸಿ.'),
      L('Keep your photos private — share only with people you know.',
          'अपनी फ़ोटो निजी रखें — सिर्फ़ जान-पहचान वालों से शेयर करें।',
          'ನಿಮ್ಮ ಫೋಟೋ ಖಾಸಗಿಯಾಗಿಡಿ — ಪರಿಚಿತರೊಂದಿಗೆ ಮಾತ್ರ ಹಂಚಿ.'),
    ],
  ),
  MicroLesson(
    id: 'otp_lesson',
    emoji: '🔑',
    title: L('The OTP trap', 'OTP का जाल', 'OTP ಬಲೆ'),
    cards: [
      StoryCard('📞', L('Someone calls saying they are from your bank.',
          'कोई कॉल करके कहता है कि वह आपके बैंक से है।',
          'ಯಾರೋ ಕರೆ ಮಾಡಿ ತಾವು ನಿಮ್ಮ ಬ್ಯಾಂಕ್‌ನಿಂದ ಎನ್ನುತ್ತಾರೆ.')),
      StoryCard('🔢', L('They ask for the OTP sent to your phone.',
          'वे आपके फ़ोन पर आए OTP को माँगते हैं।',
          'ನಿಮ್ಮ ಫೋನಿಗೆ ಬಂದ OTP ಕೇಳುತ್ತಾರೆ.')),
      StoryCard('💸', L('If you share it, money leaves your account.',
          'अगर आप बता देते हैं, तो खाते से पैसे चले जाते हैं।',
          'ನೀವು ಹೇಳಿದರೆ, ಖಾತೆಯಿಂದ ಹಣ ಹೋಗುತ್ತದೆ.')),
      StoryCard('🙅‍♀️', L('Never share an OTP. Banks never ask for it.',
          'OTP कभी न बताएँ। बैंक कभी नहीं माँगते।',
          'OTP ಎಂದಿಗೂ ಹೇಳಬೇಡಿ. ಬ್ಯಾಂಕ್ ಕೇಳುವುದಿಲ್ಲ.')),
    ],
    steps: [
      L('Cut the call. Never share OTP, PIN, or CVV.',
          'कॉल काट दें। OTP, PIN, CVV कभी न बताएँ।',
          'ಕರೆ ಕಡಿತಗೊಳಿಸಿ. OTP, PIN, CVV ಎಂದಿಗೂ ಹೇಳಬೇಡಿ.'),
      L('If money is gone, call 1930 immediately.',
          'पैसे चले गए तो तुरंत 1930 पर कॉल करें।',
          'ಹಣ ಹೋದರೆ ತಕ್ಷಣ 1930 ಗೆ ಕರೆ ಮಾಡಿ.'),
    ],
  ),
  MicroLesson(
    id: 'job_lesson',
    emoji: '💼',
    title: L('The fake job offer', 'नकली नौकरी का ऑफ़र', 'ನಕಲಿ ಉದ್ಯೋಗ ಆಫರ್'),
    cards: [
      StoryCard('📲', L('A message offers ₹15,000/month, work from home.',
          'एक संदेश ₹15,000/माह घर से काम का ऑफ़र देता है।',
          'ಒಂದು ಸಂದೇಶ ಮನೆಯಿಂದ ಕೆಲಸ, ₹15,000/ತಿಂಗಳು ಎನ್ನುತ್ತದೆ.')),
      StoryCard('💰', L('They ask for a small "registration fee" first.',
          'वे पहले छोटी "रजिस्ट्रेशन फ़ीस" माँगते हैं।',
          'ಅವರು ಮೊದಲು ಸಣ್ಣ "ನೋಂದಣಿ ಶುಲ್ಕ" ಕೇಳುತ್ತಾರೆ.')),
      StoryCard('🚫', L('No real company name. The salary is too good.',
          'कोई असली कंपनी नाम नहीं। सैलरी बहुत ज़्यादा।',
          'ನಿಜವಾದ ಕಂಪನಿ ಹೆಸರಿಲ್ಲ. ಸಂಬಳ ತುಂಬಾ ಹೆಚ್ಚು.')),
      StoryCard('✋', L('Real jobs never ask you to pay first.',
          'असली नौकरी पहले पैसे नहीं माँगती।',
          'ನಿಜವಾದ ಕೆಲಸ ಮೊದಲು ಹಣ ಕೇಳುವುದಿಲ್ಲ.')),
    ],
    steps: [
      L('Delete the message. Do not pay any fee.',
          'संदेश हटाएँ। कोई फ़ीस न दें।',
          'ಸಂದೇಶ ಅಳಿಸಿ. ಯಾವುದೇ ಶುಲ್ಕ ಕೊಡಬೇಡಿ.'),
    ],
  ),
];

// ── Visual Scam Library (real vs fake) — Feature 3.3 ────────────────────────
class ScamCompare {
  final String emoji;
  final L title;
  final L realExample;
  final L fakeExample;
  final L tell; // the giveaway
  const ScamCompare({
    required this.emoji,
    required this.title,
    required this.realExample,
    required this.fakeExample,
    required this.tell,
  });
}

const List<ScamCompare> scamLibrary = [
  ScamCompare(
    emoji: '🏦',
    title: L('Bank SMS', 'बैंक SMS', 'ಬ್ಯಾಂಕ್ SMS'),
    realExample: L('Rs 500 debited from a/c XX1234. Not you? Call 1800-...',
        'a/c XX1234 से ₹500 कटे। आपने नहीं? कॉल 1800-...',
        'a/c XX1234 ನಿಂದ ₹500 ಕಡಿತ. ನೀವಲ್ಲವೇ? ಕರೆ 1800-...'),
    fakeExample: L('Your a/c is BLOCKED! Update KYC now: bit.ly/kyc-sbi',
        'आपका खाता ब्लॉक! अभी KYC अपडेट: bit.ly/kyc-sbi',
        'ನಿಮ್ಮ ಖಾತೆ ಬ್ಲಾಕ್! ಈಗ KYC ಅಪ್‌ಡೇಟ್: bit.ly/kyc-sbi'),
    tell: L('Real bank SMS never has a short link asking for KYC.',
        'असली बैंक SMS में KYC माँगने वाला छोटा लिंक नहीं होता।',
        'ನಿಜವಾದ ಬ್ಯಾಂಕ್ SMS ನಲ್ಲಿ KYC ಕೇಳುವ ಶಾರ್ಟ್ ಲಿಂಕ್ ಇರುವುದಿಲ್ಲ.'),
  ),
  ScamCompare(
    emoji: '🔗',
    title: L('Website address', 'वेबसाइट पता', 'ವೆಬ್‌ಸೈಟ್ ವಿಳಾಸ'),
    realExample: L('onlinesbi.sbi', 'onlinesbi.sbi', 'onlinesbi.sbi'),
    fakeExample: L('sbi-online-kyc.xyz  /  meesh0.in',
        'sbi-online-kyc.xyz  /  meesh0.in', 'sbi-online-kyc.xyz  /  meesh0.in'),
    tell: L('Fakes add extra words or swap letters (0 for o).',
        'नकली में अतिरिक्त शब्द या बदले अक्षर होते हैं (o की जगह 0)।',
        'ನಕಲಿಯಲ್ಲಿ ಹೆಚ್ಚುವರಿ ಪದ ಅಥವಾ ಬದಲಾದ ಅಕ್ಷರ (o ಬದಲಿಗೆ 0).'),
  ),
  ScamCompare(
    emoji: '📲',
    title: L('UPI request', 'UPI अनुरोध', 'UPI ವಿನಂತಿ'),
    realExample: L('To RECEIVE money, you do nothing — it just arrives.',
        'पैसे पाने के लिए कुछ नहीं करना — वे अपने आप आते हैं।',
        'ಹಣ ಪಡೆಯಲು ಏನೂ ಮಾಡಬೇಕಿಲ್ಲ — ತಾನಾಗಿ ಬರುತ್ತದೆ.'),
    fakeExample: L('"Enter your UPI PIN to receive ₹5000 refund"',
        '"₹5000 रिफ़ंड पाने के लिए UPI PIN डालें"',
        '"₹5000 ಮರುಪಾವತಿ ಪಡೆಯಲು UPI PIN ನಮೂದಿಸಿ"'),
    tell: L('Entering a PIN always SENDS money, never receives it.',
        'PIN डालना हमेशा पैसे भेजता है, पाता नहीं।',
        'PIN ನಮೂದಿಸುವುದು ಯಾವಾಗಲೂ ಹಣ ಕಳುಹಿಸುತ್ತದೆ.'),
  ),
];

// ── Practice quiz — Feature 3.2 ─────────────────────────────────────────────
class Question {
  final String emoji;
  final L scenario;
  final bool isSafe;
  final L explain;
  const Question({
    required this.emoji,
    required this.scenario,
    required this.isSafe,
    required this.explain,
  });
}

const List<Question> practiceQuiz = [
  Question(
    emoji: '🛍️',
    scenario: L('A site "meesh0.in" sells a ₹2000 saree for ₹199. Buy?',
        'साइट "meesh0.in" ₹2000 की साड़ी ₹199 में बेचती है। खरीदें?',
        '"meesh0.in" ಸೈಟ್ ₹2000 ಸೀರೆಯನ್ನು ₹199 ಕ್ಕೆ ಮಾರುತ್ತದೆ. ಕೊಳ್ಳುವುದೇ?'),
    isSafe: false,
    explain: L('The address is "meesh0" with a zero — a fake of Meesho.',
        'पता "meesh0" में शून्य है — Meesho का नकली।',
        'ವಿಳಾಸದಲ್ಲಿ "meesh0" — ಸೊನ್ನೆ ಇದೆ — Meesho ನ ನಕಲಿ.'),
  ),
  Question(
    emoji: '🎁',
    scenario: L('"You won ₹25 lakh in KBC lucky draw! Send ₹2000 fee."',
        '"आपने KBC लकी ड्रॉ में ₹25 लाख जीते! ₹2000 फ़ीस भेजें।"',
        '"KBC ಲಕ್ಕಿ ಡ್ರಾದಲ್ಲಿ ₹25 ಲಕ್ಷ ಗೆದ್ದಿರಿ! ₹2000 ಶುಲ್ಕ ಕಳುಹಿಸಿ."'),
    isSafe: false,
    explain: L("You can't win a draw you never entered. Never pay to 'claim'.",
        'जिसमें भाग नहीं लिया वह नहीं जीत सकते। दावे के लिए पैसे न दें।',
        'ಭಾಗವಹಿಸದ ಡ್ರಾ ಗೆಲ್ಲಲಾಗದು. ಪಡೆಯಲು ಹಣ ಕೊಡಬೇಡಿ.'),
  ),
  Question(
    emoji: '👩‍👧',
    scenario: L('Your sister sends a family photo on WhatsApp. Open it?',
        'आपकी बहन WhatsApp पर परिवार की फ़ोटो भेजती है। खोलें?',
        'ನಿಮ್ಮ ಸಹೋದರಿ WhatsApp ನಲ್ಲಿ ಕುಟುಂಬ ಫೋಟೋ ಕಳುಹಿಸುತ್ತಾರೆ. ತೆರೆಯುವುದೇ?'),
    isSafe: true,
    explain: L('A known person sharing a normal photo is fine.',
        'जान-पहचान वाले की सामान्य फ़ोटो ठीक है।',
        'ಪರಿಚಿತರು ಸಾಮಾನ್ಯ ಫೋಟೋ ಹಂಚುವುದು ಸರಿ.'),
  ),
  Question(
    emoji: '⚡',
    scenario: L('"Electricity will be cut tonight! Pay now: bit.ly/bill-pay"',
        '"आज रात बिजली कटेगी! अभी भरें: bit.ly/bill-pay"',
        '"ಇಂದು ರಾತ್ರಿ ವಿದ್ಯುತ್ ಕಡಿತ! ಈಗ ಪಾವತಿಸಿ: bit.ly/bill-pay"'),
    isSafe: false,
    explain: L('Urgency + a short link = scam. Pay bills only in official apps.',
        'जल्दबाज़ी + छोटा लिंक = ठगी। बिल सिर्फ़ आधिकारिक ऐप में भरें।',
        'ಅವಸರ + ಶಾರ್ಟ್ ಲಿಂಕ್ = ಮೋಸ. ಬಿಲ್ ಅಧಿಕೃತ ಆ್ಯಪ್‌ನಲ್ಲಿ ಮಾತ್ರ ಪಾವತಿಸಿ.'),
  ),
];

// ── Badges — Feature 3.4 ────────────────────────────────────────────────────
class Badge {
  final String id;
  final String emoji;
  final L name;
  const Badge(this.id, this.emoji, this.name);
}

const List<Badge> allBadges = [
  Badge('scam_spotter', '🕵️‍♀️',
      L('Scam Spotter', 'ठगी पहचानने वाली', 'ಮೋಸ ಪತ್ತೆಗಾರ')),
  Badge('safe_learner', '📚',
      L('Safe Learner', 'सुरक्षित शिक्षार्थी', 'ಸುರಕ್ಷಿತ ಕಲಿಕಾರ')),
  Badge('safety_champion', '🏆',
      L('Safety Champion', 'सुरक्षा चैंपियन', 'ಸುರಕ್ಷತಾ ಚಾಂಪಿಯನ್')),
];
