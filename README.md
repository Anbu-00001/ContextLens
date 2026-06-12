<div align="center">

<img src="assets/branding/logo.png" alt="ConsentLens" width="180"/>

# ConsentLens

### Safe Digital Onboarding Kit for First-Time Women Internet Users

**SheSafe Hackathon · RVCE Women in Cloud × DSCI · Team MPOWERNET**

[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)](#)
[![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter&logoColor=white)](#)
[![Privacy](https://img.shields.io/badge/processing-100%25_on--device-E91E63)](#)
[![Languages](https://img.shields.io/badge/languages-EN_·_HI_·_KN-9C27B0)](#)

*Spot the scam. Browse safe. Hand the phone over without fear.*

</div>

---

## 🌸 Why ConsentLens

Millions of women come online for the first time every year — through a first smartphone, a first UPI app, a first WhatsApp forward. They are the **prime target** for KYC fraud, "digital arrest" calls, lottery scams, stalkerware, and permission-hungry apps.

ConsentLens is a calm, friendly guardian that **explains risk in plain language and the user's own voice** — and does it **entirely on the phone**. No cloud, no accounts, no tracking. Your messages and screenshots never leave the device.

> **Design promise:** flag and *inform*, never accuse or auto-act. On stalkerware we never say "just uninstall" — removal can alert an abuser. We say *document first, then get help.*

---

## ✨ The Five Pillars

```mermaid
mindmap
  root((ConsentLens))
    Scam Shield
      On-device message and link scanner
      2026 India scam taxonomy
      Voice verdict in EN / HI / KN
    Safe Browser
      Trusted-site allowlist
      Unknown sites flagged as risky
      Per-site permission explainer
    Guardian
      App permission watch
      Stalkerware safety scan
      Quick-hide calculator decoy
    Learn and Practice
      Story lessons
      Real vs Fake library
      Quiz and badges
    Circle and Handoff
      Trusted contacts and SMS alert
      Safe Handoff Kids Mode
      Emergency help hub
```

| Pillar | What it does | Privacy stance |
|---|---|---|
| 🛡️ **Scam Shield** | Paste any SMS/link → instant `SAFE / SUSPICIOUS / DANGEROUS` verdict with a spoken explanation | Rule engine runs locally — works in airplane mode |
| 🌐 **Safe Browser** | Built-in browser where only **commonly-used sites** load freely; unknown ones are flagged as possibly fraudulent | No browsing history leaves the device |
| 🔎 **Guardian** | Watches permissions of every app you open, scans for spyware, hides the app behind a calculator on a long-press | All scans on-device |
| 🎓 **Learn & Practice** | Cartoon-free emoji stories, a Real-vs-Fake gallery, a quiz, and earnable badges | No analytics |
| 🤝 **Circle & Handoff** | Add 1–2 trusted people (no contacts permission), one-tap SMS alert, and a parent-controlled Kids Mode | No SMS permission — uses the user's own SMS app |

---

## 🏗️ Architecture at a glance

ConsentLens is a **Flutter UI** over a **native Kotlin safety layer**, talking through a `MethodChannel`. Everything in the diagram below runs on the phone — there is no server.

```mermaid
flowchart TB
    subgraph Device["📱 The phone — nothing leaves it"]
        subgraph Flutter["Flutter layer · Dart"]
            UI["Screens<br/>Home · Scan · Browser · Learn<br/>Trusted Circle · Kids Mode"]
            ENG["On-device engines<br/>scam_engine · threat · risk_engine"]
            I18N["Trilingual store + TTS<br/>EN / HI / KN"]
            STORE["Local store<br/>SharedPreferences"]
        end

        subgraph Kotlin["Native layer · Kotlin"]
            MON["MonitorService<br/>foreground-app watch"]
            OVL["OverlayController<br/>permission popup"]
            KIDS["KidsBlockOverlay<br/>app allowlist guard"]
            A11Y["WebGuardAccessibility<br/>(fallback)"]
        end

        UI <-->|MethodChannel| Kotlin
        UI --> ENG --> I18N
        UI <--> STORE
        Kotlin <--> STORE
    end

    Device -. "❌ no cloud · no accounts · no tracking" .-> Cloud["☁️"]
    style Cloud fill:#ffe3e3,stroke:#e74c3c,stroke-width:2px,color:#a11111
    style Device fill:#fff0f6,stroke:#E91E63,stroke-width:2px,color:#880E4F
```

---

## 🛡️ How the Scam Scanner thinks

A pasted message (or text read from a screenshot via on-device OCR) flows through a rule engine built from the **2026 India scam taxonomy** — KYC/Aadhaar blocks, "digital arrest", UPI refund-PIN traps, lottery/KBC, fake couriers, job-fee scams — plus urgency cues and suspicious-link heuristics.

```mermaid
flowchart LR
    A["✉️ Message<br/>or 🖼️ screenshot"] --> B{"Text input"}
    B -->|image| OCR["On-device OCR<br/>ML Kit · Latin + Devanagari"]
    OCR --> C
    B -->|text| C["scanText()"]
    C --> D["Match scam rules<br/>KYC · OTP · UPI · lottery…"]
    C --> E["Scan links<br/>lookalikes · IPs · shorteners"]
    C --> F["Detect urgency cues<br/>'within 24h', 'act now'"]
    D & E & F --> G{"Verdict"}
    G -->|danger rule<br/>or bad link| R1["🛑 DANGEROUS"]
    G -->|rule + urgency| R1
    G -->|rule only| R2["⚠️ SUSPICIOUS"]
    G -->|nothing| R3["✅ SAFE"]
    R1 & R2 & R3 --> V["🔊 Spoken verdict<br/>+ 'rule to remember'<br/>+ share card"]

    style R1 fill:#ffcdd2,stroke:#c62828,stroke-width:2px,color:#b71c1c
    style R2 fill:#ffe7a3,stroke:#f9a825,stroke-width:2px,color:#7a5b00
    style R3 fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px,color:#1b5e20
```

---

## 🌐 Safe Browser — an allowlist, not a blocklist

Most filters block *known-bad* sites and miss everything new. ConsentLens flips it: a curated list of **~110 commonly-used India domains** (banks, UPI, `gov.in`, top shopping/news/social) load freely; **anything else is treated as potentially fraudulent** until the user consciously continues. In child mode, unknown sites simply stay closed.

```mermaid
flowchart TD
    U["User opens a site"] --> S{"siteTrust(url)"}
    S -->|"on trusted list<br/>(exact-suffix match)"| T["✅ Load · green verified badge"]
    S -->|"phishing heuristics hit<br/>(IP / lookalike / shortener)"| B["🛑 Hard blocked"]
    S -->|"not recognised"| W["⚠️ 'Not a commonly used site'"]
    W --> M{"Mode?"}
    M -->|adult| P["Proceed once · or go back"]
    M -->|child| K["🔒 Stays closed"]

    style T fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px,color:#1b5e20
    style B fill:#ffcdd2,stroke:#c62828,stroke-width:2px,color:#b71c1c
    style W fill:#ffe7a3,stroke:#f9a825,stroke-width:2px,color:#7a5b00
    style K fill:#d9ccf2,stroke:#5e35b1,stroke-width:2px,color:#4527a0
```

> Ride-along tricks like `google.com.evil.in` or `fakeflipkart.com` are rejected — matching is exact-label suffix only, covered by unit tests.

---

## 🧸 Safe Handoff — parent-controlled Kids Mode

The parent picks exactly which apps the child may open and sets a 4-digit exit PIN. While Kids Mode is on, the foreground app is watched; anything outside the allowlist is covered by a friendly *"ask a grown-up"* screen. Sign-in helpers (Google Play Services) and the dialer are never blocked, so the experience stays smooth and emergency calls remain possible.

```mermaid
sequenceDiagram
    actor Parent
    actor Child
    participant Setup as Kids Setup
    participant Mon as MonitorService
    participant Guard as KidsBlockOverlay

    Parent->>Setup: pick allowed apps + set exit PIN
    Setup->>Mon: kids_mode_on = true, allowlist saved
    Parent-->>Child: hands over the phone

    loop every 1.2s
        Child->>Mon: opens an app (foreground event)
        alt app is on allowlist (or a sign-in helper)
            Mon->>Child: ✅ app runs freely
        else app not allowed
            Mon->>Guard: show "🧸 ask a grown-up"
            Guard->>Child: friendly block + "Back to play"
        end
    end

    Parent->>Guard: enter exit PIN
    Guard->>Mon: kids_mode_on = false → normal mode
```

> **Honest scope:** without device-owner enrollment this is a strong *deterrent*, not an unbreakable kiosk — the same non-root ceiling consumer parental apps hit.

---

## 🔐 Privacy by construction

```mermaid
flowchart LR
    subgraph YES["✅ What ConsentLens does"]
        A1["Process text & images on-device"]
        A2["Store settings in local prefs"]
        A3["Open YOUR sms / dialer app via intents"]
    end
    subgraph NO["🚫 What it never does"]
        B1["Send data to a server"]
        B2["Create an account or login"]
        B3["Ask for SMS / Contacts / Location"]
        B4["Track or profile the user"]
    end
    style YES fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px,color:#1b5e20
    style NO fill:#ffcdd2,stroke:#c62828,stroke-width:2px,color:#b71c1c
```

**Permissions used (and why):** overlay (permission popups & kids guard) · usage-access (which app is open) · notifications (foreground service) · biometric (adult/child verify). **No** SMS, Contacts, Camera, or Location permission.

---

## 📂 Project layout

```
lib/
├── main.dart                 # app + overlay entrypoints
├── logic/
│   ├── scam_engine.dart      # 🛡️ on-device scam taxonomy + verdict
│   ├── threat.dart           # 🌐 domain heuristics + trusted-site allowlist
│   ├── learn_content.dart    # 🎓 lessons, quiz, badges, scam library
│   ├── i18n.dart             # 🗣️ EN/HI/KN strings + TTS locales
│   ├── store.dart            # 💾 shared prefs (also read by Kotlin)
│   └── native.dart           # 🔌 MethodChannel bridge
├── screens/                  # home · scan · safe_browser · learn_zone
│                             # trusted_circle · kids_mode · emergency_hub
└── widgets/                  # design system + quick-hide decoy
android/app/src/main/kotlin/com/consentlens/consentlens/
├── MonitorService.kt         # foreground-app watch + kids gate
├── OverlayController.kt      # permission popup (2nd Flutter engine)
├── KidsBlockOverlay.kt       # native kids "ask a grown-up" guard
└── MainActivity.kt           # channel handlers
test/
└── logic_test.dart           # 35 unit tests (scam, threat, allowlist, i18n)
```

---

## 🚀 Build & run

```bash
flutter pub get
flutter test                       # 35 unit tests
flutter build apk --release        # → build/app/outputs/flutter-apk/
```

A ready-to-install build for the team lives at **`APKforTeamate/ConsentLens.apk`** (universal: arm64 + arm32 + x86_64, minSdk 26).

**On a Samsung/Oppo phone:** allow "install from this source" → tap *Install anyway* past Play Protect → set the app's Battery to **Unrestricted** so the guardian service survives.

---

<div align="center">

Made with 💗 for first-time women internet users · **100% on your phone**

</div>
