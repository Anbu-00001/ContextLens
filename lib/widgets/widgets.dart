import 'package:flutter/material.dart';

import '../logic/i18n.dart';
import '../logic/risk_engine.dart';
import '../logic/safety_resources.dart';
import '../theme.dart';

// Permission categories that amount to tracking/profiling — DPDP Act prohibits
// these for children (<18).
const Set<String> _trackingCats = {
  'location',
  'bg_location',
  'phone_state',
  'sensors',
  'nearby',
};

// ── App Logo ────────────────────────────────────────────────────────────────
class CLLogo extends StatelessWidget {
  final double size;
  const CLLogo({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CLColors.pink,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Icon(Icons.security_rounded, color: Colors.white, size: size * 0.6),
    );
  }
}

// ── Risk Badge ──────────────────────────────────────────────────────────────
class RiskBadge extends StatelessWidget {
  final Risk level;
  final String lang;
  final bool large;
  const RiskBadge(
      {super.key, required this.level, required this.lang, this.large = false});

  Color get bg {
    switch (level) {
      case Risk.low:
        return CLColors.greenLight;
      case Risk.medium:
        return CLColors.amberLight;
      case Risk.high:
        return CLColors.redLight;
    }
  }

  Color get fg {
    switch (level) {
      case Risk.low:
        return CLColors.green;
      case Risk.medium:
        return CLColors.amberDark;
      case Risk.high:
        return CLColors.redDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = (level == Risk.high
            ? S.high
            : level == Risk.medium
                ? S.medium
                : S.low)
        .of(lang);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 5 : 3,
      ),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: large ? 13 : 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ── Category Icon ───────────────────────────────────────────────────────────
class CategoryIcon extends StatelessWidget {
  final PermCategory category;
  final double size;
  const CategoryIcon({super.key, required this.category, this.size = 36});

  static const Map<String, IconData> _icons = {
    'location': Icons.location_on_rounded,
    'bg_location': Icons.share_location_rounded,
    'camera': Icons.camera_alt_rounded,
    'microphone': Icons.mic_rounded,
    'contacts': Icons.people_rounded,
    'sms': Icons.sms_rounded,
    'calls': Icons.call_rounded,
    'storage': Icons.folder_rounded,
    'notifications': Icons.notifications_rounded,
    'sensors': Icons.monitor_heart_rounded,
    'nearby': Icons.bluetooth_rounded,
    'phone_state': Icons.perm_device_information_rounded,
    'overlay': Icons.layers_rounded,
    'calendar': Icons.calendar_month_rounded,
    'internet': Icons.public_rounded,
  };

  static const List<List<Color>> _palette = [
    [CLColors.pinkLight, CLColors.pink],
    [CLColors.purpleLight, CLColors.purple],
    [CLColors.amberLight, CLColors.amber],
    [CLColors.greenLight, CLColors.green],
    [CLColors.blueLight, CLColors.blue],
  ];

  @override
  Widget build(BuildContext context) {
    final pair = _palette[category.id.hashCode.abs() % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: pair[0],
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(_icons[category.id] ?? Icons.lock_rounded,
          color: pair[1], size: size * 0.52),
    );
  }
}

// ── Permission Animation Strip (emoji flow / mic wave / camera blink) ──────
class PermissionAnimStrip extends StatefulWidget {
  final PermCategory category;
  const PermissionAnimStrip({super.key, required this.category});

  @override
  State<PermissionAnimStrip> createState() => _PermissionAnimStripState();
}

class _PermissionAnimStripState extends State<PermissionAnimStrip>
    with TickerProviderStateMixin {
  late final AnimationController _dotCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat();
  late final AnimationController _waveCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000))
    ..repeat();
  late final AnimationController _blinkCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..repeat();

  @override
  void dispose() {
    _dotCtrl.dispose();
    _waveCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border:
            Border.symmetric(horizontal: BorderSide(color: CLColors.border)),
      ),
      child: Center(child: _buildAnimation()),
    );
  }

  Widget _buildAnimation() {
    switch (widget.category.anim) {
      case AnimKind.wave:
        return _buildWaveAnim();
      case AnimKind.blink:
        return _buildBlinkAnim(widget.category.emojis);
      case AnimKind.flow:
        return _buildDotFlow(widget.category.emojis);
    }
  }

  Widget _buildDotFlow(List<String> emojis) {
    final List<Widget> children = [];
    for (int i = 0; i < emojis.length; i++) {
      children.add(Text(emojis[i], style: const TextStyle(fontSize: 22)));
      if (i < emojis.length - 1) {
        children.add(const SizedBox(width: 4));
        for (int d = 0; d < 3; d++) {
          children.add(_FlowDot(controller: _dotCtrl, delay: d * 0.18));
          children.add(const SizedBox(width: 4));
        }
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildWaveAnim() {
    const heights = [8.0, 18.0, 26.0, 18.0, 8.0];
    const delays = [0.0, 0.13, 0.26, 0.39, 0.52];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.category.emojis.first,
            style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        ...List.generate(
          5,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _WaveBar(
              controller: _waveCtrl,
              maxHeight: heights[i],
              delay: delays[i],
              color: CLColors.purple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlinkAnim(List<String> emojis) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _blinkCtrl,
          builder: (_, __) {
            final t = _blinkCtrl.value;
            final opacity = (t > 0.88 && t < 0.95) ? 0.15 : 1.0;
            return Opacity(
                opacity: opacity,
                child:
                    Text(emojis.first, style: const TextStyle(fontSize: 22)));
          },
        ),
        const SizedBox(width: 4),
        for (int d = 0; d < 3; d++) ...[
          _FlowDot(controller: _dotCtrl, delay: d * 0.18),
          const SizedBox(width: 4),
        ],
        Text(emojis.length > 1 ? emojis[1] : '👤',
            style: const TextStyle(fontSize: 22)),
      ],
    );
  }
}

class _FlowDot extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  const _FlowDot({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        double t = (controller.value - delay) % 1.0;
        if (t < 0) t += 1.0;
        final double scale =
            t < 0.5 ? 0.7 + (t / 0.5) * 0.6 : 1.3 - ((t - 0.5) / 0.5) * 0.6;
        final double opacity =
            t < 0.5 ? 0.2 + (t / 0.5) * 0.8 : 1.0 - ((t - 0.5) / 0.5) * 0.8;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  color: CLColors.pink, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}

class _WaveBar extends StatelessWidget {
  final AnimationController controller;
  final double maxHeight;
  final double delay;
  final Color color;
  const _WaveBar(
      {required this.controller,
      required this.maxHeight,
      required this.delay,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        double t = (controller.value - delay) % 1.0;
        if (t < 0) t += 1.0;
        final double scaleY =
            t < 0.5 ? 0.35 + (t / 0.5) * 0.65 : 1.0 - ((t - 0.5) / 0.5) * 0.65;
        final double opacity =
            t < 0.5 ? 0.4 + (t / 0.5) * 0.6 : 1.0 - ((t - 0.5) / 0.5) * 0.6;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            width: 5,
            height: (maxHeight * scaleY).clamp(2, maxHeight),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3)),
          ),
        );
      },
    );
  }
}

// ── Permission Category Card (popup + permissions screen) ───────────────────
class CategoryCard extends StatelessWidget {
  final PermCategory category;
  final String lang;
  final String userMode; // 'adult' | 'child'
  const CategoryCard(
      {super.key,
      required this.category,
      required this.lang,
      this.userMode = 'adult'});

  @override
  Widget build(BuildContext context) {
    final ageRisk = userMode == 'child' ? category.kidRisk : category.adultRisk;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CategoryIcon(category: category, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(category.title.of(lang),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: CLColors.textPrimary)),
                ),
                RiskBadge(level: category.risk, lang: lang),
              ],
            ),
          ),
          PermissionAnimStrip(category: category),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: _kv(S.whyNeeded.of(lang), category.why.of(lang)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: _kv(S.ifAllowed.of(lang), category.consequence.of(lang)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: userMode == 'child'
                    ? CLColors.redLight
                    : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: userMode == 'child'
                        ? const Color(0xFFF3C2C2)
                        : CLColors.border),
              ),
              child: Text(
                ageRisk.of(lang),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: userMode == 'child'
                      ? CLColors.redDark
                      : CLColors.textSec,
                ),
              ),
            ),
          ),
          // DPDP Act citation when a child meets a tracking-type permission.
          if (userMode == 'child' && _trackingCats.contains(category.id))
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.gavel_rounded,
                      size: 14, color: CLColors.purple),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(S.dpdpChildNote.of(lang),
                        style: const TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: CLColors.purple)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: CLColors.textMuted,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: CLTextStyles.body),
      ],
    );
  }
}

// ── Age Fit Chip ────────────────────────────────────────────────────────────
class FitChip extends StatelessWidget {
  final String label;
  final Fit fit;
  final String lang;
  const FitChip(
      {super.key, required this.label, required this.fit, required this.lang});

  @override
  Widget build(BuildContext context) {
    final Color bg, fg;
    final String emoji;
    final L text;
    switch (fit) {
      case Fit.ok:
        bg = CLColors.greenLight;
        fg = CLColors.green;
        emoji = '✅';
        text = S.okFor;
        break;
      case Fit.caution:
        bg = CLColors.amberLight;
        fg = CLColors.amberDark;
        emoji = '⚠️';
        text = S.cautionFor;
        break;
      case Fit.no:
        bg = CLColors.redLight;
        fg = CLColors.redDark;
        emoji = '🚫';
        text = S.notOkFor;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
          Text(text.of(lang), style: TextStyle(fontSize: 10, color: fg)),
        ],
      ),
    );
  }
}

// ── Section Label ───────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: CLColors.textMuted,
            letterSpacing: 0.7),
      ),
    );
  }
}

// ── Toggle Row ──────────────────────────────────────────────────────────────
class SettingToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingToggleRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: iconFg, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CLColors.textPrimary)),
                Text(subtitle, style: CLTextStyles.label),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: CLColors.pink),
        ],
      ),
    );
  }
}

// ── Privacy Chips Strip ─────────────────────────────────────────────────────
class PrivacyChipsStrip extends StatelessWidget {
  const PrivacyChipsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CLColors.greenLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          _PrivChip(Icons.laptop_rounded, 'On-device only'),
          _PrivChip(Icons.cloud_off_rounded, 'No cloud sync'),
          _PrivChip(Icons.person_off_rounded, 'No accounts'),
          _PrivChip(Icons.visibility_off_rounded, 'No tracking'),
        ],
      ),
    );
  }
}

class _PrivChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PrivChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: CLColors.green),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: CLColors.green)),
      ],
    );
  }
}

// ── Help Resources (official Indian helplines) ──────────────────────────────
class HelpResourcesList extends StatelessWidget {
  final String lang;
  const HelpResourcesList({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(S.helpIntro.of(lang),
              style: const TextStyle(fontSize: 12, color: CLColors.textMuted)),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              for (int i = 0; i < helpResources.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 58),
                _HelpRow(res: helpResources[i], lang: lang),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HelpRow extends StatelessWidget {
  final HelpResource res;
  final String lang;
  const _HelpRow({required this.res, required this.lang});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchHelp(res.action),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: res.isPhone ? CLColors.greenLight : CLColors.blueLight,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(res.icon,
                  size: 18,
                  color: res.isPhone ? CLColors.green : CLColors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(res.title.of(lang),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CLColors.textPrimary)),
                  Text(res.subtitle.of(lang),
                      style: const TextStyle(
                          fontSize: 11, color: CLColors.textMuted)),
                ],
              ),
            ),
            Icon(res.isPhone ? Icons.call_rounded : Icons.open_in_new_rounded,
                size: 18, color: CLColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Mode Badge (Adult / Child) ──────────────────────────────────────────────
class ModeBadge extends StatelessWidget {
  final String mode;
  final String lang;
  const ModeBadge({super.key, required this.mode, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isChild = mode == 'child';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isChild ? CLColors.purpleLight : CLColors.greenLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isChild ? '🧒' : '🧑', style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            (isChild ? S.childMode : S.adultMode).of(lang),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isChild ? CLColors.purple : CLColors.green),
          ),
        ],
      ),
    );
  }
}
