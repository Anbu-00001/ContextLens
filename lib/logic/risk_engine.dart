// ── ConsentLens risk engine ────────────────────────────────────────────────
// 100% local, rule-based classification. No network calls, ever.

import 'i18n.dart';

enum Risk { low, medium, high }

enum AnimKind { flow, wave, blink }

enum Fit { ok, caution, no }

class PermCategory {
  final String id;
  final List<String> emojis; // emoji flow for the animation strip
  final AnimKind anim;
  final Risk risk;
  final L title, why, consequence, kidRisk, teenRisk, adultRisk;

  const PermCategory({
    required this.id,
    required this.emojis,
    this.anim = AnimKind.flow,
    required this.risk,
    required this.title,
    required this.why,
    required this.consequence,
    required this.kidRisk,
    required this.teenRisk,
    required this.adultRisk,
  });

  L get riskLabel =>
      risk == Risk.high ? S.high : (risk == Risk.medium ? S.medium : S.low);
}

// ── Catalog: 15 categories covering the common Android permissions ─────────
const List<PermCategory> catalog = [
  PermCategory(
    id: 'location',
    emojis: ['🏠', '📍', '🏢'],
    risk: Risk.high,
    title: L('Location', 'लोकेशन', 'ಸ್ಥಳ (ಲೊಕೇಶನ್)'),
    why: L('To show maps, deliveries or nearby things.',
        'नक्शे, डिलीवरी या आस-पास की चीज़ें दिखाने के लिए।',
        'ನಕ್ಷೆ, ಡೆಲಿವರಿ ಅಥವಾ ಹತ್ತಿರದ ವಿಷಯ ತೋರಿಸಲು.'),
    consequence: L('The app can learn where you live, study and work.',
        'ऐप जान सकता है कि आप कहाँ रहते, पढ़ते और काम करते हैं।',
        'ನೀವು ಎಲ್ಲಿ ವಾಸಿಸುತ್ತೀರಿ, ಓದುತ್ತೀರಿ, ಕೆಲಸ ಮಾಡುತ್ತೀರಿ ಎಂದು ಆ್ಯಪ್ ತಿಳಿಯಬಹುದು.'),
    kidRisk: L('Strangers could find your home or school. 🏠',
        'अजनबी आपका घर या स्कूल ढूँढ सकते हैं। 🏠',
        'ಅಪರಿಚಿತರು ನಿಮ್ಮ ಮನೆ ಅಥವಾ ಶಾಲೆ ಕಂಡುಹಿಡಿಯಬಹುದು. 🏠'),
    teenRisk: L('Your daily movements can be tracked and shared.',
        'आपकी रोज़ की आवाजाही ट्रैक और शेयर हो सकती है।',
        'ನಿಮ್ಮ ದಿನನಿತ್ಯದ ಓಡಾಟ ಟ್ರ್ಯಾಕ್ ಆಗಿ ಹಂಚಿಕೆಯಾಗಬಹುದು.'),
    adultRisk: L('Advertisers may profile your home and office locations.',
        'विज्ञापन कंपनियाँ आपके घर-दफ़्तर की प्रोफ़ाइल बना सकती हैं।',
        'ಜಾಹೀರಾತುದಾರರು ನಿಮ್ಮ ಮನೆ-ಕಚೇರಿ ಸ್ಥಳಗಳ ಪ್ರೊಫೈಲ್ ಮಾಡಬಹುದು.'),
  ),
  PermCategory(
    id: 'bg_location',
    emojis: ['🌙', '📍', '🗺️'],
    risk: Risk.high,
    title: L('Background location', 'बैकग्राउंड लोकेशन', 'ಹಿನ್ನೆಲೆ ಸ್ಥಳ'),
    why: L('To track location even when the app is closed.',
        'ऐप बंद होने पर भी लोकेशन जानने के लिए।',
        'ಆ್ಯಪ್ ಮುಚ್ಚಿದ್ದರೂ ಸ್ಥಳ ತಿಳಿಯಲು.'),
    consequence: L('It can follow you all day, everywhere you go.',
        'यह दिनभर, हर जगह आपका पीछा कर सकता है।',
        'ಇದು ದಿನವಿಡೀ, ಎಲ್ಲೆಡೆ ನಿಮ್ಮನ್ನು ಹಿಂಬಾಲಿಸಬಹುದು.'),
    kidRisk: L('The app knows where you are even while you sleep. 😴',
        'आप सोते समय भी ऐप जानता है कि आप कहाँ हैं। 😴',
        'ನೀವು ಮಲಗಿರುವಾಗಲೂ ನೀವು ಎಲ್ಲಿದ್ದೀರಿ ಎಂದು ಆ್ಯಪ್‌ಗೆ ಗೊತ್ತು. 😴'),
    teenRisk: L('Your hangout spots can be recorded 24/7.',
        'आपके घूमने-फिरने की जगहें 24/7 दर्ज हो सकती हैं।',
        'ನೀವು ಸುತ್ತಾಡುವ ಸ್ಥಳಗಳು 24/7 ದಾಖಲಾಗಬಹುದು.'),
    adultRisk: L('Your full movement history may be stored and sold.',
        'आपकी पूरी आवाजाही का इतिहास सहेजा और बेचा जा सकता है।',
        'ನಿಮ್ಮ ಸಂಪೂರ್ಣ ಓಡಾಟದ ಇತಿಹಾಸ ಸಂಗ್ರಹವಾಗಿ ಮಾರಾಟವಾಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'camera',
    emojis: ['📷', '👤'],
    anim: AnimKind.blink,
    risk: Risk.high,
    title: L('Camera', 'कैमरा', 'ಕ್ಯಾಮೆರಾ'),
    why: L('For photos, video calls or scanning.',
        'फ़ोटो, वीडियो कॉल या स्कैन करने के लिए।',
        'ಫೋಟೋ, ವೀಡಿಯೊ ಕರೆ ಅಥವಾ ಸ್ಕ್ಯಾನ್ ಮಾಡಲು.'),
    consequence: L('It can take photos or record video.',
        'यह फ़ोटो खींच सकता है या वीडियो रिकॉर्ड कर सकता है।',
        'ಇದು ಫೋಟೋ ತೆಗೆಯಬಹುದು ಅಥವಾ ವೀಡಿಯೊ ರೆಕಾರ್ಡ್ ಮಾಡಬಹುದು.'),
    kidRisk: L('Someone could see you or your room. 🙈',
        'कोई आपको या आपका कमरा देख सकता है। 🙈',
        'ಯಾರಾದರೂ ನಿಮ್ಮನ್ನು ಅಥವಾ ನಿಮ್ಮ ಕೋಣೆಯನ್ನು ನೋಡಬಹುದು. 🙈'),
    teenRisk: L('Private photos could be captured or misused.',
        'निजी तस्वीरें खींची या गलत इस्तेमाल हो सकती हैं।',
        'ಖಾಸಗಿ ಫೋಟೋಗಳು ಸೆರೆಯಾಗಿ ದುರ್ಬಳಕೆಯಾಗಬಹುದು.'),
    adultRisk: L('Meetings or documents could be recorded.',
        'मीटिंग या दस्तावेज़ रिकॉर्ड हो सकते हैं।',
        'ಸಭೆಗಳು ಅಥವಾ ದಾಖಲೆಗಳು ರೆಕಾರ್ಡ್ ಆಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'microphone',
    emojis: ['🎙️'],
    anim: AnimKind.wave,
    risk: Risk.high,
    title: L('Microphone', 'माइक्रोफ़ोन', 'ಮೈಕ್ರೊಫೋನ್'),
    why: L('For calls, voice notes or voice search.',
        'कॉल, वॉइस नोट या आवाज़ से खोज के लिए।',
        'ಕರೆ, ಧ್ವನಿ ಟಿಪ್ಪಣಿ ಅಥವಾ ಧ್ವನಿ ಹುಡುಕಾಟಕ್ಕೆ.'),
    consequence: L('It can listen to and record what you say.',
        'यह आपकी बातें सुन और रिकॉर्ड कर सकता है।',
        'ಇದು ನಿಮ್ಮ ಮಾತುಗಳನ್ನು ಕೇಳಿ ರೆಕಾರ್ಡ್ ಮಾಡಬಹುದು.'),
    kidRisk: L('It can hear you and your family talking. 👂',
        'यह आपकी और परिवार की बातें सुन सकता है। 👂',
        'ಇದು ನಿಮ್ಮ ಮತ್ತು ಕುಟುಂಬದ ಮಾತುಗಳನ್ನು ಕೇಳಬಹುದು. 👂'),
    teenRisk: L('Private conversations could be recorded.',
        'निजी बातचीत रिकॉर्ड हो सकती है।', 'ಖಾಸಗಿ ಮಾತುಕತೆ ರೆಕಾರ್ಡ್ ಆಗಬಹುದು.'),
    adultRisk: L('Work calls could be captured.', 'काम की कॉल रिकॉर्ड हो सकती हैं।',
        'ಕೆಲಸದ ಕರೆಗಳು ಸೆರೆಯಾಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'contacts',
    emojis: ['👥', '📤'],
    risk: Risk.high,
    title: L('Contacts', 'संपर्क (कॉन्टैक्ट्स)', 'ಸಂಪರ್ಕಗಳು'),
    why: L('To find friends or share with people you know.',
        'दोस्तों को ढूँढने या जान-पहचान वालों से शेयर करने के लिए।',
        'ಸ್ನೇಹಿತರನ್ನು ಹುಡುಕಲು ಅಥವಾ ಪರಿಚಿತರೊಂದಿಗೆ ಹಂಚಲು.'),
    consequence: L('Names and numbers of everyone you know can be copied.',
        'आपके सभी जान-पहचान वालों के नाम-नंबर कॉपी हो सकते हैं।',
        'ನಿಮಗೆ ಗೊತ್ತಿರುವ ಎಲ್ಲರ ಹೆಸರು-ನಂಬರ್ ನಕಲಾಗಬಹುದು.'),
    kidRisk: L('Family phone numbers could go to strangers. 📵',
        'परिवार के नंबर अजनबियों तक पहुँच सकते हैं। 📵',
        'ಕುಟುಂಬದ ನಂಬರ್‌ಗಳು ಅಪರಿಚಿತರಿಗೆ ಹೋಗಬಹುದು. 📵'),
    teenRisk: L('Your friends may start getting spam calls.',
        'आपके दोस्तों को स्पैम कॉल आ सकती हैं।',
        'ನಿಮ್ಮ ಸ್ನೇಹಿತರಿಗೆ ಸ್ಪ್ಯಾಮ್ ಕರೆಗಳು ಬರಬಹುದು.'),
    adultRisk: L('Your whole network can be uploaded and sold.',
        'आपका पूरा नेटवर्क अपलोड और बेचा जा सकता है।',
        'ನಿಮ್ಮ ಇಡೀ ನೆಟ್‌ವರ್ಕ್ ಅಪ್‌ಲೋಡ್ ಆಗಿ ಮಾರಾಟವಾಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'sms',
    emojis: ['✉️', '👀'],
    risk: Risk.high,
    title: L('Messages (SMS)', 'संदेश (SMS)', 'ಸಂದೇಶಗಳು (SMS)'),
    why: L('To read OTP codes or send messages.',
        'OTP पढ़ने या संदेश भेजने के लिए।', 'OTP ಓದಲು ಅಥವಾ ಸಂದೇಶ ಕಳುಹಿಸಲು.'),
    consequence: L('It can read your private messages, including bank OTPs.',
        'यह आपके निजी संदेश, बैंक OTP समेत, पढ़ सकता है।',
        'ಇದು ಬ್ಯಾಂಕ್ OTP ಸೇರಿದಂತೆ ನಿಮ್ಮ ಖಾಸಗಿ ಸಂದೇಶ ಓದಬಹುದು.'),
    kidRisk: L('It can read your family\'s messages. ✉️',
        'यह परिवार के संदेश पढ़ सकता है। ✉️',
        'ಇದು ಕುಟುಂಬದ ಸಂದೇಶಗಳನ್ನು ಓದಬಹುದು. ✉️'),
    teenRisk: L('Private chats can be read by the app.',
        'निजी चैट ऐप पढ़ सकता है।', 'ಖಾಸಗಿ ಚಾಟ್‌ಗಳನ್ನು ಆ್ಯಪ್ ಓದಬಹುದು.'),
    adultRisk: L('Bank OTPs and money messages can be stolen.',
        'बैंक OTP और पैसों के संदेश चोरी हो सकते हैं।',
        'ಬ್ಯಾಂಕ್ OTP ಮತ್ತು ಹಣದ ಸಂದೇಶಗಳು ಕಳವಾಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'calls',
    emojis: ['📞', '📝'],
    risk: Risk.high,
    title: L('Phone & call log', 'फ़ोन और कॉल लॉग', 'ಫೋನ್ ಮತ್ತು ಕರೆ ದಾಖಲೆ'),
    why: L('To make calls or show who called you.',
        'कॉल करने या यह दिखाने के लिए कि किसने कॉल किया।',
        'ಕರೆ ಮಾಡಲು ಅಥವಾ ಯಾರು ಕರೆ ಮಾಡಿದರು ಎಂದು ತೋರಿಸಲು.'),
    consequence: L('It can see who you call and even dial numbers.',
        'यह देख सकता है कि आप किसे कॉल करते हैं, और खुद नंबर मिला भी सकता है।',
        'ನೀವು ಯಾರಿಗೆ ಕರೆ ಮಾಡುತ್ತೀರಿ ಎಂದು ನೋಡಬಹುದು, ತಾನೇ ಕರೆಯನ್ನೂ ಮಾಡಬಹುದು.'),
    kidRisk: L('It could call numbers without you knowing. ☎️',
        'यह आपकी जानकारी के बिना कॉल कर सकता है। ☎️',
        'ನಿಮಗೆ ಗೊತ್ತಿಲ್ಲದೆ ಇದು ಕರೆ ಮಾಡಬಹುದು. ☎️'),
    teenRisk: L('Your call list can be copied.', 'आपकी कॉल सूची कॉपी हो सकती है।',
        'ನಿಮ್ಮ ಕರೆ ಪಟ್ಟಿ ನಕಲಾಗಬಹುದು.'),
    adultRisk: L('Business contacts and call habits get exposed.',
        'कारोबारी संपर्क और कॉल की आदतें उजागर हो सकती हैं।',
        'ವ್ಯವಹಾರ ಸಂಪರ್ಕಗಳು ಮತ್ತು ಕರೆ ಅಭ್ಯಾಸ ಬಯಲಾಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'storage',
    emojis: ['📁', '☁️'],
    risk: Risk.medium,
    title: L('Photos & files', 'फ़ोटो और फ़ाइलें', 'ಫೋಟೋ ಮತ್ತು ಫೈಲ್‌ಗಳು'),
    why: L('To save or open photos and files.',
        'फ़ोटो और फ़ाइलें सहेजने या खोलने के लिए।',
        'ಫೋಟೋ ಮತ್ತು ಫೈಲ್‌ಗಳನ್ನು ಉಳಿಸಲು ಅಥವಾ ತೆರೆಯಲು.'),
    consequence: L('It can see your photos, videos and documents.',
        'यह आपकी फ़ोटो, वीडियो और दस्तावेज़ देख सकता है।',
        'ಇದು ನಿಮ್ಮ ಫೋಟೋ, ವೀಡಿಯೊ, ದಾಖಲೆಗಳನ್ನು ನೋಡಬಹುದು.'),
    kidRisk: L('Family photos could be seen by the app. 🖼️',
        'परिवार की तस्वीरें ऐप देख सकता है। 🖼️',
        'ಕುಟುಂಬದ ಫೋಟೋಗಳನ್ನು ಆ್ಯಪ್ ನೋಡಬಹುದು. 🖼️'),
    teenRisk: L('Private pictures could be uploaded.',
        'निजी तस्वीरें अपलोड हो सकती हैं।', 'ಖಾಸಗಿ ಚಿತ್ರಗಳು ಅಪ್‌ಲೋಡ್ ಆಗಬಹುದು.'),
    adultRisk: L('Personal documents may be scanned.',
        'निजी दस्तावेज़ स्कैन हो सकते हैं।', 'ವೈಯಕ್ತಿಕ ದಾಖಲೆಗಳು ಸ್ಕ್ಯಾನ್ ಆಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'notifications',
    emojis: ['🔔', '📱'],
    risk: Risk.low,
    title: L('Notifications', 'सूचनाएँ', 'ಅಧಿಸೂಚನೆಗಳು'),
    why: L('To send you alerts and updates.', 'आपको अलर्ट और अपडेट भेजने के लिए।',
        'ನಿಮಗೆ ಎಚ್ಚರಿಕೆ ಮತ್ತು ಅಪ್‌ಡೇಟ್ ಕಳುಹಿಸಲು.'),
    consequence: L('It can ping you any time, even at night.',
        'यह कभी भी, रात में भी, सूचना भेज सकता है।',
        'ಇದು ಯಾವಾಗ ಬೇಕಾದರೂ, ರಾತ್ರಿಯೂ ಸಹ, ಸೂಚನೆ ಕಳುಹಿಸಬಹುದು.'),
    kidRisk: L('Pop-ups may show things not meant for kids. 🚸',
        'पॉपअप में बच्चों के लिए अनुचित चीज़ें दिख सकती हैं। 🚸',
        'ಮಕ್ಕಳಿಗೆ ಸೂಕ್ತವಲ್ಲದ ವಿಷಯ ಪಾಪ್‌ಅಪ್‌ನಲ್ಲಿ ಬರಬಹುದು. 🚸'),
    teenRisk: L('Endless pings can distract you from study.',
        'लगातार सूचनाएँ पढ़ाई से ध्यान भटका सकती हैं।',
        'ನಿರಂತರ ಸೂಚನೆಗಳು ಓದಿನಿಂದ ಗಮನ ಕದಿಯಬಹುದು.'),
    adultRisk: L('Promotional spam can flood your screen.',
        'प्रचार वाला स्पैम स्क्रीन भर सकता है।',
        'ಜಾಹೀರಾತು ಸ್ಪ್ಯಾಮ್ ಪರದೆ ತುಂಬಬಹುದು.'),
  ),
  PermCategory(
    id: 'sensors',
    emojis: ['❤️', '📊'],
    risk: Risk.medium,
    title: L('Body & activity sensors', 'शरीर और गतिविधि सेंसर',
        'ದೇಹ ಮತ್ತು ಚಟுವಟಿಕೆ ಸಂವೇದಕ'),
    why: L('To count steps or check heart rate.',
        'कदम गिनने या दिल की धड़कन जाँचने के लिए।',
        'ಹೆಜ್ಜೆ ಎಣಿಸಲು ಅಥವಾ ಹೃದಯ ಬಡಿತ ನೋಡಲು.'),
    consequence: L('It learns your health and activity patterns.',
        'यह आपकी सेहत और गतिविधि का पैटर्न जान लेता है।',
        'ಇದು ನಿಮ್ಮ ಆರೋಗ್ಯ ಮತ್ತು ಚಟುವಟಿಕೆಯ ಮಾದರಿ ತಿಳಿಯುತ್ತದೆ.'),
    kidRisk: L('It knows when you sleep and play. 🛌',
        'यह जानता है कि आप कब सोते-खेलते हैं। 🛌',
        'ನೀವು ಯಾವಾಗ ಮಲಗುತ್ತೀರಿ, ಆಡುತ್ತೀರಿ ಎಂದು ಇದಕ್ಕೆ ಗೊತ್ತು. 🛌'),
    teenRisk: L('Fitness data may be shared with others.',
        'फिटनेस डेटा दूसरों से साझा हो सकता है।',
        'ಫಿಟ್‌ನೆಸ್ ಡೇಟಾ ಇತರರಿಗೆ ಹಂಚಿಕೆಯಾಗಬಹುದು.'),
    adultRisk: L('Health data could affect insurance or ads.',
        'सेहत का डेटा बीमा या विज्ञापनों पर असर डाल सकता है।',
        'ಆರೋಗ್ಯ ಡೇಟಾ ವಿಮೆ ಅಥವಾ ಜಾಹೀರಾತಿನ ಮೇಲೆ ಪರಿಣಾಮ ಬೀರಬಹುದು.'),
  ),
  PermCategory(
    id: 'nearby',
    emojis: ['📡', '📱'],
    risk: Risk.low,
    title: L('Bluetooth & nearby devices', 'ब्लूटूथ और नज़दीकी डिवाइस',
        'ಬ್ಲೂಟೂತ್ ಮತ್ತು ಹತ್ತಿರದ ಸಾಧನಗಳು'),
    why: L('To connect earphones, watches or nearby devices.',
        'ईयरफ़ोन, घड़ी या नज़दीकी डिवाइस जोड़ने के लिए।',
        'ಇಯರ್‌ಫೋನ್, ವಾಚ್ ಅಥವಾ ಹತ್ತಿರದ ಸಾಧನ ಸಂಪರ್ಕಿಸಲು.'),
    consequence: L('It can sense devices and people near you.',
        'यह आपके आस-पास के डिवाइस और लोगों को भाँप सकता है।',
        'ನಿಮ್ಮ ಸುತ್ತಲಿನ ಸಾಧನ ಮತ್ತು ಜನರನ್ನು ಇದು ಗ್ರಹಿಸಬಹುದು.'),
    kidRisk: L('It can tell who is around you. 🧑‍🤝‍🧑',
        'यह बता सकता है कि आपके पास कौन है। 🧑‍🤝‍🧑',
        'ನಿಮ್ಮ ಹತ್ತಿರ ಯಾರಿದ್ದಾರೆ ಎಂದು ಇದು ಹೇಳಬಹುದು. 🧑‍🤝‍🧑'),
    teenRisk: L('Your presence at places can be detected.',
        'आप कहाँ मौजूद हैं, इसका पता चल सकता है।',
        'ನೀವು ಎಲ್ಲಿ ಇದ್ದೀರಿ ಎಂದು ಪತ್ತೆಯಾಗಬಹುದು.'),
    adultRisk: L('Can be used for indoor location tracking.',
        'इमारत के अंदर लोकेशन ट्रैकिंग में इस्तेमाल हो सकता है।',
        'ಒಳಾಂಗಣ ಸ್ಥಳ ಟ್ರ್ಯಾಕಿಂಗ್‌ಗೆ ಬಳಕೆಯಾಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'phone_state',
    emojis: ['📱', '🆔'],
    risk: Risk.medium,
    title: L('Phone identity', 'फ़ोन की पहचान', 'ಫೋನ್ ಗುರುತು'),
    why: L('To know your phone number and network.',
        'आपका फ़ोन नंबर और नेटवर्क जानने के लिए।',
        'ನಿಮ್ಮ ಫೋನ್ ನಂಬರ್ ಮತ್ತು ನೆಟ್‌ವರ್ಕ್ ತಿಳಿಯಲು.'),
    consequence: L('It can read your phone\'s identity number.',
        'यह आपके फ़ोन का पहचान नंबर पढ़ सकता है।',
        'ಇದು ನಿಮ್ಮ ಫೋನಿನ ಗುರುತಿನ ಸಂಖ್ಯೆ ಓದಬಹುದು.'),
    kidRisk: L('Your phone can be uniquely identified. 🔎',
        'आपका फ़ोन अलग से पहचाना जा सकता है। 🔎',
        'ನಿಮ್ಮ ಫೋನನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ಗುರುತಿಸಬಹುದು. 🔎'),
    teenRisk: L('Apps can track you across devices.',
        'ऐप्स आपको कई डिवाइस पर ट्रैक कर सकते हैं।',
        'ಆ್ಯಪ್‌ಗಳು ನಿಮ್ಮನ್ನು ಹಲವು ಸಾಧನಗಳಲ್ಲಿ ಟ್ರ್ಯಾಕ್ ಮಾಡಬಹುದು.'),
    adultRisk: L('Device ID may be used to profile you everywhere.',
        'डिवाइस ID से हर जगह आपकी प्रोफ़ाइल बन सकती है।',
        'ಸಾಧನ ID ಬಳಸಿ ಎಲ್ಲೆಡೆ ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಮಾಡಬಹುದು.'),
  ),
  PermCategory(
    id: 'overlay',
    emojis: ['🪟', '📱'],
    risk: Risk.medium,
    title: L('Draw over other apps', 'दूसरे ऐप्स के ऊपर दिखाना',
        'ಇತರ ಆ್ಯಪ್‌ಗಳ ಮೇಲೆ ತೋರಿಸುವುದು'),
    why: L('To show bubbles or popups over other apps.',
        'दूसरे ऐप्स के ऊपर बबल या पॉपअप दिखाने के लिए।',
        'ಇತರ ಆ್ಯಪ್‌ಗಳ ಮೇಲೆ ಬಬಲ್ ಅಥವಾ ಪಾಪ್‌ಅಪ್ ತೋರಿಸಲು.'),
    consequence: L('It can draw on top of any app you use.',
        'यह आपके किसी भी ऐप के ऊपर स्क्रीन बना सकता है।',
        'ನೀವು ಬಳಸುವ ಯಾವುದೇ ಆ್ಯಪ್ ಮೇಲೆ ಇದು ಪರದೆ ಬರೆಯಬಹುದು.'),
    kidRisk: L('Fake screens could trick you into tapping. 🎭',
        'नकली स्क्रीन आपसे गलत जगह टैप करवा सकती है। 🎭',
        'ನಕಲಿ ಪರದೆಗಳು ತಪ್ಪಾಗಿ ಟ್ಯಾಪ್ ಮಾಡಿಸಬಹುದು. 🎭'),
    teenRisk: L('Fake login screens can steal passwords.',
        'नकली लॉगिन स्क्रीन पासवर्ड चुरा सकती है।',
        'ನಕಲಿ ಲಾಗಿನ್ ಪರದೆಗಳು ಪಾಸ್‌ವರ್ಡ್ ಕದಿಯಬಹುದು.'),
    adultRisk: L('Banking screens can be overlaid and faked.',
        'बैंकिंग स्क्रीन के ऊपर नकली स्क्रीन आ सकती है।',
        'ಬ್ಯಾಂಕಿಂಗ್ ಪರದೆಯ ಮೇಲೆ ನಕಲಿ ಪರದೆ ಬರಬಹುದು.'),
  ),
  PermCategory(
    id: 'calendar',
    emojis: ['📅', '👀'],
    risk: Risk.medium,
    title: L('Calendar', 'कैलेंडर', 'ಕ್ಯಾಲೆಂಡರ್'),
    why: L('To add events and reminders.', 'इवेंट और रिमाइंडर जोड़ने के लिए।',
        'ಈವೆಂಟ್ ಮತ್ತು ರಿಮೈಂಡರ್ ಸೇರಿಸಲು.'),
    consequence: L('It can read your meetings and plans.',
        'यह आपकी मीटिंग और योजनाएँ पढ़ सकता है।',
        'ಇದು ನಿಮ್ಮ ಸಭೆ ಮತ್ತು ಯೋಜನೆಗಳನ್ನು ಓದಬಹುದು.'),
    kidRisk: L('It knows your school and family schedule. 🏫',
        'यह आपके स्कूल और परिवार का शेड्यूल जानता है। 🏫',
        'ನಿಮ್ಮ ಶಾಲೆ ಮತ್ತು ಕುಟುಂಬದ ವೇಳಾಪಟ್ಟಿ ಇದಕ್ಕೆ ಗೊತ್ತು. 🏫'),
    teenRisk: L('Your plans could be visible to the app.',
        'आपकी योजनाएँ ऐप को दिख सकती हैं।',
        'ನಿಮ್ಮ ಯೋಜನೆಗಳು ಆ್ಯಪ್‌ಗೆ ಕಾಣಬಹುದು.'),
    adultRisk: L('Business meetings could leak.', 'कारोबारी मीटिंग लीक हो सकती हैं।',
        'ವ್ಯವಹಾರ ಸಭೆಗಳು ಸೋರಿಕೆಯಾಗಬಹುದು.'),
  ),
  PermCategory(
    id: 'internet',
    emojis: ['🌐', '☁️'],
    risk: Risk.low,
    title: L('Internet', 'इंटरनेट', 'ಇಂಟರ್ನೆಟ್'),
    why: L('To load content and sync data.', 'सामग्री लोड और डेटा सिंक करने के लिए।',
        'ವಿಷಯ ಲೋಡ್ ಮಾಡಲು ಮತ್ತು ಡೇಟಾ ಸಿಂಕ್ ಮಾಡಲು.'),
    consequence: L('It can send data from your phone to its servers.',
        'यह आपके फ़ोन से डेटा अपने सर्वर भेज सकता है।',
        'ಇದು ನಿಮ್ಮ ಫೋನಿನಿಂದ ಡೇಟಾವನ್ನು ತನ್ನ ಸರ್ವರ್‌ಗೆ ಕಳುಹಿಸಬಹುದು.'),
    kidRisk: L('Things you do can be sent out of the phone. 📤',
        'आप जो करते हैं, वह फ़ोन से बाहर भेजा जा सकता है। 📤',
        'ನೀವು ಮಾಡುವ ವಿಷಯಗಳು ಫೋನಿನಿಂದ ಹೊರ ಹೋಗಬಹುದು. 📤'),
    teenRisk: L('Your usage data can be uploaded.',
        'आपके इस्तेमाल का डेटा अपलोड हो सकता है।',
        'ನಿಮ್ಮ ಬಳಕೆಯ ಡೇಟಾ ಅಪ್‌ಲೋಡ್ ಆಗಬಹುದು.'),
    adultRisk: L('Data can leave your device silently.',
        'डेटा चुपचाप डिवाइस से बाहर जा सकता है।',
        'ಡೇಟಾ ಸದ್ದಿಲ್ಲದೆ ಸಾಧನದಿಂದ ಹೊರಹೋಗಬಹುದು.'),
  ),
];

// ── Android permission string → category id ────────────────────────────────
const Map<String, String> _permToCategory = {
  'android.permission.ACCESS_FINE_LOCATION': 'location',
  'android.permission.ACCESS_COARSE_LOCATION': 'location',
  'android.permission.ACCESS_BACKGROUND_LOCATION': 'bg_location',
  'android.permission.CAMERA': 'camera',
  'android.permission.RECORD_AUDIO': 'microphone',
  'android.permission.READ_CONTACTS': 'contacts',
  'android.permission.WRITE_CONTACTS': 'contacts',
  'android.permission.GET_ACCOUNTS': 'contacts',
  'android.permission.READ_SMS': 'sms',
  'android.permission.RECEIVE_SMS': 'sms',
  'android.permission.SEND_SMS': 'sms',
  'android.permission.READ_CALL_LOG': 'calls',
  'android.permission.WRITE_CALL_LOG': 'calls',
  'android.permission.CALL_PHONE': 'calls',
  'android.permission.PROCESS_OUTGOING_CALLS': 'calls',
  'android.permission.READ_EXTERNAL_STORAGE': 'storage',
  'android.permission.WRITE_EXTERNAL_STORAGE': 'storage',
  'android.permission.MANAGE_EXTERNAL_STORAGE': 'storage',
  'android.permission.READ_MEDIA_IMAGES': 'storage',
  'android.permission.READ_MEDIA_VIDEO': 'storage',
  'android.permission.READ_MEDIA_AUDIO': 'storage',
  'android.permission.POST_NOTIFICATIONS': 'notifications',
  'android.permission.BODY_SENSORS': 'sensors',
  'android.permission.ACTIVITY_RECOGNITION': 'sensors',
  'android.permission.BLUETOOTH_CONNECT': 'nearby',
  'android.permission.BLUETOOTH_SCAN': 'nearby',
  'android.permission.NEARBY_WIFI_DEVICES': 'nearby',
  'android.permission.READ_PHONE_STATE': 'phone_state',
  'android.permission.READ_PHONE_NUMBERS': 'phone_state',
  'android.permission.SYSTEM_ALERT_WINDOW': 'overlay',
  'android.permission.READ_CALENDAR': 'calendar',
  'android.permission.WRITE_CALENDAR': 'calendar',
  'android.permission.INTERNET': 'internet',
};

PermCategory? categoryById(String id) {
  for (final c in catalog) {
    if (c.id == id) return c;
  }
  return null;
}

// ── App report ──────────────────────────────────────────────────────────────
class AppReport {
  final String packageName;
  final String appName;
  final bool isBrowser;
  final List<PermCategory> categories;
  final bool overallHigh; // HIGH vs LOW
  final Fit kidsFit, teensFit, adultsFit;

  const AppReport({
    required this.packageName,
    required this.appName,
    required this.isBrowser,
    required this.categories,
    required this.overallHigh,
    required this.kidsFit,
    required this.teensFit,
    required this.adultsFit,
  });

  L get overallLabel => overallHigh ? S.riskHigh : S.riskLow;

  Map<String, dynamic> toJson() => {
        'pkg': packageName,
        'name': appName,
        'browser': isBrowser,
        'cats': categories.map((c) => c.id).toList(),
        'high': overallHigh,
        'kids': kidsFit.index,
        'teens': teensFit.index,
        'adults': adultsFit.index,
      };

  static AppReport fromJson(Map<String, dynamic> j) => AppReport(
        packageName: j['pkg'] as String,
        appName: j['name'] as String,
        isBrowser: (j['browser'] as bool?) ?? false,
        categories: ((j['cats'] as List?) ?? [])
            .map((id) => categoryById(id as String))
            .whereType<PermCategory>()
            .toList(),
        overallHigh: (j['high'] as bool?) ?? false,
        kidsFit: Fit.values[(j['kids'] as int?) ?? 0],
        teensFit: Fit.values[(j['teens'] as int?) ?? 0],
        adultsFit: Fit.values[(j['adults'] as int?) ?? 0],
      );
}

const Set<String> browserPackages = {
  'com.android.chrome',
  'org.mozilla.firefox',
  'com.brave.browser',
  'com.opera.browser',
  'com.opera.mini.native',
  'com.microsoft.emmx',
  'com.sec.android.app.sbrowser',
  'com.duckduckgo.mobile.android',
  'com.UCMobile.intl',
};

AppReport buildReport(String pkg, String appName, List<String> permissions) {
  final ids = <String>{};
  for (final p in permissions) {
    final id = _permToCategory[p];
    if (id != null) ids.add(id);
  }
  // Stable order: catalog order (high-risk categories appear first in catalog).
  final cats = catalog.where((c) => ids.contains(c.id)).toList()
    ..sort((a, b) => b.risk.index.compareTo(a.risk.index));

  final highCount = cats.where((c) => c.risk == Risk.high).length;
  final medCount = cats.where((c) => c.risk == Risk.medium).length;
  final overallHigh = highCount >= 2 || (highCount >= 1 && medCount >= 2);

  // Kids: any high-risk permission makes it unsafe.
  final Fit kids = highCount > 0
      ? Fit.no
      : (medCount > 0 ? Fit.caution : Fit.ok);
  // Teens: SMS / call log / background tracking are red lines.
  final redLine = ids.contains('sms') ||
      ids.contains('calls') ||
      ids.contains('bg_location');
  final Fit teens =
      redLine ? Fit.no : (overallHigh || highCount > 0 ? Fit.caution : Fit.ok);
  // Adults: informed use; caution only when overall risk is HIGH.
  final Fit adultsF = overallHigh ? Fit.caution : Fit.ok;

  return AppReport(
    packageName: pkg,
    appName: appName,
    isBrowser: browserPackages.contains(pkg),
    categories: cats,
    overallHigh: overallHigh,
    kidsFit: kids,
    teensFit: teens,
    adultsFit: adultsF,
  );
}
