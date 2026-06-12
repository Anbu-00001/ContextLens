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
  static const trustedSite =
      L('Trusted site', 'विश्वसनीय साइट', 'ನಂಬಲರ್ಹ ಸೈಟ್');
  static const unknownSiteTitle = L('Not a commonly used site',
      'यह आम इस्तेमाल वाली साइट नहीं है', 'ಇದು ಸಾಮಾನ್ಯ ಬಳಕೆಯ ಸೈಟ್ ಅಲ್ಲ');
  static const unknownSiteBody = L(
      'This website is not on the trusted list. It could be fraudulent. If someone sent you this link, do not enter money details or passwords.',
      'यह वेबसाइट विश्वसनीय सूची में नहीं है। यह धोखाधड़ी हो सकती है। अगर किसी ने यह लिंक भेजा है, तो पैसे की जानकारी या पासवर्ड न डालें।',
      'ಈ ವೆಬ್‌ಸೈಟ್ ನಂಬಲರ್ಹ ಪಟ್ಟಿಯಲ್ಲಿಲ್ಲ. ಇದು ವಂಚನೆಯಾಗಿರಬಹುದು. ಯಾರಾದರೂ ಈ ಲಿಂಕ್ ಕಳುಹಿಸಿದ್ದರೆ, ಹಣದ ವಿವರ ಅಥವಾ ಪಾಸ್‌ವರ್ಡ್ ಹಾಕಬೇಡಿ.');
  static const unknownSiteChild = L(
      'This site is not on the trusted list, so it stays closed in child mode.',
      'यह साइट विश्वसनीय सूची में नहीं है, इसलिए चाइल्ड मोड में बंद रहेगी।',
      'ಈ ಸೈಟ್ ನಂಬಲರ್ಹ ಪಟ್ಟಿಯಲ್ಲಿಲ್ಲ, ಹಾಗಾಗಿ ಮಕ್ಕಳ ಮೋಡ್‌ನಲ್ಲಿ ಮುಚ್ಚಿರುತ್ತದೆ.');
  static const insecureSiteTitle = L('Not a secure site (HTTP)',
      'सुरक्षित साइट नहीं (HTTP)', 'ಸುರಕ್ಷಿತ ಸೈಟ್ ಅಲ್ಲ (HTTP)');
  static const insecureSiteBody = L(
      'This site does not use a secure (https) connection. Anything you type — passwords, OTPs, card numbers — can be seen by others. Do not enter private details.',
      'यह साइट सुरक्षित (https) कनेक्शन का उपयोग नहीं करती। आप जो भी टाइप करें — पासवर्ड, OTP, कार्ड नंबर — दूसरे देख सकते हैं। निजी जानकारी न डालें।',
      'ಈ ಸೈಟ್ ಸುರಕ್ಷಿತ (https) ಸಂಪರ್ಕ ಬಳಸುವುದಿಲ್ಲ. ನೀವು ಟೈಪ್ ಮಾಡುವ ಪಾಸ್‌ವರ್ಡ್, OTP, ಕಾರ್ಡ್ ಸಂಖ್ಯೆ ಬೇರೆಯವರು ನೋಡಬಹುದು. ಖಾಸಗಿ ವಿವರ ಹಾಕಬೇಡಿ.');

  // Kids Mode app allowlist
  static const chooseKidsApps = L('Choose apps for your child',
      'बच्चे के लिए ऐप चुनें', 'ಮಗುವಿಗೆ ಆ್ಯಪ್ ಆಯ್ಕೆಮಾಡಿ');
  static const chooseKidsAppsSub = L(
      'Only the apps you pick here will open while the child uses the phone. Everything else shows a friendly "ask a grown-up" screen.',
      'सिर्फ़ यहाँ चुने ऐप ही बच्चे के फोन इस्तेमाल के दौरान खुलेंगे। बाकी सब पर "बड़ों से पूछो" स्क्रीन दिखेगी।',
      'ಇಲ್ಲಿ ಆಯ್ಕೆ ಮಾಡಿದ ಆ್ಯಪ್‌ಗಳು ಮಾತ್ರ ಮಗು ಫೋನ್ ಬಳಸುವಾಗ ತೆರೆಯುತ್ತವೆ. ಉಳಿದವುಗಳಿಗೆ "ದೊಡ್ಡವರನ್ನು ಕೇಳಿ" ಪರದೆ ಕಾಣುತ್ತದೆ.');
  static const kidsNeedsPerms = L(
      'To guard other apps, ConsentLens needs Usage access and Display-over-apps permission.',
      'दूसरे ऐप्स की निगरानी के लिए ConsentLens को उपयोग एक्सेस और ऐप्स-के-ऊपर-दिखाएँ अनुमति चाहिए।',
      'ಇತರ ಆ್ಯಪ್‌ಗಳನ್ನು ಕಾಯಲು ConsentLens ಗೆ ಬಳಕೆ ಪ್ರವೇಶ ಮತ್ತು ಆ್ಯಪ್‌ಗಳ-ಮೇಲೆ-ತೋರಿಸು ಅನುಮತಿ ಬೇಕು.');
  static const noAppsPicked = L(
      'No apps picked — the child gets a simple play screen only.',
      'कोई ऐप नहीं चुना — बच्चे को सिर्फ़ साधारण खेल स्क्रीन मिलेगी।',
      'ಯಾವ ಆ್ಯಪ್ ಆಯ್ಕೆ ಆಗಿಲ್ಲ — ಮಗುವಿಗೆ ಸರಳ ಆಟದ ಪರದೆ ಮಾತ್ರ.');
  static const kidsPickApp = L('Tap an app to play',
      'खेलने के लिए ऐप दबाओ', 'ಆಡಲು ಆ್ಯಪ್ ಒತ್ತಿ');

  // Trusted apps — no permission popup
  static const trustedApps = L('Trusted apps (no popup)',
      'भरोसेमंद ऐप (कोई पॉपअप नहीं)', 'ನಂಬಲರ್ಹ ಆ್ಯಪ್‌ಗಳು (ಪಾಪ್‌ಅಪ್ ಇಲ್ಲ)');
  static const trustedAppsSub = L(
      'Skip the permission popup for apps you use every day',
      'रोज़ इस्तेमाल होने वाले ऐप के लिए पॉपअप छोड़ें',
      'ಪ್ರತಿದಿನ ಬಳಸುವ ಆ್ಯಪ್‌ಗಳಿಗೆ ಅನುಮತಿ ಪಾಪ್‌ಅಪ್ ಬಿಟ್ಟುಬಿಡಿ');
  static const trustedAppsIntro = L(
      'Turn ON the apps you trust and use daily. ConsentLens will stay quiet for these and keep watching the rest.',
      'जिन ऐप पर आप भरोसा करते हैं और रोज़ इस्तेमाल करते हैं उन्हें चालू करें। ConsentLens इनके लिए शांत रहेगा और बाकी पर नज़र रखेगा।',
      'ನೀವು ನಂಬುವ ಮತ್ತು ಪ್ರತಿದಿನ ಬಳಸುವ ಆ್ಯಪ್‌ಗಳನ್ನು ಆನ್ ಮಾಡಿ. ConsentLens ಇವುಗಳಿಗೆ ಶಾಂತವಾಗಿರುತ್ತದೆ, ಉಳಿದವುಗಳನ್ನು ಗಮನಿಸುತ್ತದೆ.');
  static const dontWarnThisApp = L("Don't warn me for this app",
      'इस ऐप के लिए न चेताएँ', 'ಈ ಆ್ಯಪ್‌ಗೆ ಎಚ್ಚರಿಸಬೇಡಿ');
  static const noPopupApps = L('No popup', 'कोई पॉपअप नहीं', 'ಪಾಪ್‌ಅಪ್ ಇಲ್ಲ');

  // Stalkerware / safety module
  static const safetyScan = L('Spyware safety scan', 'स्पाईवेयर सुरक्षा स्कैन',
      'ಸ್ಪೈವೇರ್ ಸುರಕ್ಷತಾ ಸ್ಕ್ಯಾನ್');
  static const safetyScanSub = L(
      'Check if any app may be secretly watching you',
      'जाँचें कि कोई ऐप चुपके से आप पर नज़र तो नहीं रख रहा',
      'ಯಾವುದೇ ಆ್ಯಪ್ ರಹಸ್ಯವಾಗಿ ನಿಮ್ಮ ಮೇಲೆ ಕಣ್ಣಿಡುತ್ತಿದೆಯೇ ಪರಿಶೀಲಿಸಿ');
  static const scanning = L('Scanning your apps…', 'आपके ऐप्स स्कैन हो रहे हैं…',
      'ನಿಮ್ಮ ಆ್ಯಪ್‌ಗಳನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲಾಗುತ್ತಿದೆ…');
  static const scanClean = L(
      'No spyware-like apps found. Stay alert anyway.',
      'कोई स्पाईवेयर जैसा ऐप नहीं मिला। फिर भी सतर्क रहें।',
      'ಸ್ಪೈವೇರ್‌ನಂತಹ ಆ್ಯಪ್ ಸಿಗಲಿಲ್ಲ. ಆದರೂ ಎಚ್ಚರವಾಗಿರಿ.');
  static const spySuspected = L('POSSIBLE SPYWARE', 'संभावित स्पाईवेयर',
      'ಸಂಭಾವ್ಯ ಸ್ಪೈವೇರ್');
  static const spyElevated = L('Watches a lot', 'बहुत कुछ देखता है',
      'ಬಹಳಷ್ಟು ನೋಡುತ್ತದೆ');
  static const spyCardTitle = L('This app may be secretly monitoring you',
      'यह ऐप चुपके से आप पर नज़र रख सकता है',
      'ಈ ಆ್ಯಪ್ ರಹಸ್ಯವಾಗಿ ನಿಮ್ಮ ಮೇಲೆ ಕಣ್ಣಿಡುತ್ತಿರಬಹುದು');
  static const whySuspicious =
      L('Why it looks risky', 'यह जोखिम भरा क्यों लगता है', 'ಇದು ಯಾಕೆ ಅಪಾಯಕಾರಿ');
  static const spyDisclaimer = L(
      'This is a warning sign, not proof. Some genuine apps need these too.',
      'यह चेतावनी का संकेत है, सबूत नहीं। कुछ असली ऐप्स को भी इनकी ज़रूरत होती है।',
      'ಇದು ಎಚ್ಚರಿಕೆ ಸೂಚನೆ, ಪುರಾವೆಯಲ್ಲ. ಕೆಲವು ನಿಜವಾದ ಆ್ಯಪ್‌ಗಳಿಗೂ ಇವು ಬೇಕು.');
  // Safety-first guidance — NEVER tell the user to just uninstall.
  static const safetyFirstTitle =
      L('Your safety comes first', 'आपकी सुरक्षा सबसे पहले', 'ನಿಮ್ಮ ಸುರಕ್ಷತೆ ಮೊದಲು');
  static const safetyFirstBody = L(
      'If someone may be tracking you, do NOT remove the app yet — they could be alerted. First reach out for help and save proof (screenshots).',
      'अगर कोई आप पर नज़र रख रहा हो, तो ऐप अभी न हटाएँ — उसे पता चल सकता है। पहले मदद लें और सबूत (स्क्रीनशॉट) सहेजें।',
      'ಯಾರಾದರೂ ನಿಮ್ಮನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡುತ್ತಿದ್ದರೆ, ಆ್ಯಪ್ ಅನ್ನು ಈಗ ತೆಗೆಯಬೇಡಿ — ಅವರಿಗೆ ತಿಳಿಯಬಹುದು. ಮೊದಲು ಸಹಾಯ ಪಡೆಯಿರಿ, ಪುರಾವೆ (ಸ್ಕ್ರೀನ್‌ಶಾಟ್) ಉಳಿಸಿ.');
  static const getHelp = L('Get help', 'मदद लें', 'ಸಹಾಯ ಪಡೆಯಿರಿ');
  static const safetyHelp =
      L('Safety & help', 'सुरक्षा और मदद', 'ಸುರಕ್ಷತೆ ಮತ್ತು ಸಹಾಯ');
  static const helpIntro = L(
      'Free, official Indian helplines. Tap to call or open.',
      'मुफ़्त, आधिकारिक भारतीय हेल्पलाइन। कॉल करने या खोलने के लिए टैप करें।',
      'ಉಚಿತ, ಅಧಿಕೃತ ಭಾರತೀಯ ಸಹಾಯವಾಣಿಗಳು. ಕರೆ ಅಥವಾ ತೆರೆಯಲು ಟ್ಯಾಪ್ ಮಾಡಿ.');
  static const ttsSpyWarn = L(
      'Warning. This app may be secretly monitoring you. Your safety comes first. Do not remove it yet. Please reach out for help.',
      'सावधान। यह ऐप चुपके से आप पर नज़र रख सकता है। आपकी सुरक्षा सबसे पहले है। इसे अभी न हटाएँ। कृपया मदद लें।',
      'ಎಚ್ಚರಿಕೆ. ಈ ಆ್ಯಪ್ ರಹಸ್ಯವಾಗಿ ನಿಮ್ಮ ಮೇಲೆ ಕಣ್ಣಿಡುತ್ತಿರಬಹುದು. ನಿಮ್ಮ ಸುರಕ್ಷತೆ ಮೊದಲು. ಈಗ ತೆಗೆಯಬೇಡಿ. ದಯವಿಟ್ಟು ಸಹಾಯ ಪಡೆಯಿರಿ.');
  static const hiddenApp = L('Hidden app', 'छिपा हुआ ऐप', 'ಮರೆಯಾದ ಆ್ಯಪ್');
  static const dpdpChildNote = L(
      "Under India's DPDP Act, tracking children is not allowed.",
      'भारत के DPDP कानून के तहत बच्चों को ट्रैक करना मना है।',
      'ಭಾರತದ DPDP ಕಾಯ್ದೆ ಪ್ರಕಾರ ಮಕ್ಕಳನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡುವುದು ನಿಷಿದ್ಧ.');

  // ── Emergency Hub ──
  static const emergencyHub =
      L('Emergency help', 'आपातकालीन मदद', 'ತುರ್ತು ಸಹಾಯ');
  static const emergencyHubSub = L('Been scammed? Get help right now',
      'ठगी हो गई? अभी मदद पाएँ', 'ಮೋಸ ಆಯ್ತಾ? ಈಗಲೇ ಸಹಾಯ ಪಡೆಯಿರಿ');
  static const call1930 = L('Call Cyber Police 1930', 'साइबर पुलिस 1930 को कॉल करें',
      'ಸೈಬರ್ ಪೊಲೀಸ್ 1930 ಗೆ ಕರೆ ಮಾಡಿ');
  static const call1930Sub = L(
      'National Cyber Crime Helpline · works without internet',
      'राष्ट्रीय साइबर क्राइम हेल्पलाइन · बिना इंटरनेट चलती है',
      'ರಾಷ್ಟ್ರೀಯ ಸೈಬರ್ ಅಪರಾಧ ಸಹಾಯವಾಣಿ · ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ');
  static const prepareReport =
      L('Prepare my report', 'मेरी रिपोर्ट तैयार करें', 'ನನ್ನ ವರದಿ ಸಿದ್ಧಪಡಿಸಿ');
  static const prepareReportSub = L(
      'We write the complaint for cybercrime.gov.in',
      'हम cybercrime.gov.in के लिए शिकायत लिख देंगे',
      'cybercrime.gov.in ಗಾಗಿ ನಾವು ದೂರು ಬರೆಯುತ್ತೇವೆ');
  static const reportViaWhatsapp = L('Report via WhatsApp',
      'WhatsApp से रिपोर्ट करें', 'WhatsApp ಮೂಲಕ ವರದಿ ಮಾಡಿ');
  static const reportViaWhatsappSub = L('Forward the fraud to Sanchar Saathi',
      'फ्रॉड को संचार साथी को फॉरवर्ड करें', 'ವಂಚನೆಯನ್ನು ಸಂಚಾರ್ ಸಾಥಿಗೆ ಕಳುಹಿಸಿ');
  static const reportAmount = L('How much money? (₹)', 'कितने पैसे? (₹)',
      'ಎಷ್ಟು ಹಣ? (₹)');
  static const reportWhen = L('When did it happen?', 'यह कब हुआ?', 'ಯಾವಾಗ ಆಯ್ತು?');
  static const reportWhat = L('What happened? (short)', 'क्या हुआ? (संक्षेप में)',
      'ಏನಾಯ್ತು? (ಸಂಕ್ಷಿಪ್ತ)');
  static const reportTxn = L('Transaction ID (if any)', 'ट्रांज़ैक्शन ID (यदि हो)',
      'ವಹಿವಾಟು ID (ಇದ್ದರೆ)');
  static const generateReport =
      L('Generate', 'बनाएँ', 'ರಚಿಸಿ');
  static const copyReport =
      L('Copy report', 'रिपोर्ट कॉपी करें', 'ವರದಿ ನಕಲಿಸಿ');
  static const copied = L('Copied!', 'कॉपी हो गया!', 'ನಕಲಿಸಲಾಗಿದೆ!');
  static const openPortal = L('Open portal', 'पोर्टल खोलें', 'ಪೋರ್ಟಲ್ ತೆರೆಯಿರಿ');

  // ── Quick Hide ──
  static const quickHideHint = L(
      'Tap the shield any time to hide this app instantly.',
      'इस ऐप को तुरंत छिपाने के लिए कभी भी शील्ड दबाएँ।',
      'ಈ ಆ್ಯಪ್ ಅನ್ನು ತಕ್ಷಣ ಮರೆಮಾಡಲು ಯಾವಾಗ ಬೇಕಾದರೂ ಶೀಲ್ಡ್ ಒತ್ತಿರಿ.');

  // ── Scam Scan ──
  static const scamScan = L('Scan a message', 'संदेश जाँचें', 'ಸಂದೇಶ ಪರಿಶೀಲಿಸಿ');
  static const scamScanSub = L(
      'Is this message, link or payment safe? Check it.',
      'क्या यह संदेश, लिंक या पेमेंट सुरक्षित है? जाँचें।',
      'ಈ ಸಂದೇಶ, ಲಿಂಕ್ ಅಥವಾ ಪಾವತಿ ಸುರಕ್ಷಿತವೇ? ಪರಿಶೀಲಿಸಿ.');
  static const pasteMessage = L('Paste the message or link here',
      'संदेश या लिंक यहाँ पेस्ट करें', 'ಸಂದೇಶ ಅಥವಾ ಲಿಂಕ್ ಇಲ್ಲಿ ಅಂಟಿಸಿ');
  static const pickScreenshot = L('Pick a screenshot', 'स्क्रीनशॉट चुनें',
      'ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಆಯ್ಕೆಮಾಡಿ');
  static const checkNow = L('Check now', 'अभी जाँचें', 'ಈಗ ಪರಿಶೀಲಿಸಿ');
  static const reading = L('Reading the image…', 'इमेज पढ़ी जा रही है…',
      'ಚಿತ್ರ ಓದಲಾಗುತ್ತಿದೆ…');
  static const resultSafe = L('SAFE', 'सुरक्षित', 'ಸುರಕ್ಷಿತ');
  static const resultSuspicious =
      L('SUSPICIOUS', 'संदिग्ध', 'ಸಂಶಯಾಸ್ಪದ');
  static const resultDangerous = L('DANGEROUS', 'खतरनाक', 'ಅಪಾಯಕಾರಿ');
  static const whatWeFound =
      L('What we found', 'हमें क्या मिला', 'ನಾವು ಏನು ಕಂಡೆವು');
  static const safeBody = L(
      'No common scam signs found. Still, stay careful with money and OTPs.',
      'कोई आम ठगी का संकेत नहीं मिला। फिर भी पैसे और OTP को लेकर सतर्क रहें।',
      'ಸಾಮಾನ್ಯ ಮೋಸದ ಚಿಹ್ನೆಗಳಿಲ್ಲ. ಆದರೂ ಹಣ ಮತ್ತು OTP ಬಗ್ಗೆ ಎಚ್ಚರವಾಗಿರಿ.');
  static const offlineMode =
      L('Offline mode · using saved rules', 'ऑफ़लाइन मोड · सहेजे नियमों से',
          'ಆಫ್‌ಲೈನ್ ಮೋಡ್ · ಉಳಿಸಿದ ನಿಯಮಗಳಿಂದ');
  static const ruleToRemember =
      L('Rule to remember', 'याद रखने का नियम', 'ನೆನಪಿಡುವ ನಿಯಮ');
  static const shareRule = L('Share on WhatsApp', 'WhatsApp पर शेयर करें',
      'WhatsApp ನಲ್ಲಿ ಹಂಚಿ');
  static const emptyInput = L('Paste a message or pick a screenshot first.',
      'पहले कोई संदेश पेस्ट करें या स्क्रीनशॉट चुनें।',
      'ಮೊದಲು ಸಂದೇಶ ಅಂಟಿಸಿ ಅಥವಾ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಆಯ್ಕೆಮಾಡಿ.');
  static const ocrFailed = L(
      'Could not read text from that image. Try pasting the message instead.',
      'उस इमेज से टेक्स्ट नहीं पढ़ पाए। संदेश पेस्ट करके देखें।',
      'ಆ ಚಿತ್ರದಿಂದ ಪಠ್ಯ ಓದಲಾಗಲಿಲ್ಲ. ಸಂದೇಶವನ್ನು ಅಂಟಿಸಿ ಪ್ರಯತ್ನಿಸಿ.');

  // ── Learning Zone ──
  static const learnZone = L('Learn & practice', 'सीखें और अभ्यास करें',
      'ಕಲಿಯಿರಿ ಮತ್ತು ಅಭ್ಯಾಸ');
  static const learnZoneSub = L('Spot scams on your own. No reading needed.',
      'खुद ठगी पहचानें। पढ़ने की ज़रूरत नहीं।',
      'ನೀವೇ ಮೋಸ ಗುರುತಿಸಿ. ಓದುವ ಅಗತ್ಯವಿಲ್ಲ.');
  static const lessons = L('Lessons', 'पाठ', 'ಪಾಠಗಳು');
  static const practice = L('Practice', 'अभ्यास', 'ಅಭ್ಯಾಸ');
  static const library = L('Real vs Fake', 'असली बनाम नकली', 'ನಿಜ vs ನಕಲಿ');
  static const badges = L('Badges', 'बैज', 'ಬ್ಯಾಡ್ಜ್');
  static const real = L('REAL', 'असली', 'ನಿಜ');
  static const fake = L('FAKE', 'नकली', 'ನಕಲಿ');
  static const theTell = L('The giveaway', 'पहचान', 'ಗುರುತು');
  static const listen = L('Listen', 'सुनें', 'ಕೇಳಿ');
  static const whatToDo = L('What to do', 'क्या करें', 'ಏನು ಮಾಡಬೇಕು');
  static const isThisSafe =
      L('Is this safe?', 'क्या यह सुरक्षित है?', 'ಇದು ಸುರಕ್ಷಿತವೇ?');
  static const itsSafe = L("It's safe", 'सुरक्षित है', 'ಸುರಕ್ಷಿತ');
  static const itsScam = L("It's a scam", 'यह ठगी है', 'ಇದು ಮೋಸ');
  static const correct = L('Correct! 🎉', 'सही! 🎉', 'ಸರಿ! 🎉');
  static const notQuite = L('Not quite', 'बिल्कुल सही नहीं', 'ಸರಿಯಲ್ಲ');
  static const nextOne = L('Next', 'अगला', 'ಮುಂದೆ');
  static const practiceDone =
      L('Practice complete!', 'अभ्यास पूरा!', 'ಅಭ್ಯಾಸ ಮುಗಿಯಿತು!');
  static const youScored = L('You scored', 'आपका स्कोर', 'ನಿಮ್ಮ ಅಂಕ');
  static const badgeEarned =
      L('Badge earned!', 'बैज मिला!', 'ಬ್ಯಾಡ್ಜ್ ಗಳಿಸಿದಿರಿ!');
  static const shareBadge = L('Share badge', 'बैज शेयर करें', 'ಬ್ಯಾಡ್ಜ್ ಹಂಚಿ');
  static const locked = L('Locked', 'बंद', 'ಲಾಕ್');
  static const tapToStart = L('Tap to start', 'शुरू करने के लिए टैप करें',
      'ಪ್ರಾರಂಭಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ');

  // ── Trusted Circle ──
  static const trustedCircle =
      L('Trusted circle', 'भरोसेमंद लोग', 'ನಂಬಿಕೆಯ ವಲಯ');
  static const trustedCircleSub = L(
      'Add someone you trust. Alert them in one tap.',
      'किसी भरोसेमंद को जोड़ें। एक टैप में सूचित करें।',
      'ನೀವು ನಂಬುವವರನ್ನು ಸೇರಿಸಿ. ಒಂದೇ ಟ್ಯಾಪ್‌ನಲ್ಲಿ ಎಚ್ಚರಿಸಿ.');
  static const addTrusted =
      L('Add a trusted person', 'भरोसेमंद व्यक्ति जोड़ें', 'ನಂಬಿಕೆಯ ವ್ಯಕ್ತಿ ಸೇರಿಸಿ');
  static const contactName = L('Their name', 'उनका नाम', 'ಅವರ ಹೆಸರು');
  static const contactNumber = L('Their phone number', 'उनका फ़ोन नंबर',
      'ಅವರ ಫೋನ್ ನಂಬರ್');
  static const saveContact = L('Save', 'सहेजें', 'ಉಳಿಸಿ');
  static const sendIntro = L('Send intro SMS', 'परिचय SMS भेजें',
      'ಪರಿಚಯ SMS ಕಳುಹಿಸಿ');
  static const alertContact = L('Alert my trusted person',
      'मेरे भरोसेमंद व्यक्ति को सूचित करें', 'ನನ್ನ ನಂಬಿಕೆಯ ವ್ಯಕ್ತಿಗೆ ಎಚ್ಚರಿಸಿ');
  static const noTrusted = L('No trusted person added yet.',
      'अभी कोई भरोसेमंद व्यक्ति नहीं जोड़ा।',
      'ಇನ್ನೂ ನಂಬಿಕೆಯ ವ್ಯಕ್ತಿ ಸೇರಿಸಿಲ್ಲ.');
  static const removeContact = L('Remove', 'हटाएँ', 'ತೆಗೆದುಹಾಕಿ');
  static const weeklySummary = L('Share weekly safety summary',
      'साप्ताहिक सुरक्षा सारांश शेयर करें', 'ವಾರದ ಸುರಕ್ಷತಾ ಸಾರಾಂಶ ಹಂಚಿ');
  static const weeklySummarySub = L(
      'A short update for your trusted person — no private details.',
      'आपके भरोसेमंद व्यक्ति के लिए छोटा अपडेट — कोई निजी जानकारी नहीं।',
      'ನಿಮ್ಮ ನಂಬಿಕೆಯ ವ್ಯಕ್ತಿಗೆ ಚಿಕ್ಕ ಅಪ್‌ಡೇಟ್ — ಖಾಸಗಿ ವಿವರಗಳಿಲ್ಲ.');

  // ── Safe Handoff / Kids Mode ──
  static const kidsMode = L('Safe Handoff (Kids)', 'सुरक्षित हैंडऑफ़ (बच्चे)',
      'ಸುರಕ್ಷಿತ ಹ್ಯಾಂಡ್‌ಆಫ್ (ಮಕ್ಕಳು)');
  static const kidsModeSub = L('Hand the phone to a child safely',
      'फ़ोन बच्चे को सुरक्षित रूप से दें', 'ಫೋನ್ ಅನ್ನು ಮಗುವಿಗೆ ಸುರಕ್ಷಿತವಾಗಿ ಕೊಡಿ');
  static const setPin = L('Set a 4-digit PIN to exit',
      'बाहर निकलने के लिए 4 अंकों का PIN सेट करें',
      'ನಿರ್ಗಮಿಸಲು 4-ಅಂಕಿ PIN ಹೊಂದಿಸಿ');
  static const enterPin = L('Enter PIN to exit', 'बाहर निकलने के लिए PIN डालें',
      'ನಿರ್ಗಮಿಸಲು PIN ನಮೂದಿಸಿ');
  static const wrongPin = L('Wrong PIN', 'गलत PIN', 'ತಪ್ಪು PIN');
  static const startKidsMode = L('Start Kids Mode', 'बच्चों का मोड शुरू करें',
      'ಮಕ್ಕಳ ಮೋಡ್ ಪ್ರಾರಂಭಿಸಿ');
  static const kidsModeNote = L(
      'A simple, safe screen. To leave, a grown-up enters the PIN. (Screen-lock is best-effort on this phone.)',
      'एक सरल, सुरक्षित स्क्रीन। बाहर निकलने के लिए बड़े PIN डालें। (इस फ़ोन पर स्क्रीन-लॉक सर्वोत्तम-प्रयास है।)',
      'ಸರಳ, ಸುರಕ್ಷಿತ ಪರದೆ. ಹೊರಹೋಗಲು ದೊಡ್ಡವರು PIN ನಮೂದಿಸಬೇಕು. (ಈ ಫೋನ್‌ನಲ್ಲಿ ಸ್ಕ್ರೀನ್-ಲಾಕ್ ಬೆಸ್ಟ್-ಎಫರ್ಟ್.)');
  static const kidsHi = L('Hi! 👋 Let\'s have fun safely.',
      'नमस्ते! 👋 चलो सुरक्षित मज़े करें।', 'ನಮಸ್ಕಾರ! 👋 ಸುರಕ್ಷಿತವಾಗಿ ಮಜಾ ಮಾಡೋಣ.');
}
