// ── Bridge to the Kotlin side (MainActivity / MonitorService) ──────────────

import 'package:flutter/services.dart';

class InstalledApp {
  final String packageName;
  final String label;
  final List<String> permissions;

  const InstalledApp(this.packageName, this.label, this.permissions);
}

class Native {
  static const _ch = MethodChannel('consentlens/native');

  static Future<bool> hasUsageAccess() async =>
      (await _ch.invokeMethod<bool>('hasUsageAccess')) ?? false;

  static Future<void> openUsageAccessSettings() =>
      _ch.invokeMethod('openUsageAccessSettings');

  static Future<bool> hasOverlayPermission() async =>
      (await _ch.invokeMethod<bool>('hasOverlayPermission')) ?? false;

  static Future<void> openOverlaySettings() =>
      _ch.invokeMethod('openOverlaySettings');

  static Future<void> requestNotificationPermission() =>
      _ch.invokeMethod('requestNotificationPermission');

  static Future<void> startMonitor() => _ch.invokeMethod('startMonitor');

  static Future<void> stopMonitor() => _ch.invokeMethod('stopMonitor');

  static Future<bool> isMonitorRunning() async =>
      (await _ch.invokeMethod<bool>('isMonitorRunning')) ?? false;

  static Future<bool> hasAccessibility() async =>
      (await _ch.invokeMethod<bool>('hasAccessibility')) ?? false;

  static Future<void> openAccessibilitySettings() =>
      _ch.invokeMethod('openAccessibilitySettings');

  static Future<void> verifyNow() => _ch.invokeMethod('verifyNow');

  static Future<void> openAppDetails(String pkg) =>
      _ch.invokeMethod('openAppDetails', {'pkg': pkg});

  static Future<List<InstalledApp>> listApps() async {
    final raw = await _ch.invokeMethod<List<dynamic>>('listApps') ?? [];
    return raw.map((e) {
      final m = (e as Map).cast<String, dynamic>();
      return InstalledApp(
        m['pkg'] as String,
        m['label'] as String,
        ((m['perms'] as List?) ?? []).cast<String>(),
      );
    }).toList();
  }
}
