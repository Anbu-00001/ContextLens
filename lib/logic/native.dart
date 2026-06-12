// ── Bridge to the Kotlin side (MainActivity / MonitorService) ──────────────

import 'dart:typed_data';

import 'package:flutter/services.dart';

class InstalledApp {
  final String packageName;
  final String label;
  final List<String> permissions;

  const InstalledApp(this.packageName, this.label, this.permissions);
}

class ScannedApp {
  final String packageName;
  final String label;
  final List<String> permissions;
  final bool hasLauncher;
  final bool isSystem;
  final bool isDeviceAdmin;
  final bool hasAccessibility;

  const ScannedApp({
    required this.packageName,
    required this.label,
    required this.permissions,
    required this.hasLauncher,
    required this.isSystem,
    required this.isDeviceAdmin,
    required this.hasAccessibility,
  });
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

  static Future<bool> startScreenPinning() async =>
      (await _ch.invokeMethod<bool>('startScreenPinning')) ?? false;

  static Future<void> stopScreenPinning() =>
      _ch.invokeMethod('stopScreenPinning');

  static Future<void> openAppDetails(String pkg) =>
      _ch.invokeMethod('openAppDetails', {'pkg': pkg});

  static Future<List<ScannedApp>> scanInstalledApps() async {
    final raw =
        await _ch.invokeMethod<List<dynamic>>('scanInstalledApps') ?? [];
    return raw.map((e) {
      final m = (e as Map).cast<String, dynamic>();
      return ScannedApp(
        packageName: m['pkg'] as String,
        label: m['label'] as String,
        permissions: ((m['perms'] as List?) ?? []).cast<String>(),
        hasLauncher: (m['hasLauncher'] as bool?) ?? true,
        isSystem: (m['system'] as bool?) ?? false,
        isDeviceAdmin: (m['deviceAdmin'] as bool?) ?? false,
        hasAccessibility: (m['accessibility'] as bool?) ?? false,
      );
    }).toList();
  }

  /// Launch another app by package name (Kids Mode allowlist grid).
  static Future<bool> launchApp(String pkg) async =>
      (await _ch.invokeMethod<bool>('launchApp', {'pkg': pkg})) ?? false;

  /// PNG icon bytes for the given packages (pkg → bytes).
  static Future<Map<String, Uint8List>> getAppIcons(List<String> pkgs) async {
    final raw = await _ch
        .invokeMethod<Map<dynamic, dynamic>>('getAppIcons', {'pkgs': pkgs});
    if (raw == null) return {};
    return raw.map((k, v) => MapEntry('$k', v as Uint8List));
  }

  /// Tear down the kids block overlay immediately (on exit).
  static Future<void> kidsGuardOff() => _ch.invokeMethod('kidsGuardOff');

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
