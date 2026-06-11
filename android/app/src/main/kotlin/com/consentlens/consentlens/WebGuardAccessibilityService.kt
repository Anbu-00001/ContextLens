package com.consentlens.consentlens

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale

/**
 * Primary website-permission watcher.
 *
 * Reads the on-screen content of Chromium browsers. When a site permission
 * prompt appears ("example.com wants to use your camera"), it extracts the
 * site + permission and fires the ConsentLens popup over it — before the user
 * taps Allow. It also reads the URL bar to flag known-dangerous domains.
 *
 * All matching is on-device text inspection; nothing leaves the phone.
 */
class WebGuardAccessibilityService : AccessibilityService() {

    companion object {
        @Volatile
        var connected = false

        private val BROWSERS = setOf(
            "com.android.chrome",
            "com.chrome.beta",
            "com.brave.browser",
            "com.microsoft.emmx",
            "org.chromium.chrome",
            "com.sec.android.app.sbrowser",
            "com.opera.browser",
            "com.duckduckgo.mobile.android"
        )

        // permission keyword -> web permission id used by the risk engine
        private val PERM_KEYWORDS = linkedMapOf(
            "location" to "location",
            "camera" to "camera",
            "microphone" to "microphone",
            "record audio" to "microphone",
            "notification" to "notifications",
            "files" to "storage",
            "storage" to "storage",
            "bluetooth" to "bluetooth",
            "usb" to "usb",
            "midi" to "midi",
            "clipboard" to "clipboard"
        )

        // Words that mark a node as the permission prompt (not page content).
        private val PROMPT_MARKERS = listOf("wants to", "allow", "use your", "block")
        private const val COOLDOWN_MS = 12_000L
    }

    private var lastShownKey = ""
    private var lastShownAt = 0L
    private var lastUrlChecked = ""

    override fun onServiceConnected() {
        super.onServiceConnected()
        connected = true
    }

    override fun onDestroy() {
        connected = false
        super.onDestroy()
    }

    override fun onInterrupt() {}

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        val pkg = event.packageName?.toString() ?: return
        if (pkg !in BROWSERS) return

        val root = rootInActiveWindow ?: return
        try {
            // 1) Check the address bar for dangerous domains.
            val url = readUrlBar(root, pkg)
            if (url != null && url != lastUrlChecked) {
                lastUrlChecked = url
                maybeWarnDangerousUrl(url)
            }

            // 2) Look for a permission prompt on screen.
            handlePermissionPrompt(root, url)
        } finally {
            root.recycle()
        }
    }

    private fun handlePermissionPrompt(root: AccessibilityNodeInfo, url: String?) {
        val texts = ArrayList<String>()
        collectText(root, texts, 0)
        if (texts.isEmpty()) return

        val joined = texts.joinToString(" | ").lowercase(Locale.ROOT)
        val isPrompt = PROMPT_MARKERS.count { joined.contains(it) } >= 2
        if (!isPrompt) return

        val perms = JSONArray()
        val foundIds = HashSet<String>()
        for ((kw, id) in PERM_KEYWORDS) {
            if (joined.contains(kw) && foundIds.add(id)) perms.put(id)
        }
        if (perms.length() == 0) return

        val site = extractSite(texts, url) ?: return
        val key = "$site:${foundIds.sorted().joinToString(",")}"
        val now = System.currentTimeMillis()
        if (key == lastShownKey && now - lastShownAt < COOLDOWN_MS) return
        lastShownKey = key
        lastShownAt = now

        val payload = JSONObject()
            .put("kind", "web")
            .put("site", site)
            .put("perms", perms)
            .toString()
        OverlayController.show(this, payload)
    }

    private fun maybeWarnDangerousUrl(url: String) {
        val host = host(url)
        if (host.isEmpty()) return
        if (!DomainThreat.isShady(host)) return
        val now = System.currentTimeMillis()
        val key = "threat:$host"
        if (key == lastShownKey && now - lastShownAt < COOLDOWN_MS) return
        lastShownKey = key
        lastShownAt = now

        // No specific permission yet — surface the threat itself. The Dart side
        // re-runs its own (richer) heuristics and renders the red banner.
        val payload = JSONObject()
            .put("kind", "web")
            .put("site", host)
            .put("perms", JSONArray())
            .toString()
        OverlayController.show(this, payload)
    }

    // ── Node helpers ─────────────────────────────────────────────────────────
    private fun readUrlBar(root: AccessibilityNodeInfo, pkg: String): String? {
        for (id in listOf("$pkg:id/url_bar", "$pkg:id/location_bar_status", "$pkg:id/url_field")) {
            val nodes = root.findAccessibilityNodeInfosByViewId(id) ?: continue
            for (n in nodes) {
                val t = n.text?.toString()
                n.recycle()
                if (!t.isNullOrBlank()) return t
            }
        }
        return null
    }

    private fun collectText(node: AccessibilityNodeInfo?, out: ArrayList<String>, depth: Int) {
        node ?: return
        if (depth > 25 || out.size > 120) return
        node.text?.toString()?.takeIf { it.isNotBlank() }?.let { out.add(it) }
        node.contentDescription?.toString()?.takeIf { it.isNotBlank() }?.let { out.add(it) }
        for (i in 0 until node.childCount) {
            collectText(node.getChild(i), out, depth + 1)
        }
    }

    /** Pull a host-looking token out of the prompt text, else fall back to URL. */
    private fun extractSite(texts: List<String>, url: String?): String? {
        val domainRe = Regex("([a-z0-9-]+\\.)+[a-z]{2,}", RegexOption.IGNORE_CASE)
        for (t in texts) {
            val m = domainRe.find(t)
            if (m != null) return m.value.lowercase(Locale.ROOT)
        }
        url?.let { return host(it) }
        return null
    }

    private fun host(input: String): String {
        var s = input.trim().lowercase(Locale.ROOT)
        s = s.replace(Regex("^[a-z]+://"), "")
        s = s.substringBefore('/').substringBefore('?').substringBefore(' ')
        if (s.contains('@')) s = s.substringAfterLast('@')
        return s.substringBefore(':')
    }
}
