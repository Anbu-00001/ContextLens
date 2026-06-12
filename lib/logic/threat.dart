// ── Local domain threat heuristics ─────────────────────────────────────────
// 100% on-device. A small curated blocklist plus rule-based heuristics that
// flag the patterns shady / phishing sites commonly use. No network lookups.

import 'i18n.dart';

class ThreatVerdict {
  final bool shady;
  final L reason;
  const ThreatVerdict(this.shady, this.reason);
}

const _safeReason = L('No obvious red flags in the address.',
    'पते में कोई स्पष्ट खतरा नहीं दिखा।', 'ವಿಳಾಸದಲ್ಲಿ ಸ್ಪಷ್ಟ ಅಪಾಯ ಕಾಣಲಿಲ್ಲ.');

// Known-bad sample domains (extend freely; matched as suffix).
const Set<String> _blocklist = {
  'free-gift-card.live',
  'login-verify-account.com',
  'secure-bank-update.info',
  'claim-your-prize.xyz',
  'update-kyc-now.top',
};

// TLDs disproportionately used for abuse / throwaway phishing.
const Set<String> _riskyTlds = {
  'zip', 'mov', 'top', 'xyz', 'gq', 'tk', 'ml', 'cf', 'ga', 'work',
  'click', 'country', 'kim', 'science', 'review', 'cam', 'rest', 'live',
};

// Brand names that, combined with "login/verify/secure", suggest spoofing.
const List<String> _spoofedBrands = [
  'paypal', 'google', 'apple', 'amazon', 'microsoft', 'netflix', 'whatsapp',
  'instagram', 'facebook', 'sbi', 'hdfc', 'icici', 'paytm', 'phonepe',
  'gpay', 'irctc', 'income-tax', 'aadhaar', 'uidai',
];

const List<String> _luringWords = [
  'login', 'signin', 'verify', 'secure', 'account', 'update', 'confirm',
  'kyc', 'otp', 'wallet', 'free', 'prize', 'gift', 'reward', 'bonus', 'claim',
];

// ── Trusted-sites allowlist ─────────────────────────────────────────────────
// "Commonly used" sites for first-time internet users (India-focused, from
// SimilarWeb/Semrush top-India rankings + official bank/gov/UPI domains).
// Matching is exact-label suffix only (host == d or host ends with ".d"), so
// "google.com.evil.in" or "fakeflipkart.com" can NOT ride on the list.
const Set<String> trustedSites = {
  // Search / big tech
  'google.com', 'google.co.in', 'gmail.com', 'youtube.com', 'bing.com',
  'microsoft.com', 'apple.com', 'mozilla.org', 'wikipedia.org',
  'chatgpt.com', 'openai.com', 'samsung.com', 'duckduckgo.com',
  // Social / messaging
  'whatsapp.com', 'instagram.com', 'facebook.com', 'x.com', 'twitter.com',
  'linkedin.com', 'telegram.org', 'pinterest.com', 'reddit.com',
  'snapchat.com', 'sharechat.com', 'threads.net', 'quora.com',
  // Shopping / groceries
  'amazon.in', 'amazon.com', 'flipkart.com', 'myntra.com', 'meesho.com',
  'ajio.com', 'snapdeal.com', 'jiomart.com', 'bigbasket.com', 'blinkit.com',
  'zeptonow.com', 'nykaa.com', 'tatacliq.com',
  // Food / travel / transport
  'zomato.com', 'swiggy.com', 'makemytrip.com', 'redbus.in', 'goibibo.com',
  'irctc.co.in', 'ixigo.com', 'olacabs.com', 'uber.com', 'rapido.bike',
  'confirmtkt.com', 'abhibus.com',
  // Banks (official domains only)
  'onlinesbi.sbi', 'sbi.co.in', 'hdfcbank.com', 'icicibank.com',
  'axisbank.com', 'kotak.com', 'pnbindia.in', 'bankofbaroda.in',
  'canarabank.com', 'unionbankofindia.co.in', 'idfcfirstbank.com',
  'indusind.com', 'yesbank.in', 'rbi.org.in',
  // Payments / UPI
  'paytm.com', 'phonepe.com', 'bhimupi.org.in', 'npci.org.in',
  'mobikwik.com', 'freecharge.in',
  // Government (controlled TLD spaces — suffix match covers all departments)
  'gov.in', 'nic.in', 'mygov.in', 'ac.in', 'edu.in',
  // Entertainment / news
  'hotstar.com', 'netflix.com', 'primevideo.com', 'jiocinema.com',
  'spotify.com', 'gaana.com', 'sonyliv.com', 'zee5.com', 'mxplayer.in',
  'cricbuzz.com', 'espncricinfo.com', 'ndtv.com', 'indiatimes.com',
  'hindustantimes.com', 'thehindu.com', 'aajtak.in', 'abplive.com',
  'news18.com', 'bhaskar.com', 'jagran.com', 'indianexpress.com',
  // Education / jobs / utility
  'byjus.com', 'vedantu.com', 'unacademy.com', 'khanacademy.org',
  'coursera.org', 'udemy.com', 'naukri.com', 'indeed.com', 'justdial.com',
  'indiamart.com', 'truecaller.com', 'edx.org', 'swayam.gov.in',
  'nptel.ac.in', 'duolingo.com', 'foundtio.in',
  // Coding / learning / developer (commonly used by students & professionals)
  'leetcode.com', 'github.com', 'gitlab.com', 'bitbucket.org',
  'stackoverflow.com', 'stackexchange.com', 'geeksforgeeks.org',
  'hackerrank.com', 'hackerearth.com', 'codechef.com', 'codeforces.com',
  'w3schools.com', 'programiz.com', 'tutorialspoint.com', 'freecodecamp.org',
  'codepen.io', 'replit.com', 'kaggle.com', 'codingninjas.com',
  'developer.mozilla.org', 'dev.to', 'medium.com', 'npmjs.com',
  'pypi.org', 'jupyter.org', 'anaconda.com', 'docker.com', 'vercel.com',
  'netlify.app', 'firebase.google.com', 'cloud.google.com',
  // Google & Microsoft services (most are covered by google.com / live.com)
  'google.co', 'goo.gl', 'gstatic.com', 'googleusercontent.com',
  'office.com', 'office365.com', 'outlook.com', 'live.com', 'microsoftonline.com',
  'sharepoint.com', 'onedrive.com', 'azure.com',
  // Work / productivity / cloud
  'notion.so', 'figma.com', 'canva.com', 'dropbox.com', 'slack.com',
  'zoom.us', 'trello.com', 'atlassian.net', 'asana.com', 'miro.com',
  'overleaf.com', 'grammarly.com', 'wetransfer.com', 'adobe.com',
  // Reference / AI / knowledge
  'gemini.google.com', 'bard.google.com', 'claude.ai', 'anthropic.com',
  'perplexity.ai', 'wolframalpha.com', 'archive.org', 'scholar.google.com',
  'researchgate.net', 'arxiv.org', 'imdb.com', 'goodreads.com',
  'britannica.com', 'twitch.tv', 'soundcloud.com',
};

/// Allowlist verdict for the Safe Browser.
enum SiteTrust { trusted, unknown, shady }

bool isTrustedSite(String input) {
  var host = hostOf(input);
  if (host.startsWith('www.')) host = host.substring(4);
  if (host.isEmpty) return false;
  for (final t in trustedSites) {
    if (host == t || host.endsWith('.$t')) return true;
  }
  return false;
}

/// True when the address is plain HTTP (no TLS) — insecure, can be tampered
/// with in transit and is common in phishing. Sites typed without a scheme are
/// upgraded to https before navigation, so only explicit http:// reaches here.
bool isInsecureHttp(String input) =>
    input.trim().toLowerCase().startsWith('http://');

/// Combined verdict: shady heuristics win, then the allowlist, else unknown.
SiteTrust siteTrust(String input) {
  if (assessDomain(input).shady) return SiteTrust.shady;
  if (isTrustedSite(input)) return SiteTrust.trusted;
  return SiteTrust.unknown;
}

String hostOf(String input) {
  var s = input.trim().toLowerCase();
  s = s.replaceFirst(RegExp(r'^[a-z]+://'), '');
  s = s.split('/').first.split('?').first;
  if (s.contains('@')) s = s.split('@').last; // strip userinfo trick
  s = s.split(':').first; // strip port
  return s;
}

ThreatVerdict assessDomain(String input) {
  final host = hostOf(input);
  if (host.isEmpty) return const ThreatVerdict(false, _safeReason);

  // 1) Explicit blocklist.
  for (final bad in _blocklist) {
    if (host == bad || host.endsWith('.$bad')) {
      return const ThreatVerdict(
        true,
        L('This address is on the known-dangerous list.',
            'यह पता ज्ञात-खतरनाक सूची में है।',
            'ಈ ವಿಳಾಸ ತಿಳಿದಿರುವ ಅಪಾಯಕಾರಿ ಪಟ್ಟಿಯಲ್ಲಿದೆ.'),
      );
    }
  }

  // 2) Raw IP address instead of a real name.
  if (RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host)) {
    return const ThreatVerdict(
      true,
      L('This site uses a bare number instead of a real name — risky.',
          'यह साइट असली नाम की जगह सिर्फ़ नंबर इस्तेमाल करती है — जोखिम भरा।',
          'ಈ ಸೈಟ್ ನಿಜವಾದ ಹೆಸರಿನ ಬದಲು ಬರೀ ಸಂಖ್ಯೆ ಬಳಸುತ್ತದೆ — ಅಪಾಯಕಾರಿ.'),
    );
  }

  // 3) Punycode / fake-letter domains.
  if (host.contains('xn--')) {
    return const ThreatVerdict(
      true,
      L('This address may use look-alike letters to fool you.',
          'यह पता धोखा देने के लिए मिलते-जुलते अक्षर इस्तेमाल कर सकता है।',
          'ಈ ವಿಳಾಸ ಮೋಸಗೊಳಿಸಲು ಹೋಲುವ ಅಕ್ಷರ ಬಳಸಬಹುದು.'),
    );
  }

  final tld = host.contains('.') ? host.split('.').last : '';
  final hasLure = _luringWords.any((w) => host.contains(w));
  final hasBrand = _spoofedBrands.any((b) => host.contains(b));
  // Real brand domains are short; a brand buried in a long host is suspicious.
  final brandLooksFaked = hasBrand &&
      hasLure &&
      !_isOfficialBrandHost(host);

  // 4) Brand spoof (e.g. paypal-login-secure.xyz).
  if (brandLooksFaked) {
    return const ThreatVerdict(
      true,
      L('This pretends to be a well-known brand to steal your details.',
          'यह आपकी जानकारी चुराने के लिए किसी जाने-माने ब्रांड का रूप धरता है।',
          'ನಿಮ್ಮ ಮಾಹಿತಿ ಕದಿಯಲು ಇದು ಪ್ರಸಿದ್ಧ ಬ್ರ್ಯಾಂಡ್‌ನಂತೆ ನಟಿಸುತ್ತದೆ.'),
    );
  }

  // 5) Risky TLD + luring words.
  if (_riskyTlds.contains(tld) && hasLure) {
    return const ThreatVerdict(
      true,
      L('Risky web address with words often used in scams.',
          'जोखिम भरा वेब पता, ऐसे शब्दों के साथ जो अक्सर ठगी में इस्तेमाल होते हैं।',
          'ವಂಚನೆಯಲ್ಲಿ ಬಳಸುವ ಪದಗಳಿರುವ ಅಪಾಯಕಾರಿ ವೆಬ್ ವಿಳಾಸ.'),
    );
  }

  // 6) Excessive hyphens / very long host — common in throwaway phishing.
  final hyphens = '-'.allMatches(host).length;
  if (hyphens >= 3 || host.length > 40) {
    return const ThreatVerdict(
      true,
      L('This address looks unusual and may not be trustworthy.',
          'यह पता असामान्य लगता है और शायद भरोसेमंद न हो।',
          'ಈ ವಿಳಾಸ ಅಸಾಮಾನ್ಯವಾಗಿದ್ದು ನಂಬಲರ್ಹವಲ್ಲದಿರಬಹುದು.'),
    );
  }

  return const ThreatVerdict(false, _safeReason);
}

// Treat well-known official hosts as safe even if they contain a brand word.
bool _isOfficialBrandHost(String host) {
  const official = {
    'google.com', 'accounts.google.com', 'apple.com', 'amazon.in', 'amazon.com',
    'paypal.com', 'microsoft.com', 'netflix.com', 'whatsapp.com',
    'instagram.com', 'facebook.com', 'onlinesbi.sbi', 'hdfcbank.com',
    'icicibank.com', 'paytm.com', 'phonepe.com', 'irctc.co.in',
    'incometax.gov.in', 'uidai.gov.in',
  };
  for (final o in official) {
    if (host == o || host.endsWith('.$o')) return true;
  }
  return false;
}
