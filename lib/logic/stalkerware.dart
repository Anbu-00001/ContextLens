// ── ConsentLens stalkerware / spyware fingerprint ──────────────────────────
// Reuses the permission data the app already reads. Detection is heuristic and
// circumstantial (per the Coalition Against Stalkerware) — we FLAG and INFORM,
// we never accuse or auto-act, and we never tell the user to just uninstall
// (removal can alert an abuser and escalate danger).

import 'i18n.dart';
import 'native.dart';
import 'risk_engine.dart';

enum SpyLevel { none, elevated, suspected }

// Permission categories that enable covert surveillance of a person.
const Set<String> _surveillanceCats = {
  'location',
  'bg_location',
  'sms',
  'calls',
  'camera',
  'microphone',
  'contacts',
};

bool _requestsOverlay(List<String> perms) =>
    perms.contains('android.permission.SYSTEM_ALERT_WINDOW');

class SpyVerdict {
  final SpyLevel level;
  final List<PermCategory> surveillanceCategories;
  final List<L> signals; // human-readable reasons
  final bool hidden;
  final bool deviceAdmin;
  final bool accessibility;
  final bool overlay;

  const SpyVerdict({
    required this.level,
    required this.surveillanceCategories,
    required this.signals,
    required this.hidden,
    required this.deviceAdmin,
    required this.accessibility,
    required this.overlay,
  });

  bool get suspected => level == SpyLevel.suspected;
}

SpyVerdict assessStalkerware(ScannedApp app) {
  // Reuse the catalog mapping to get this app's permission categories.
  final report = buildReport(app.packageName, app.label, app.permissions);
  final surveillance = report.categories
      .where((c) => _surveillanceCats.contains(c.id))
      .toList();
  final count = surveillance.length;

  final hidden = !app.hasLauncher && !app.isSystem;
  final overlay = _requestsOverlay(app.permissions);
  final deviceAdmin = app.isDeviceAdmin;
  final accessibility = app.hasAccessibility;
  final powerSignal = hidden || deviceAdmin || accessibility;

  final signals = <L>[];
  if (count > 0) {
    signals.add(L(
      'Can access $count private thing(s): ${surveillance.map((c) => c.title.en).join(", ")}',
      '$count निजी चीज़ों तक पहुँच: ${surveillance.map((c) => c.title.hi).join(", ")}',
      '$count ಖಾಸಗಿ ವಿಷಯಗಳ ಪ್ರವೇಶ: ${surveillance.map((c) => c.title.kn).join(", ")}',
    ));
  }
  if (hidden) {
    signals.add(const L(
      'Hidden — it has no icon in your apps list.',
      'छिपा हुआ — आपकी ऐप सूची में इसका कोई आइकन नहीं है।',
      'ಮರೆಮಾಚಲಾಗಿದೆ — ನಿಮ್ಮ ಆ್ಯಪ್ ಪಟ್ಟಿಯಲ್ಲಿ ಐಕಾನ್ ಇಲ್ಲ.',
    ));
  }
  if (deviceAdmin) {
    signals.add(const L(
      'Has device-admin control over your phone.',
      'आपके फ़ोन पर डिवाइस-एडमिन नियंत्रण रखता है।',
      'ನಿಮ್ಮ ಫೋನ್ ಮೇಲೆ ಸಾಧನ-ನಿರ್ವಾಹಕ ನಿಯಂತ್ರಣ ಹೊಂದಿದೆ.',
    ));
  }
  if (accessibility) {
    signals.add(const L(
      'Can read your screen via Accessibility.',
      'एक्सेसिबिलिटी से आपकी स्क्रीन पढ़ सकता है।',
      'ಪ್ರವೇಶಿಸುವಿಕೆ ಮೂಲಕ ನಿಮ್ಮ ಪರದೆ ಓದಬಹುದು.',
    ));
  }
  if (overlay) {
    signals.add(const L(
      'Can draw screens on top of other apps.',
      'दूसरे ऐप्स के ऊपर स्क्रीन बना सकता है।',
      'ಇತರ ಆ್ಯಪ್‌ಗಳ ಮೇಲೆ ಪರದೆ ಬರೆಯಬಹುದು.',
    ));
  }

  SpyLevel level;
  if ((count >= 3 && powerSignal) ||
      (count >= 2 && hidden && (overlay || accessibility || deviceAdmin))) {
    level = SpyLevel.suspected;
  } else if ((count >= 4 && (overlay || accessibility || deviceAdmin)) ||
      count >= 5) {
    // "Watches a lot": broad surveillance reach, but no covert fingerprint.
    level = SpyLevel.elevated;
  } else {
    level = SpyLevel.none;
  }

  return SpyVerdict(
    level: level,
    surveillanceCategories: surveillance,
    signals: signals,
    hidden: hidden,
    deviceAdmin: deviceAdmin,
    accessibility: accessibility,
    overlay: overlay,
  );
}

class SpyScanResult {
  final List<ScannedApp> suspected;
  final List<ScannedApp> elevated;
  final Map<String, SpyVerdict> verdicts;

  const SpyScanResult(this.suspected, this.elevated, this.verdicts);

  int get total => suspected.length + elevated.length;
}

Future<SpyScanResult> runStalkerwareScan() async {
  final apps = await Native.scanInstalledApps();
  final suspected = <ScannedApp>[];
  final elevated = <ScannedApp>[];
  final verdicts = <String, SpyVerdict>{};
  for (final app in apps) {
    final v = assessStalkerware(app);
    verdicts[app.packageName] = v;
    if (v.level == SpyLevel.suspected) {
      suspected.add(app);
    } else if (v.level == SpyLevel.elevated) {
      elevated.add(app);
    }
  }
  int weight(ScannedApp a) => verdicts[a.packageName]!.signals.length;
  suspected.sort((a, b) => weight(b).compareTo(weight(a)));
  elevated.sort((a, b) => weight(b).compareTo(weight(a)));
  return SpyScanResult(suspected, elevated, verdicts);
}
