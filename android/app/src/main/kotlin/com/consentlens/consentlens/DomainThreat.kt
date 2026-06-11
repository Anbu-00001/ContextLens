package com.consentlens.consentlens

import java.util.Locale

/**
 * Lightweight native pre-screen so the accessibility watcher can fire the
 * popup on a dangerous URL even before any permission is requested. The Dart
 * side (lib/logic/threat.dart) holds the authoritative, richer heuristics and
 * renders the warning; this just decides "worth surfacing".
 */
object DomainThreat {
    private val BLOCKLIST = setOf(
        "free-gift-card.live",
        "login-verify-account.com",
        "secure-bank-update.info",
        "claim-your-prize.xyz",
        "update-kyc-now.top"
    )
    private val RISKY_TLDS = setOf(
        "zip", "mov", "top", "xyz", "gq", "tk", "ml", "cf", "ga",
        "work", "click", "country", "review", "cam", "rest", "live", "science"
    )
    private val LURES = listOf(
        "login", "signin", "verify", "secure", "account", "update", "confirm",
        "kyc", "otp", "wallet", "free", "prize", "gift", "reward", "claim"
    )

    fun isShady(hostIn: String): Boolean {
        val host = hostIn.lowercase(Locale.ROOT)
        if (host.isEmpty()) return false
        if (BLOCKLIST.any { host == it || host.endsWith(".$it") }) return true
        if (Regex("^\\d{1,3}(\\.\\d{1,3}){3}$").matches(host)) return true
        if (host.contains("xn--")) return true

        val tld = host.substringAfterLast('.', "")
        val hasLure = LURES.any { host.contains(it) }
        if (RISKY_TLDS.contains(tld) && hasLure) return true
        if (host.count { it == '-' } >= 3 || host.length > 40) return true
        return false
    }
}
