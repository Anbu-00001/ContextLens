// ── ConsentLens trilingual strings (English / Hindi / Kannada) ─────────────
// All processing is local. These strings power both UI text and TTS voice.

class L {
  final String en, hi, kn;
  const L(this.en, this.hi, this.kn);

  String of(String lang) {
    switch (lang) {
      case 'hi':
        return hi;
      case 'kn':
        return kn;
      default:
        return en;
    }
  }
}

/// TTS locale per app language code.
const Map<String, String> ttsLocales = {
  'en': 'en-IN',
  'hi': 'hi-IN',
  'kn': 'kn-IN',
};

class S {
  static const appName = L('ConsentLens', 'कंसेंटलेंस', 'ಕನ್ಸೆಂಟ್‌ಲೆನ್ಸ್');
  static const tagline = L('Protecting your privacy', 'आपकी निजता की रक्षा',
      'ನಿಮ್ಮ ಖಾಸಗಿತನದ ರಕ್ಷಣೆ');

  // Risk
  static const overallRisk = L('Overall risk', 'कुल जोखिम', 'ಒಟ್ಟು ಅಪಾಯ');
  static const riskHigh = L('HIGH', 'उच्च', 'ಹೆಚ್ಚು');
  static const riskLow = L('LOW', 'कम', 'ಕಡಿಮೆ');
  static const low = L('Low', 'कम', 'ಕಡಿಮೆ');
  static const medium = L('Medium', 'मध्यम', 'ಮಧ್ಯಮ');
  static const high = L('High', 'उच्च', 'ಹೆಚ್ಚು');
  static const riskLevel = L('Risk level', 'जोखिम स्तर', 'ಅಪಾಯ ಮಟ್ಟ');

  // Popup sections
  static const whyNeeded = L('Why it is needed', 'क्यों चाहिए', 'ಯಾಕೆ ಬೇಕು');
  static const ifAllowed =
      L('If you allow', 'अनुमति देने पर', 'ಅನುಮತಿ ನೀಡಿದರೆ');
  static const suitableFor =
      L('Who is this app for?', 'यह ऐप किसके लिए है?', 'ಈ ಆ್ಯಪ್ ಯಾರಿಗೆ?');
  static const kids = L('Kids', 'बच्चे', 'ಮಕ್ಕಳು');
  static const teens = L('Teens', 'किशोर', 'ಹದಿಹರೆಯದವರು');
  static const adults = L('Adults', 'वयस्क', 'ವಯಸ್ಕರು');
  static const okFor = L('OK', 'ठीक', 'ಸರಿ');
  static const cautionFor = L('Careful', 'सावधानी', 'ಎಚ್ಚರ');
  static const notOkFor = L('Not safe', 'सुरक्षित नहीं', 'ಸುರಕ್ಷಿತವಲ್ಲ');
  static const risksAsKid =
      L('Risks for kids', 'बच्चों के लिए जोखिम', 'ಮಕ್ಕಳಿಗೆ ಅಪಾಯಗಳು');
  static const risksAsTeen = L('Risks for teens', 'किशोरों के लिए जोखिम',
      'ಹದಿಹರೆಯದವರಿಗೆ ಅಪಾಯಗಳು');
  static const risksAsAdult =
      L('Risks for adults', 'वयस्कों के लिए जोखिम', 'ವಯಸ್ಕರಿಗೆ ಅಪಾಯಗಳು');
  static const gotIt = L('Got it', 'समझ गया', 'ಗೊತ್ತಾಯ್ತು');
  static const appSettings =
      L('App settings', 'ऐप सेटिंग्स', 'ಆ್ಯಪ್ ಸೆಟ್ಟಿಂಗ್ಸ್');
  static const childAlert = L(
      'Ask a grown-up before using this app!',
      'यह ऐप चलाने से पहले बड़ों से पूछो!',
      'ಈ ಆ್ಯಪ್ ಬಳಸುವ ಮೊದಲು ದೊಡ್ಡವರನ್ನು ಕೇಳಿ!');
  static const browserNote = L(
      'This is a browser. Websites you open inside it can also ask for these permissions.',
      'यह एक ब्राउज़र है। इसमें खुलने वाली वेबसाइटें भी ये अनुमतियाँ माँग सकती हैं।',
      'ಇದು ಬ್ರೌಸರ್. ಇದರಲ್ಲಿ ತೆರೆಯುವ ವೆಬ್‌ಸೈಟ್‌ಗಳು ಸಹ ಈ ಅನುಮತಿಗಳನ್ನು ಕೇಳಬಹುದು.');
  static const permsDetected =
      L('permissions detected', 'अनुमतियाँ मिलीं', 'ಅನುಮತಿಗಳು ಪತ್ತೆಯಾಗಿವೆ');
  static const noRiskyPerms = L('No risky permissions found',
      'कोई जोखिम भरी अनुमति नहीं मिली', 'ಯಾವುದೇ ಅಪಾಯಕಾರಿ ಅನುಮತಿ ಸಿಗಲಿಲ್ಲ');

  // TTS templates — use {app}, {n}, {risk}
  static const ttsSummary = L(
      '{app} asks for {n} permissions. Overall risk is {risk}.',
      '{app} {n} अनुमतियाँ माँगता है। कुल जोखिम {risk} है।',
      '{app} {n} ಅನುಮತಿಗಳನ್ನು ಕೇಳುತ್ತದೆ. ಒಟ್ಟು ಅಪಾಯ {risk}.');
  static const ttsChildWarn = L(
      'Warning! This app may not be safe for kids. Please ask a grown-up.',
      'सावधान! यह ऐप बच्चों के लिए सुरक्षित नहीं हो सकता। बड़ों से पूछें।',
      'ಎಚ್ಚರಿಕೆ! ಈ ಆ್ಯಪ್ ಮಕ್ಕಳಿಗೆ ಸುರಕ್ಷಿತವಲ್ಲದಿರಬಹುದು. ದೊಡ್ಡವರನ್ನು ಕೇಳಿ.');

  // Main app
  static const protect = L('Protect', 'सुरक्षा', 'ರಕ್ಷಣೆ');
  static const permissions = L('Permissions', 'अनुमतियाँ', 'ಅನುಮತಿಗಳು');
  static const history = L('History', 'इतिहास', 'ಇತಿಹಾಸ');
  static const settings = L('Settings', 'सेटिंग्स', 'ಸೆಟ್ಟಿಂಗ್ಸ್');
  static const protectionActive =
      L('Protection is ON', 'सुरक्षा चालू है', 'ರಕ್ಷಣೆ ಆನ್ ಆಗಿದೆ');
  static const protectionOff =
      L('Protection is OFF', 'सुरक्षा बंद है', 'ರಕ್ಷಣೆ ಆಫ್ ಆಗಿದೆ');
  static const startProtection =
      L('Start protection', 'सुरक्षा शुरू करें', 'ರಕ್ಷಣೆ ಪ್ರಾರಂಭಿಸಿ');
  static const stopProtection =
      L('Stop protection', 'सुरक्षा रोकें', 'ರಕ್ಷಣೆ ನಿಲ್ಲಿಸಿ');
  static const setupNeeded =
      L('Setup needed', 'सेटअप ज़रूरी है', 'ಸೆಟಪ್ ಅಗತ್ಯವಿದೆ');
  static const usageAccess = L('App detection access', 'ऐप पहचान की अनुमति',
      'ಆ್ಯಪ್ ಪತ್ತೆ ಅನುಮತಿ');
  static const usageAccessSub = L(
      'Needed to know which app you opened',
      'यह जानने के लिए कि आपने कौन-सा ऐप खोला',
      'ನೀವು ಯಾವ ಆ್ಯಪ್ ತೆರೆದಿದ್ದೀರಿ ಎಂದು ತಿಳಿಯಲು');
  static const overlayAccess = L('Display over other apps',
      'दूसरे ऐप्स के ऊपर दिखाना', 'ಇತರ ಆ್ಯಪ್‌ಗಳ ಮೇಲೆ ತೋರಿಸುವುದು');
  static const overlayAccessSub = L(
      'Needed to show the warning popup',
      'चेतावनी पॉपअप दिखाने के लिए',
      'ಎಚ್ಚರಿಕೆ ಪಾಪ್‌ಅಪ್ ತೋರಿಸಲು');
  static const grant = L('Grant', 'दें', 'ನೀಡಿ');
  static const granted = L('Granted', 'दी गई', 'ನೀಡಲಾಗಿದೆ');
  static const currentUser =
      L('Current user', 'वर्तमान उपयोगकर्ता', 'ಪ್ರಸ್ತುತ ಬಳಕೆದಾರ');
  static const adultMode = L('Adult', 'वयस्क', 'ವಯಸ್ಕ');
  static const childMode = L('Child', 'बच्चा', 'ಮಗು');
  static const verifyNow = L('Verify now', 'अभी सत्यापित करें', 'ಈಗ ಪರಿಶೀಲಿಸಿ');
  static const verifySub = L(
      'Fingerprint, face or passcode decides Adult vs Child mode',
      'फिंगरप्रिंट, फेस या पासकोड से वयस्क/बच्चा मोड तय होता है',
      'ಬೆರಳಚ್ಚು, ಮುಖ ಅಥವಾ ಪಾಸ್‌ಕೋಡ್ ವಯಸ್ಕ/ಮಗು ಮೋಡ್ ನಿರ್ಧರಿಸುತ್ತದೆ');
  static const language = L('Language', 'भाषा', 'ಭಾಷೆ');
  static const voiceNarration =
      L('Voice narration', 'आवाज़ में सुनाना', 'ಧ್ವನಿ ವಿವರಣೆ');
  static const voiceNarrationSub = L(
      'Speak the popup aloud automatically',
      'पॉपअप को अपने आप बोलकर सुनाएँ',
      'ಪಾಪ್‌ಅಪ್ ಅನ್ನು ತಾನಾಗಿ ಓದಿ ಹೇಳುತ್ತದೆ');
  static const recentAlerts =
      L('Recent alerts', 'हाल की चेतावनियाँ', 'ಇತ್ತೀಚಿನ ಎಚ್ಚರಿಕೆಗಳು');
  static const noAlerts = L(
      'No alerts yet. Open any app to see ConsentLens in action.',
      'अभी कोई चेतावनी नहीं। कोई भी ऐप खोलें और कंसेंटलेंस को काम करते देखें।',
      'ಇನ್ನೂ ಎಚ್ಚರಿಕೆಗಳಿಲ್ಲ. ಯಾವುದೇ ಆ್ಯಪ್ ತೆರೆದು ಕನ್ಸೆಂಟ್‌ಲೆನ್ಸ್ ನೋಡಿ.');
  static const installedApps =
      L('Installed apps', 'इंस्टॉल किए गए ऐप्स', 'ಸ್ಥಾಪಿತ ಆ್ಯಪ್‌ಗಳು');
  static const storedLocally = L('Stored only on this device',
      'सिर्फ़ इसी डिवाइस पर सहेजा गया', 'ಈ ಸಾಧನದಲ್ಲಿ ಮಾತ್ರ ಸಂಗ್ರಹ');
  static const clearHistory =
      L('Clear history', 'इतिहास मिटाएँ', 'ಇತಿಹಾಸ ಅಳಿಸಿ');
  static const localOnly = L('Local processing only', 'सिर्फ़ लोकल प्रोसेसिंग',
      'ಸ್ಥಳೀಯ ಸಂಸ್ಕರಣೆ ಮಾತ್ರ');
  static const localOnlySub = L('No data ever leaves your device',
      'कोई डेटा डिवाइस से बाहर नहीं जाता', 'ಯಾವುದೇ ಡೇಟಾ ಸಾಧನದಿಂದ ಹೊರಹೋಗುವುದಿಲ್ಲ');
  static const seen = L('Seen', 'देखा गया', 'ನೋಡಲಾಗಿದೆ');

  // Website / threat
  static const websiteWants = L('This website is asking for:',
      'यह वेबसाइट माँग रही है:', 'ಈ ವೆಬ್‌ಸೈಟ್ ಕೇಳುತ್ತಿದೆ:');
  static const dangerousSite = L('DANGEROUS WEBSITE', 'खतरनाक वेबसाइट',
      'ಅಪಾಯಕಾರಿ ವೆಬ್‌ಸೈಟ್');
  static const threatWarn = L(
      'This may be a scam or fake site. Do NOT allow anything or enter passwords.',
      'यह ठगी या नकली साइट हो सकती है। कुछ भी अनुमति न दें और पासवर्ड न डालें।',
      'ಇದು ವಂಚನೆ ಅಥವಾ ನಕಲಿ ಸೈಟ್ ಆಗಿರಬಹುದು. ಯಾವುದನ್ನೂ ಅನುಮತಿಸಬೇಡಿ, ಪಾಸ್‌ವರ್ಡ್ ಹಾಕಬೇಡಿ.');
  static const ttsThreat = L(
      'Warning! This website looks dangerous. Do not allow this permission or type any password.',
      'सावधान! यह वेबसाइट खतरनाक लगती है। यह अनुमति न दें और कोई पासवर्ड न लिखें।',
      'ಎಚ್ಚರಿಕೆ! ಈ ವೆಬ್‌ಸೈಟ್ ಅಪಾಯಕಾರಿ ಕಾಣುತ್ತದೆ. ಈ ಅನುಮತಿ ನೀಡಬೇಡಿ, ಪಾಸ್‌ವರ್ಡ್ ಬರೆಯಬೇಡಿ.');
  static const safeBrowser =
      L('Safe Browser', 'सुरक्षित ब्राउज़र', 'ಸುರಕ್ಷಿತ ಬ್ರೌಸರ್');
  static const safeBrowserSub = L(
      'Browse with ConsentLens checking every site & permission',
      'हर साइट और अनुमति जाँचते हुए ConsentLens के साथ ब्राउज़ करें',
      'ಪ್ರತಿ ಸೈಟ್ ಮತ್ತು ಅನುಮತಿ ಪರಿಶೀಲಿಸುತ್ತಾ ConsentLens ಜೊತೆ ಬ್ರೌಸ್ ಮಾಡಿ');
  static const webMonitor = L('Website permission watch',
      'वेबसाइट अनुमति निगरानी', 'ವೆಬ್‌ಸೈಟ್ ಅನುಮತಿ ಕಣ್ಗಾವಲು');
  static const webMonitorSub = L(
      'Warn me when any website in Chrome asks for a permission',
      'जब Chrome में कोई वेबसाइट अनुमति माँगे तो मुझे चेताएँ',
      'Chrome ನಲ್ಲಿ ಯಾವುದೇ ವೆಬ್‌ಸೈಟ್ ಅನುಮತಿ ಕೇಳಿದಾಗ ನನ್ನನ್ನು ಎಚ್ಚರಿಸಿ');
  static const blocked = L('Blocked', 'अवरुद्ध', 'ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ');
  static const allowOnce = L('Allow once', 'एक बार अनुमति दें', 'ಒಮ್ಮೆ ಅನುಮತಿಸಿ');
  static const block = L('Block', 'रोकें', 'ನಿರ್ಬಂಧಿಸಿ');
  static const enterUrl = L('Search or type a website',
      'खोजें या वेबसाइट टाइप करें', 'ಹುಡುಕಿ ಅಥವಾ ವೆಬ್‌ಸೈಟ್ ಟೈಪ್ ಮಾಡಿ');
  static const siteBlockedTitle =
      L('Site blocked for safety', 'सुरक्षा हेतु साइट रोकी गई',
          'ಸುರಕ್ಷತೆಗಾಗಿ ಸೈಟ್ ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ');
  static const goBack = L('Go back', 'वापस जाएँ', 'ಹಿಂದೆ ಹೋಗಿ');
  static const proceedAnyway =
      L('Proceed anyway', 'फिर भी आगे बढ़ें', 'ಹೇಗಾದರೂ ಮುಂದುವರಿಯಿರಿ');
}
