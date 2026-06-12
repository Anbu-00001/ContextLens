// ── Local storage (shared with the Kotlin side via FlutterSharedPreferences)
// Keys written from Kotlin use the same names with the "flutter." prefix.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Keys {
  static const language = 'language'; // 'en' | 'hi' | 'kn'
  static const voiceOn = 'voice_on';
  static const userMode = 'user_mode'; // 'adult' | 'child' (set by VerifyActivity)
  static const lastVerifiedAt = 'last_verified_at'; // millis, set by Kotlin
  static const history = 'history_json'; // JSON list of history entries
  static const lastSpyCount = 'last_spy_count'; // suspected count from last scan
  static const lastScanAt = 'last_scan_at'; // millis of last spyware scan
  static const badges = 'earned_badges'; // CSV of badge ids
  static const trusted = 'trusted_contacts'; // JSON list {name, number}
  static const kidsPin = 'kids_pin'; // 4-digit exit PIN for Kids Mode
  static const kidsModeOn = 'kids_mode_on'; // read by MonitorService (Kotlin)
  static const kidsAllowedApps = 'kids_allowed_apps'; // CSV of package names
}

class HistoryEntry {
  final String pkg, appName;
  final bool high;
  final int catCount;
  final int timestamp;

  const HistoryEntry({
    required this.pkg,
    required this.appName,
    required this.high,
    required this.catCount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'pkg': pkg,
        'name': appName,
        'high': high,
        'n': catCount,
        't': timestamp,
      };

  static HistoryEntry fromJson(Map<String, dynamic> j) => HistoryEntry(
        pkg: j['pkg'] as String,
        appName: j['name'] as String,
        high: (j['high'] as bool?) ?? false,
        catCount: (j['n'] as int?) ?? 0,
        timestamp: (j['t'] as int?) ?? 0,
      );

  String timeAgo() {
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

class Store {
  static Future<SharedPreferences> _prefs() async {
    final p = await SharedPreferences.getInstance();
    await p.reload(); // pick up writes from the Kotlin side
    return p;
  }

  static Future<String> language() async =>
      (await _prefs()).getString(Keys.language) ?? 'en';

  static Future<void> setLanguage(String lang) async =>
      (await _prefs()).setString(Keys.language, lang);

  static Future<bool> voiceOn() async =>
      (await _prefs()).getBool(Keys.voiceOn) ?? true;

  static Future<void> setVoiceOn(bool v) async =>
      (await _prefs()).setBool(Keys.voiceOn, v);

  static Future<String> userMode() async =>
      (await _prefs()).getString(Keys.userMode) ?? 'adult';

  static Future<void> setUserMode(String mode) async =>
      (await _prefs()).setString(Keys.userMode, mode);

  static Future<int> lastVerifiedAt() async {
    final p = await _prefs();
    final v = p.get(Keys.lastVerifiedAt);
    if (v is int) return v;
    return 0;
  }

  static Future<List<HistoryEntry>> history() async {
    final raw = (await _prefs()).getString(Keys.history);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => HistoryEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addHistory(HistoryEntry entry) async {
    final p = await _prefs();
    final items = await history();
    items.insert(0, entry);
    while (items.length > 100) {
      items.removeLast();
    }
    await p.setString(
        Keys.history, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearHistory() async =>
      (await _prefs()).remove(Keys.history);

  static Future<void> saveScanResult(int suspectedCount) async {
    final p = await _prefs();
    await p.setInt(Keys.lastSpyCount, suspectedCount);
    await p.setInt(Keys.lastScanAt, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<int?> lastSpyCount() async {
    final p = await _prefs();
    if (!p.containsKey(Keys.lastScanAt)) return null;
    return p.getInt(Keys.lastSpyCount) ?? 0;
  }

  // ── Badges ──
  static Future<Set<String>> earnedBadges() async {
    final raw = (await _prefs()).getString(Keys.badges) ?? '';
    return raw.split(',').where((s) => s.isNotEmpty).toSet();
  }

  static Future<bool> awardBadge(String id) async {
    final p = await _prefs();
    final set = await earnedBadges();
    if (set.contains(id)) return false; // already had it
    set.add(id);
    await p.setString(Keys.badges, set.join(','));
    return true; // newly earned
  }

  // ── Trusted contacts ──
  static Future<List<Map<String, String>>> trustedContacts() async {
    final raw = (await _prefs()).getString(Keys.trusted);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => (e as Map).map((k, v) => MapEntry('$k', '$v')))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTrusted(List<Map<String, String>> list) async =>
      (await _prefs()).setString(Keys.trusted, jsonEncode(list));

  // ── Kids Mode PIN ──
  static Future<String?> kidsPin() async =>
      (await _prefs()).getString(Keys.kidsPin);

  static Future<void> setKidsPin(String pin) async =>
      (await _prefs()).setString(Keys.kidsPin, pin);

  // ── Kids Mode app allowlist (shared with MonitorService) ──
  static Future<List<String>> kidsAllowedApps() async {
    final raw = (await _prefs()).getString(Keys.kidsAllowedApps) ?? '';
    return raw.split(',').where((s) => s.isNotEmpty).toList();
  }

  static Future<void> setKidsAllowedApps(List<String> pkgs) async =>
      (await _prefs()).setString(Keys.kidsAllowedApps, pkgs.join(','));

  static Future<void> setKidsModeOn(bool on) async =>
      (await _prefs()).setBool(Keys.kidsModeOn, on);

  static Future<bool> kidsModeOn() async =>
      (await _prefs()).getBool(Keys.kidsModeOn) ?? false;
}
