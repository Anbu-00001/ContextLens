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
                    "startScreenPinning" -> {
                        try {
                            startLockTask() // screen pinning (best-effort, no device owner)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "stopScreenPinning" -> {
                        try {
                            stopLockTask()
                        } catch (_: Exception) {
                        }
                        result.success(null)
                    }
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
                    "scanInstalledApps" -> result.success(scanInstalledApps())
                    "launchApp" -> {
                        val pkg = call.argument<String>("pkg")
                        val intent =
                            if (pkg != null) packageManager.getLaunchIntentForPackage(pkg)
                            else null
                        if (intent != null) {
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    "getAppIcons" -> {
                        val pkgs = call.argument<List<String>>("pkgs") ?: emptyList()
                        result.success(getAppIcons(pkgs))
                    }
                    "kidsGuardOff" -> {
                        KidsBlockOverlay.hide(this)
                        result.success(null)
                    }
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

    /**
     * Full scan for the stalkerware/safety module: every package (user + system)
     * with its requested permissions and the high-signal flags — whether it has
     * a launcher icon (hidden apps are a red flag), is a system app, is an
     * active device admin, or provides an accessibility service.
     */
    private fun scanInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager

        val launcherPkgs = pm.queryIntentActivities(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER), 0
        ).mapNotNull { it.activityInfo?.packageName }.toHashSet()

        val adminPkgs = HashSet<String>()
        try {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE)
                    as android.app.admin.DevicePolicyManager
            dpm.activeAdmins?.forEach { adminPkgs.add(it.packageName) }
        } catch (_: Exception) {
        }

        val a11yPkgs = HashSet<String>()
        try {
            val am = getSystemService(Context.ACCESSIBILITY_SERVICE)
                    as android.view.accessibility.AccessibilityManager
            am.installedAccessibilityServiceList?.forEach {
                it.resolveInfo?.serviceInfo?.packageName?.let { p -> a11yPkgs.add(p) }
            }
        } catch (_: Exception) {
        }

        val out = ArrayList<Map<String, Any>>()
        val packages = pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
        for (info in packages) {
            val pkg = info.packageName ?: continue
            if (pkg == packageName) continue
            val appInfo = info.applicationInfo ?: continue
            val isSystem =
                (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
            val label = appInfo.loadLabel(pm)?.toString() ?: pkg
            out.add(
                mapOf(
                    "pkg" to pkg,
                    "label" to label,
                    "perms" to (info.requestedPermissions?.toList() ?: emptyList<String>()),
                    "hasLauncher" to launcherPkgs.contains(pkg),
                    "system" to isSystem,
                    "deviceAdmin" to adminPkgs.contains(pkg),
                    "accessibility" to a11yPkgs.contains(pkg)
                )
            )
        }
        return out
    }

    /** Small PNG icons for the Kids Mode app grid (pkg → bytes). */
    private fun getAppIcons(pkgs: List<String>): Map<String, ByteArray> {
        val pm = packageManager
        val out = HashMap<String, ByteArray>()
        for (pkg in pkgs) {
            try {
                val drawable = pm.getApplicationIcon(pkg)
                val size = 128
                val bmp = android.graphics.Bitmap.createBitmap(
                    size, size, android.graphics.Bitmap.Config.ARGB_8888
                )
                val canvas = android.graphics.Canvas(bmp)
                drawable.setBounds(0, 0, size, size)
                drawable.draw(canvas)
                val baos = java.io.ByteArrayOutputStream()
                bmp.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, baos)
                bmp.recycle()
                out[pkg] = baos.toByteArray()
            } catch (_: Exception) {
            }
        }
        return out
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
