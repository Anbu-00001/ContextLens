package com.consentlens.consentlens

import android.os.Bundle
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_WEAK
import androidx.biometric.BiometricManager.Authenticators.DEVICE_CREDENTIAL
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity

/**
 * Transparent activity that decides Adult vs Child mode.
 * Fingerprint / face / passcode success -> adult. Failure or dismissal -> child.
 * Launched on every unlock, every hour of use, and from "Verify now".
 */
class VerifyActivity : FragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val executor = ContextCompat.getMainExecutor(this)
        val prompt = BiometricPrompt(this, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    setMode("adult")
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    // Cancelled / too many attempts / no credentials -> treat as child
                    setMode("child")
                }
            })

        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Who is using this phone?")
            .setSubtitle("ConsentLens: verify to use Adult mode. Cancel for Child mode.")
            .setAllowedAuthenticators(BIOMETRIC_WEAK or DEVICE_CREDENTIAL)
            .setConfirmationRequired(false)
            .build()

        try {
            prompt.authenticate(info)
        } catch (_: Exception) {
            setMode("child")
        }
    }

    private fun setMode(mode: String) {
        Prefs.setUserMode(this, mode)
        Prefs.setLastVerifiedAt(this, System.currentTimeMillis())
        finish()
    }
}
