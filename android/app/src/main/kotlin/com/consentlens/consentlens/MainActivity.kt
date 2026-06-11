package com.consentlens.consentlens

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "consentlens/native")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsageAccess" -> result.success(hasUsageAccess())
                    "openUsageAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "hasOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                    "openOverlaySettings" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                        )
                        result.success(null)
                    }
                    "requestNotificationPermission" -> {
                        if (Build.VERSION.SDK_INT >= 33 &&
                            checkSelfPermission("android.permission.POST_NOTIFICATIONS") !=
                            PackageManager.PERMISSION_GRANTED
                        ) {
                            ActivityCompat.requestPermissions(
                                this, arrayOf("android.permission.POST_NOTIFICATIONS"), 7
                            )
                        }
                        result.success(null)
                    }
                    "startMonitor" -> {
                        val intent = Intent(this, MonitorService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    }
                    "stopMonitor" -> {
                        stopService(Intent(this, MonitorService::class.java))
                        result.success(null)
                    }
                    "isMonitorRunning" -> result.success(MonitorService.running)
                    "hasAccessibility" -> result.success(isAccessibilityEnabled())
                    "openAccessibilitySettings" -> {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    }
                    "verifyNow" -> {
                        startActivity(Intent(this, VerifyActivity::class.java))
                        result.success(null)
                    }
                    "openAppDetails" -> {
                        val pkg = call.argument<String>("pkg") ?: packageName
                        startActivity(
                            Intent(
                                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.parse("package:$pkg")
                            )
                        )
                        result.success(null)
                    }
                    "listApps" -> result.success(listApps())
                    else -> result.notImplemented()
                }
            }
    }

    private fun isAccessibilityEnabled(): Boolean {
        if (WebGuardAccessibilityService.connected) return true
        val flat = Settings.Secure.getString(
            contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        return flat.contains("$packageName/.WebGuardAccessibilityService") ||
                flat.contains("$packageName/$packageName.WebGuardAccessibilityService")
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun listApps(): List<Map<String, Any>> {
        val pm = packageManager
        val launchIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val resolved = pm.queryIntentActivities(launchIntent, 0)
        val seen = HashSet<String>()
        val out = ArrayList<Map<String, Any>>()
        for (ri in resolved) {
            val pkg = ri.activityInfo?.packageName ?: continue
            if (pkg == packageName || !seen.add(pkg)) continue
            try {
                val info = pm.getPackageInfo(pkg, PackageManager.GET_PERMISSIONS)
                val label = info.applicationInfo?.loadLabel(pm)?.toString() ?: pkg
                out.add(
                    mapOf(
                        "pkg" to pkg,
                        "label" to label,
                        "perms" to (info.requestedPermissions?.toList() ?: emptyList<String>())
                    )
                )
            } catch (_: Exception) {
            }
        }
        return out
    }
}
