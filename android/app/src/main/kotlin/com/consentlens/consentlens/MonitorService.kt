package com.consentlens.consentlens

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject

/**
 * Foreground service that watches which app is in the foreground (UsageStats),
 * fires the ConsentLens popup when a new app opens, and triggers the
 * adult/child identity check on every unlock and every hour of use.
 */
class MonitorService : Service() {

    companion object {
        @Volatile
        var running = false
        private const val CHANNEL_ID = "consentlens_monitor"
        private const val NOTIF_ID = 11
        private const val POLL_MS = 1200L
        private const val SHOW_COOLDOWN_MS = 30_000L
        private const val VERIFY_INTERVAL_MS = 60 * 60 * 1000L // 1 hour
        private const val VERIFY_PROMPT_GAP_MS = 2 * 60 * 1000L
    }

    private val handler = Handler(Looper.getMainLooper())
    private var lastEventTs = 0L
    private var lastPackage = ""
    private val lastShownAt = HashMap<String, Long>()
    private var lastVerifyPromptAt = 0L
    private var launcherPackages: Set<String> = emptySet()

    private val unlockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_USER_PRESENT) {
                triggerVerify()
            }
        }
    }

    private val pollTask = object : Runnable {
        override fun run() {
            try {
                pollForeground()
                checkHourlyVerify()
            } catch (_: Exception) {
            }
            handler.postDelayed(this, POLL_MS)
        }
    }

    override fun onCreate() {
        super.onCreate()
        running = true
        startInForeground()
        launcherPackages = resolveLaunchers()
        lastEventTs = System.currentTimeMillis()
        ContextCompat.registerReceiver(
            this, unlockReceiver, IntentFilter(Intent.ACTION_USER_PRESENT),
            ContextCompat.RECEIVER_NOT_EXPORTED
        )
        handler.post(pollTask)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onDestroy() {
        running = false
        handler.removeCallbacks(pollTask)
        try {
            unregisterReceiver(unlockReceiver)
        } catch (_: Exception) {
        }
        OverlayController.hide(this)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ── Foreground notification ──────────────────────────────────────────────
    private fun startInForeground() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID, "ConsentLens protection",
                    NotificationManager.IMPORTANCE_MIN
                )
            )
        }
        val notif: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle("ConsentLens is protecting you")
            .setContentText("Explaining permissions of apps you open — all on-device")
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIF_ID, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIF_ID, notif)
        }
    }

    // ── Foreground app detection ────────────────────────────────────────────
    private fun pollForeground() {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(lastEventTs, now)
        var newest: String? = null
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
            ) {
                newest = event.packageName
            }
        }
        lastEventTs = now
        val pkg = newest ?: return
        if (pkg == lastPackage) return
        lastPackage = pkg

        if (pkg == packageName || pkg in launcherPackages || pkg == "com.android.systemui") {
            OverlayController.hide(this)
            return
        }
        val shownAt = lastShownAt[pkg] ?: 0L
        if (now - shownAt < SHOW_COOLDOWN_MS) return

        val payload = buildPayload(pkg) ?: return
        lastShownAt[pkg] = now
        OverlayController.show(this, payload)
    }

    private fun buildPayload(pkg: String): String? {
        return try {
            val pm = packageManager
            val info = pm.getPackageInfo(pkg, PackageManager.GET_PERMISSIONS)
            val appInfo = info.applicationInfo
            val label = appInfo?.loadLabel(pm)?.toString() ?: pkg
            val perms = JSONArray()
            info.requestedPermissions?.forEach { perms.put(it) }
            val isSystem = appInfo != null &&
                (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
            val launchIntent = Intent(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_LAUNCHER).setPackage(pkg)
            val hasLauncher =
                pm.queryIntentActivities(launchIntent, 0).isNotEmpty()
            JSONObject()
                .put("pkg", pkg)
                .put("name", label)
                .put("perms", perms)
                .put("hasLauncher", hasLauncher)
                .put("system", isSystem)
                .put("deviceAdmin", deviceAdminPkgs().contains(pkg))
                .put("accessibility", accessibilityPkgs().contains(pkg))
                .toString()
        } catch (_: Exception) {
            null
        }
    }

    private var _adminPkgs: Set<String>? = null
    private fun deviceAdminPkgs(): Set<String> {
        _adminPkgs?.let { return it }
        val set = HashSet<String>()
        try {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE)
                    as android.app.admin.DevicePolicyManager
            dpm.activeAdmins?.forEach { set.add(it.packageName) }
        } catch (_: Exception) {
        }
        _adminPkgs = set
        return set
    }

    private var _a11yPkgs: Set<String>? = null
    private fun accessibilityPkgs(): Set<String> {
        _a11yPkgs?.let { return it }
        val set = HashSet<String>()
        try {
            val am = getSystemService(Context.ACCESSIBILITY_SERVICE)
                    as android.view.accessibility.AccessibilityManager
            am.installedAccessibilityServiceList?.forEach {
                it.resolveInfo?.serviceInfo?.packageName?.let { p -> set.add(p) }
            }
        } catch (_: Exception) {
        }
        _a11yPkgs = set
        return set
    }

    private fun resolveLaunchers(): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        return packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
            .mapNotNull { it.activityInfo?.packageName }
            .toSet()
    }

    // ── Adult/child verification triggers ───────────────────────────────────
    private fun checkHourlyVerify() {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (!pm.isInteractive) return
        val last = Prefs.lastVerifiedAt(this)
        if (System.currentTimeMillis() - last > VERIFY_INTERVAL_MS) {
            triggerVerify()
        }
    }

    private fun triggerVerify() {
        val now = System.currentTimeMillis()
        if (now - lastVerifyPromptAt < VERIFY_PROMPT_GAP_MS) return
        lastVerifyPromptAt = now
        try {
            startActivity(
                Intent(this, VerifyActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            )
        } catch (_: Exception) {
        }
    }
}
